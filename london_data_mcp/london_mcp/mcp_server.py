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
async def search_with_natural_language(query: str = "fun activities", limit: int = 10) -> str:
    """Search a curated vector database of London locations, attractions, and activities using semantic natural language queries.
    
    Use this tool whenever you need to find specific types of places in London for a user's itinerary (e.g., 'quiet coffee shops', 'historical museums', 'family-friendly parks').
    
    Args:
        query (str): A detailed natural language description of what you are looking for. The more descriptive the query, the better the semantic match (e.g., 'romantic dinner spots with a view of the Thames' rather than just 'restaurants').
        limit (int): The maximum number of results to retrieve. Default is 10. You should dynamically adjust this based on the user's itinerary length (e.g., request ~3-5 items per planned day to ensure you have enough options to build a full schedule).
            
    Returns:
        str: A JSON-formatted string containing a list of search results, including venue names, descriptions, and metadata.
    """
    logger.info(f"Received search query: {query}, and limit: {limit}")
    embedding = get_embedding(query)
    embedding_str = str(embedding)
        
    db = SessionLocal()
    results: List[SearchResult] = []
    
    try:
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
        logger.info(f"Total results after sorting are {len(results)}")
        sub_results = results[:limit]
        
        # Pydantic models are not natively JSON serializable by json.dumps, so we convert them to dicts
        sub_results_json = json.dumps([r.model_dump() if hasattr(r, 'model_dump') else r.dict() for r in sub_results])
        logger.info(f"Results for {query} are {sub_results_json}")
        return sub_results_json
    except Exception as e:
        logger.error(f"Search failed: {e}")
        raise e
    finally:
        db.close()

if __name__ == "__main__":
   mcp.run(transport="streamable-http", port=8002, host="0.0.0.0")