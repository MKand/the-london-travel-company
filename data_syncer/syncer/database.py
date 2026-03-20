from sqlalchemy import create_engine, text, event, inspect
from sqlalchemy.orm import sessionmaker
from syncer.config import settings
from syncer.models import Base, Location, Activity
import os

# Engine configuration
engine = create_engine(settings.database_url)

SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

def init_db():
    # Attempt to create vector extension for Postgres if it doesn't exist
    with engine.connect() as conn:
        conn.execute(text("CREATE EXTENSION IF NOT EXISTS vector"))
        conn.commit()
        
    inspector = inspect(engine)
    if not inspector.has_table(Location.__tablename__) or not inspector.has_table(Activity.__tablename__):
        with engine.connect() as conn:
            conn.execute(text("""
            CREATE TABLE IF NOT EXISTS locations (
                sight_id VARCHAR(50) PRIMARY KEY,
                name VARCHAR(255) NOT NULL,
                category VARCHAR(100),
                description TEXT,
                embedding VECTOR(768)
            );
            """))
            conn.execute(text("""
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

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
