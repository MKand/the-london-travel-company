import logging
import json
from typing import Any, List, Optional, Literal, Union
from pydantic import BaseModel
from fastmcp import FastMCP
from mcp.server import Server
from mcp.types import Tool, TextContent, ImageContent, EmbeddedResource
from sqlalchemy import text
from sqlalchemy.orm import Session
from google import genai
from london_mcp.database import engine, SessionLocal
from london_mcp.models import Location, Activity
from london_mcp.config import settings

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Initialize GenAI client
client = genai.Client(vertexai=True, project=settings.PROJECT_ID, location=settings.LOCATION)

mcp = FastMCP("london-data-backend")

class BaseSearchResult(BaseModel):
    id: str
    name: str
    description: Optional[str] = None
    score: float

class LocationResult(BaseSearchResult):
    type: Literal["location"]
    category: Optional[str] = None

class ActivityResult(BaseSearchResult):
    type: Literal["activity"]
    cost: float
    duration: str

SearchResult = Union[LocationResult, ActivityResult]

def get_embedding(text: str) -> List[float]:
    """Generate embedding using Vertex AI."""
    try:
        response = client.models.embed_content(
            model=settings.EMBEDDING_MODEL,
            contents=text
        )
        return response.embeddings[0].values
    except Exception as e:
        logger.error(f"Error generating embedding: {e}")
        raise

@mcp.tool()
async def search_with_natural_language(query: str = "fun activities", search_type: str = "all", limit: int = 5) -> List[SearchResult]:
    """Search for London locations and activities using natural language.
    
    Args:
        query: The natural language query to search for.
        search_type: The type of results to return ('locations', 'activities', or 'all'). Defaults to 'all'.
        limit: The maximum number of results to return. Defaults to 5.
            
    Returns:
        List[SearchResult]: A list of location or activity search results.
    """
    logger.info(f"Received search query: {query}, with search type: {search_type}, and limit: {limit}")
    embedding = get_embedding(query)
    embedding_str = str(embedding)
        
    db = SessionLocal()
    results: List[SearchResult] = []
    
    try:
        if search_type in ["locations", "all"]:
            # Vector search for locations
            if settings.DB_TYPE == "postgres":
                sql = text(f"SELECT sight_id, name, category, description, (embedding <=> :embedding) as score FROM locations ORDER BY score ASC LIMIT :limit")
            else:
                sql = text(f"SELECT sight_id, name, category, description, vec_distance_cosine(embedding, vec_f32(:embedding)) as score FROM locations ORDER BY score ASC LIMIT :limit")
            
            loc_rows = db.execute(sql, {"embedding": embedding_str, "limit": limit}).fetchall()
            for row in loc_rows:
                results.append(LocationResult(
                    type="location",
                    id=row.sight_id,
                    name=row.name,
                    category=row.category,
                    description=row.description,
                    score=float(row.score)
                ))

        if search_type in ["activities", "all"]:
            # Vector search for activities
            if settings.DB_TYPE == "postgres":
                sql = text(f"SELECT activity_id, name, description, cost, duration_min, duration_max, (embedding <=> :embedding) as score FROM activities ORDER BY score ASC LIMIT :limit")
            else:
                sql = text(f"SELECT activity_id, name, description, cost, duration_min, duration_max, vec_distance_cosine(embedding, vec_f32(:embedding)) as score FROM activities ORDER BY score ASC LIMIT :limit")
            
            act_rows = db.execute(sql, {"embedding": embedding_str, "limit": limit}).fetchall()
            for row in act_rows:
                results.append(ActivityResult(
                    type="activity",
                    id=row.activity_id,
                    name=row.name,
                    description=row.description,
                    cost=float(row.cost),
                    duration=f"{row.duration_min}-{row.duration_max} mins",
                    score=float(row.score)
                ))
        
        # Sort combined results by score
        results.sort(key=lambda x: x.score)
        return results[:limit]
        
    except Exception as e:
        logger.error(f"Search failed: {e}")
        raise e
    finally:
        db.close()

if __name__ == "__main__":
   mcp.run(transport="streamable-http", port=8002, host="0.0.0.0")