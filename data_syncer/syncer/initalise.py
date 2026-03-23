
from sqlalchemy import create_engine, inspect, text
from syncer.database import engine as default_engine
from syncer.config import settings
import logging

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

def initialise_db(admin_db_url=None):
  if admin_db_url:
    engine = create_engine(admin_db_url)
  else:
    engine = default_engine
          
  user = settings.POSTGRES_USER
  password = settings.POSTGRES_PASSWORD
  db = settings.POSTGRES_DB
  
  with engine.connect() as conn:
    # Check if user exists before creating
    user_exists = conn.execute(text(f"SELECT 1 FROM pg_roles WHERE rolname='{user}'")).scalar()
    if not user_exists:
        conn.execute(text(f"CREATE USER {user} WITH PASSWORD '{password}'"))
        logger.info(f"Created user {user}")
    else:
        logger.info(f"User {user} already exists")
      
    # Check if DB exists before creating
    db_exists = conn.execute(text(f"SELECT 1 FROM pg_database WHERE datname='{db}'")).scalar()
    if not db_exists:
        conn.execute(text(f"CREATE DATABASE {db} OWNER {user}"))
        logger.info(f"Created database {db}")
    else:
        logger.info(f"Database {db} already exists")