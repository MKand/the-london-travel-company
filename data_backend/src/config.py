from pydantic_settings import BaseSettings
from typing import Optional
import os

class Settings(BaseSettings):
    # Database configuration
    DB_TYPE: str = "sqlite"  # "sqlite" or "postgres"
    SQLITE_DB_PATH: str = os.getenv("SQLITE_DB_PATH", "/Users/manasakandula/Documents/demos/london-travel-agent/data_london/london_travel.db")
    
    POSTGRES_USER: str = "user"
    POSTGRES_PASSWORD: str = "password"
    POSTGRES_HOST: str = "postgres"
    POSTGRES_PORT: int = 5432
    POSTGRES_DB: str = "london_travel"
    
    # GCP configuration
    PROJECT_ID: Optional[str] = os.getenv("GOOGLE_CLOUD_PROJECT")
    LOCATION: str = os.getenv("GOOGLE_CLOUD_LOCATION", "us-central1")
    
    # Matching Engine / Embedding configuration
    MAX_ROWS: int = 5
    
    @property
    def database_url(self) -> str:
        if self.DB_TYPE == "postgres":
            return f"postgresql://{self.POSTGRES_USER}:{self.POSTGRES_PASSWORD}@{self.POSTGRES_HOST}:{self.POSTGRES_PORT}/{self.POSTGRES_DB}"
        return f"sqlite:///{self.SQLITE_DB_PATH}"

settings = Settings()
