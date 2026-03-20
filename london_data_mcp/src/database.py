from sqlalchemy import create_engine, text, event
from sqlalchemy.orm import sessionmaker
from .config import settings
from .models import Base
import sqlite3
import sqlite_vec
import os

# Engine configuration
if settings.DB_TYPE == "postgres":
    engine = create_engine(settings.database_url)
else:
    # SQLite connection with sqlite-vec extension
    engine = create_engine(settings.database_url)

    @event.listens_for(engine, "connect")
    def load_extension(dbapi_conn, unused):
        dbapi_conn.enable_load_extension(True)
        sqlite_vec.load(dbapi_conn)
        dbapi_conn.enable_load_extension(False)

SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

def init_db():
    # Attempt to create vector extension for Postgres if it doesn't exist
    if settings.DB_TYPE == "postgres":
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
