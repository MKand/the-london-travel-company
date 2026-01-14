# Copyright 2025 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

import os
import logging
from pydantic_settings import BaseSettings
from pydantic import BaseModel, Field, ValidationError, model_validator
from google.adk.sessions import InMemorySessionService


logger = logging.getLogger(__name__)


# These will be used as defaults in the Config class via Field(default=...)
# or simply by being referenced if they aren't overridden by environment variables.
MAX_NUM_ROWS = int(os.getenv('MAX_NUM_ROWS', '20'))
EMBEDDING_MODEL_NAME = os.getenv("EMBEDDING_MODEL_NAME", 'text-embedding-005')
DEBUG_STATE = os.getenv("DEBUG_STATE", "false").lower() in ('true', '1', 't', 'yes', 'y')
EMBEDDING_DIMENSION = 768
LLM_MODEL_NAME = os.getenv("LLM_MODEL_NAME", 'gemini-2.5-flash') # Updated to latest standard
PROJECT_ID = os.getenv("GOOGLE_CLOUD_PROJECT")
LOCATION = os.getenv("GOOGLE_CLOUD_LOCATION")

# Database Configuration
DB_TYPE = os.getenv("DB_TYPE", "sqlite").lower()
LOCAL_SQLLITE_DB_PATH = os.path.join(os.path.dirname(os.path.abspath(__file__)), "data")
SQLLITE_DB_PATH = os.getenv('SQLITE_DB_PATH', LOCAL_SQLLITE_DB_PATH)

# Centralizing settings used in main.py
ALLOWED_ORIGINS = ["http://localhost", "http://localhost:8080", "*"]
SESSION_DB_URL = "sqlite:///./sessions.db"

logger.info(f"The DB type is: {DB_TYPE}")



session_service = InMemorySessionService()

class AgentModel(BaseModel):
    """Agent model settings."""
    name: str = Field(default="london_holiday_agent")
    model: str = Field(default=LLM_MODEL_NAME)

class Config(BaseSettings):
    """Configuration settings for the london holiday agent."""

    # Database settings
    db_type: str = DB_TYPE
    postgres_user: str | None = Field(default=os.getenv("POSTGRES_USER"))
    postgres_password: str | None = Field(default=os.getenv("POSTGRES_PASSWORD"))
    postgres_host: str | None = Field(default=os.getenv("POSTGRES_HOST"))
    postgres_port: str | None = Field(default=os.getenv("POSTGRES_PORT"))
    postgres_db: str | None = Field(default=os.getenv("POSTGRES_DB"))

    db_file_path: str = os.path.join(SQLLITE_DB_PATH, "london_travel.sql")
    embedding_model_name: str = EMBEDDING_MODEL_NAME
    max_rows: int = MAX_NUM_ROWS
    debug_state: bool = DEBUG_STATE
    project: str | None = PROJECT_ID
    location: str | None = LOCATION
    app_name: str = "LYLA"
    agent_settings: AgentModel = Field(default_factory=AgentModel) 
    genai_use_vertexai: str = Field(default="1") 

    # API and Session Settings
    allowed_origins: list[str] = ALLOWED_ORIGINS
    session_db_url: str = SESSION_DB_URL

    @model_validator(mode="after")
    def validate_db_settings(self):
        if self.db_type == "postgres":
            missing = []
            if not self.postgres_user: missing.append("postgres_user")
            if not self.postgres_password: missing.append("postgres_password")
            if not self.postgres_host: missing.append("postgres_host")
            if not self.postgres_db: missing.append("postgres_db")
            if missing:
                raise ValueError(f"Missing required postgres settings when db_type is 'postgres': {', '.join(missing)}")
        return self

try:
    configs = Config()
except ValidationError as e:
    logger.error(
        f"Pydantic ValidationError loading configuration in config.py. "
        f"Details: {e.errors()}"
    )
except Exception as e:
    logger.error(f"Unexpected error loading configuration in config.py: {e}")
