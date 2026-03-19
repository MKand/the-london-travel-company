from sqlalchemy import create_engine, text, event
from sqlalchemy.orm import sessionmaker
from data_london.src.config import settings
from data_london.src.models import Base
import os

# Engine configuration
engine = create_engine(settings.database_url)

SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

def init_db():
    # Attempt to create vector extension for Postgres if it doesn't exist
    with engine.connect() as conn:
        conn.execute(text("CREATE EXTENSION IF NOT EXISTS vector"))
        conn.commit()
    Base.metadata.create_all(bind=engine)

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
