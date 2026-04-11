from pydantic_settings import BaseSettings
from typing import Optional
import google.auth
import os

class Settings(BaseSettings):
    # Database configuration
    DB_TYPE: str = os.getenv("DB_TYPE", "sqlite")  # "sqlite" or "postgres"
    if DB_TYPE == "sqlite":
        SQLITE_DB_PATH: str = os.getenv("SQLITE_DB_PATH",os.path.join(os.path.dirname(os.path.dirname(__file__)), "data", "london_travel.db"))
    else:
        print("Using postgres database")
        SQLITE_DB_PATH: str = ""
        POSTGRES_USER: str = os.getenv("POSTGRES_USER", "user")
        POSTGRES_PASSWORD: str = os.getenv("POSTGRES_PASSWORD", "password")
        POSTGRES_HOST: str = os.getenv("POSTGRES_HOST", "localhost")
        POSTGRES_PORT: int = os.getenv("POSTGRES_PORT", 5432)
        POSTGRES_DB: str = os.getenv("POSTGRES_DB", "london_travel")
    
    # GCP configuration
    PROJECT_ID: Optional[str] = os.getenv("GOOGLE_CLOUD_PROJECT")
    LOCATION: str = os.getenv("GOOGLE_CLOUD_LOCATION", "us-central1")
    EMBEDDING_MODEL: str = os.getenv("EMBEDDING_MODEL", "text-embedding-005")
    
    if PROJECT_ID is None:
        _,PROJECT_ID = google.auth.default()
        
    # Matching Engine / Embedding configuration
    MAX_ROWS: int = 5
    
    @property
    def database_url(self) -> str:
        if self.DB_TYPE == "postgres":
            return f"postgresql://{self.POSTGRES_USER}:{self.POSTGRES_PASSWORD}@{self.POSTGRES_HOST}:{self.POSTGRES_PORT}/{self.POSTGRES_DB}"
        return f"sqlite:///{self.SQLITE_DB_PATH}"

settings = Settings()
