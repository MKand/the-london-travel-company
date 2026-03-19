import logging
import json
from typing import Any, List, Optional
from fastmcp import FastMCP
from mcp.server import Server
from mcp.types import Tool, TextContent, ImageContent, EmbeddedResource
from sqlalchemy import text
from sqlalchemy.orm import Session
from google import genai
from .database import engine, SessionLocal
from .models import Location, Activity
from .config import settings

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Initialize GenAI client
client = genai.Client(vertexai=True, project=settings.PROJECT_ID, location=settings.LOCATION)

mcp = FastMCP("london-data-backend")

def get_embedding(text: str) -> List[float]:
    """Generate embedding using Vertex AI."""
    try:
        response = client.models.embed_content(
            model="text-embedding-004", # Hardcoded or from settings? settings says 005 but agent says 004 is standard
            contents=text
        )
        return response.embeddings[0].values
    except Exception as e:
        logger.error(f"Error generating embedding: {e}")
        raise

# @mcp_server.list_tools()
# async def handle_list_tools() -> list[Tool]:
#     return [
#         Tool(
#             name="enriched_search",
#             description="Search for London attractions and activities using semantic search. Returns unified results.",
#             inputSchema={
#                 "type": "object",
#                 "properties": {
#                     "query": {"type": "string", "description": "Natural language search query"},
#                     "type": {"type": "string", "enum": ["locations", "activities", "all"], "default": "all"},
#                     "limit": {"type": "integer", "default": 5}
#                 },
#                 "required": ["query"]
#             }
#         )
#     ]

@mcp.tool()
async def handle_call_tool(name: str, arguments: dict | None) -> list[TextContent]:
    if name == "enriched_search":
        query = arguments.get("query")
        search_type = arguments.get("type", "all")
        limit = arguments.get("limit", 5)
        
        embedding = get_embedding(query)
        embedding_str = str(embedding)
        
        db = SessionLocal()
        results = []
        
        try:
            if search_type in ["locations", "all"]:
                # Vector search for locations
                if settings.DB_TYPE == "postgres":
                    sql = text(f"SELECT id, name, category, description, (embedding <=> :embedding) as score FROM locations ORDER BY score ASC LIMIT :limit")
                else:
                    sql = text(f"SELECT id, name, category, description, vec_distance_cosine(embedding, vec_f32(:embedding)) as score FROM locations ORDER BY score ASC LIMIT :limit")
                
                loc_rows = db.execute(sql, {"embedding": embedding_str, "limit": limit}).fetchall()
                for row in loc_rows:
                    results.append({
                        "type": "location",
                        "id": row.id,
                        "name": row.name,
                        "category": row.category,
                        "description": row.description,
                        "score": float(row.score)
                    })

            if search_type in ["activities", "all"]:
                # Vector search for activities
                if settings.DB_TYPE == "postgres":
                    sql = text(f"SELECT activity_id, name, description, cost, duration_min, duration_max, (embedding <=> :embedding) as score FROM activities ORDER BY score ASC LIMIT :limit")
                else:
                    sql = text(f"SELECT activity_id, name, description, cost, duration_min, duration_max, vec_distance_cosine(embedding, vec_f32(:embedding)) as score FROM activities ORDER BY score ASC LIMIT :limit")
                
                act_rows = db.execute(sql, {"embedding": embedding_str, "limit": limit}).fetchall()
                for row in act_rows:
                    results.append({
                        "type": "activity",
                        "id": row.activity_id,
                        "name": row.name,
                        "description": row.description,
                        "cost": float(row.cost),
                        "duration": f"{row.duration_min}-{row.duration_max} mins",
                        "score": float(row.score)
                    })
            
            # Sort combined results by score
            results.sort(key=lambda x: x["score"])
            return [TextContent(type="text", text=json.dumps(results[:limit], indent=2))]
            
        except Exception as e:
            logger.error(f"Search failed: {e}")
            return [TextContent(type="text", text=f"Error performing search: {str(e)}")]
        finally:
            db.close()
            
    return [TextContent(type="text", text=f"Unknown tool: {name}")]

if __name__ == "__main__":
   mcp.run(transport="streamable-http", port=8002, host="0.0.0.0")