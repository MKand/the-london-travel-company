import os
import json
import logging
from sqlalchemy import create_engine, text, event, inspect
from sqlalchemy.orm import Session, sessionmaker
from google import genai

from syncer.database import SessionLocal, init_db
from syncer.models import Location, Activity, Base
from syncer.config import settings

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

ATTRACTIONS_JSON_PATH = os.path.join(os.path.dirname(os.path.dirname(__file__)), "data", "london_attractions.json")
ACTIVITIES_JSON_PATH = os.path.join(os.path.dirname(os.path.dirname(__file__)), "data", "london_activities.json")

if settings.PROJECT_ID:
    client = genai.Client(vertexai=True, project=settings.PROJECT_ID, location=settings.LOCATION)
else:
    client = genai.Client()

def get_embeddings_batched(texts: list[str], batch_size: int = 50) -> list[list[float]]:
    all_embeddings = []
    for i in range(0, len(texts), batch_size):
        batch = texts[i:i + batch_size]
        response = client.models.embed_content(
            model=settings.EMBEDDING_MODEL,
            contents=batch
        )
        for embedding in response.embeddings:
            all_embeddings.append(embedding.values)
    return all_embeddings

def parse_json_data():
    with open(ATTRACTIONS_JSON_PATH, 'r', encoding='utf-8') as f:
        locations_raw = json.load(f)
        
    with open(ACTIVITIES_JSON_PATH, 'r', encoding='utf-8') as f:
        activities_raw = json.load(f)
        
    locations = []
    loc_texts = [f"{loc['name']} - {loc.get('category', '')}: {loc['description']}" for loc in locations_raw]
    logger.info(f"Generating embeddings for {len(loc_texts)} locations...")
    loc_embeddings = get_embeddings_batched(loc_texts)
    
    for loc, embedding in zip(locations_raw, loc_embeddings):
        locations.append({
            "id": loc["sight_id"],
            "name": loc["name"],
            "category": loc.get("category", ""),
            "description": loc["description"],
            "embedding": embedding
        })
        
    activities = []
    act_texts = []
    flatted_acts = []
    
    for sight in activities_raw:
        sight_id = sight["sight_id"]
        for act in sight.get("activities", []):
            duration_mins = act.get("duration_range_mins", [0, 0])
            duration_min = duration_mins[0] if len(duration_mins) > 0 else 0
            duration_max = duration_mins[1] if len(duration_mins) > 1 else duration_min
            
            flatted_acts.append({
                "activity_id": act["activity_id"],
                "name": act["name"],
                "duration_min": duration_min,
                "duration_max": duration_max,
                "kid_friendliness_score": act.get("kid_friendliness_score", 0),
                "cost": float(act.get("cost_gbp", 0.0)),
                "sight_id": sight_id,
                "description": act["description"],
            })
            act_texts.append(f"{act['name']}: {act['description']}")

    logger.info(f"Generating embeddings for {len(act_texts)} activities...")
    act_embeddings = get_embeddings_batched(act_texts)
    
    for act, embedding in zip(flatted_acts, act_embeddings):
        act["embedding"] = embedding
        activities.append(act)
            
    return locations, activities

def create_tables_if_not_exist(engine, conn):
    try:
        inspector = inspect(engine)
        if not inspector.has_table("locations") :
            logger.info("Tables not found, creating them via raw SQL...")
            with engine.connect() as conn:
                conn.execute(text("""
                CREATE EXTENSION IF NOT EXISTS vector;
                CREATE TABLE IF NOT EXISTS locations (
                    sight_id VARCHAR(50) PRIMARY KEY,
                    name VARCHAR(255) NOT NULL,
                    category VARCHAR(100),
                    description TEXT,
                    embedding VECTOR(768)
                );
                """))
                conn.commit()
        
        if not inspector.has_table("activities"):
                conn.execute(text("""
                CREATE EXTENSION IF NOT EXISTS vector;
                CREATE TABLE IF NOT EXISTS activities (
                    activity_id VARCHAR(50) PRIMARY KEY,
                    name VARCHAR(255) NOT NULL,
                    duration_min INT,
                    duration_max INT,
                    kid_friendliness_score INT,
                    cost INT,
                    sight_id VARCHAR(50) REFERENCES locations(sight_id),
                    description TEXT,
                    embedding VECTOR(768)
                );
                """))
                conn.commit()
    except Exception as e:
        logger.error(f"Error inspecting database: {str(e)}")
        raise
    return conn


def sync_data(db_url: str = None):
    logger.info("Starting sync from JSON files")
    locations_data, activities_data = parse_json_data()
    
    if db_url:
        logger.info(f"Targeting custom DB: {db_url}")
        engine = create_engine(db_url)
        
        with engine.connect() as conn:
            create_tables_if_not_exist(engine, conn)
                
        CustomSessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
        db: Session = CustomSessionLocal()
    else:
        logger.info("Targeting default DB from config")
        init_db()
        db: Session = SessionLocal()
    
    try:
        for loc_dict in locations_data:
            loc = db.query(Location).filter(Location.id == loc_dict["id"]).first()
            if not loc:
                loc = Location(**loc_dict)
                db.add(loc)
            else:
                for key, value in loc_dict.items():
                    setattr(loc, key, value)
        
        db.commit()
        logger.info(f"Synced {len(locations_data)} locations.")

        for act_dict in activities_data:
            act = db.query(Activity).filter(Activity.activity_id == act_dict["activity_id"]).first()
            if not act:
                act = Activity(**act_dict)
                db.add(act)
            else:
                for key, value in act_dict.items():
                    setattr(act, key, value)
                    
        db.commit()
        logger.info(f"Synced {len(activities_data)} activities.")
        
    except Exception as e:
        db.rollback()
        logger.error(f"Sync failed: {e}")
        raise
    finally:
        db.close()

if __name__ == "__main__":
    sync_data()
