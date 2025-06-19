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
"""Configuration module for the customer service agent."""

import os
import logging
from pydantic_settings import BaseSettings, SettingsConfigDict
from pydantic import BaseModel, Field, ValidationError
from google.adk.sessions import InMemorySessionService


logging.basicConfig(level=logging.DEBUG)
logger = logging.getLogger(__name__)
os.environ["GOOGLE_GENAI_USE_VERTEXAI"] = "TRUE"
os.environ["GOOGLE_CLOUD_PROJECT"] = "o11y-movie-guru"
os.environ["GOOGLE_CLOUD_LOCATION"] = "us-central1"
os.environ["GOOGLE_APPLICATION_CREDENTIALS"]=".key.json"

project = os.getenv("PROJECT_ID", "o11y-movie-guru")
location = os.getenv("GOOGLE_CLOUD_LOCATION", "us-central1")
DB_HOST = os.getenv('PG_HOST', 'localhost')
DB_PORT = os.getenv('PG_PORT', '5432')
DB_NAME = os.getenv('PG_DB_NAME', 'london-db')
DB_USER = os.getenv('PG_USER', 'main')
MAX_NUM_ROWS = os.getenv('MAX_NUM_ROWS', 20)
DB_PASSWORD = os.getenv('PG_PASSWORD', 'main')
EMBEDDING_MODEL_NAME = "text-embedding-004"
EMBEDDING_DIMENSION = 768
DEBUG_STATE = os.getenv("DEBUG_STATE", "false").lower() in ('true', '1', 't', 'yes', 'y')

session_service = InMemorySessionService()

class AgentModel(BaseModel):
    """Agent model settings."""
    name: str = Field(default="london_holiday_agent")
    model: str = Field(default="gemini-2.0-flash-001")


class Config(BaseSettings):
    """Configuration settings for the london holiday agent."""

    model_config = SettingsConfigDict(
        env_file=os.path.join(
            os.path.dirname(os.path.abspath(__file__)), "../.env"
        ),
        case_sensitive=True,
        extra='ignore'  # Ignore extra fields from .env rather than erroring
    )
    db_host: str = DB_HOST
    db_port: str = DB_PORT
    db_name: str = DB_NAME
    db_user: str = DB_USER
    db_pwd: str = DB_PASSWORD
    embedding_model_name: str = EMBEDDING_MODEL_NAME
    max_rows: int = MAX_NUM_ROWS
    debug_state:bool = DEBUG_STATE
    project: str = project
    location:str = location
    app_name: str = "LYLA"
    agent_settings: AgentModel = Field(default_factory=AgentModel) 
    GENAI_USE_VERTEXAI: str = Field(default="1") 

# Instantiate Config to read .env for other settings
try:
    configs = Config()
except ValidationError as e:
    logger.error(
        f"Pydantic ValidationError loading configuration from .env in config.py. "
        f"Details: {e.errors()}"
    )
    configs = Config() # Initialize with defaults if .env loading fails
except Exception as e: # Catch other unexpected errors
    logger.error(f"Unexpected error loading configuration from .env in config.py: {e}")
    configs = Config() # Initialize with defaults if .env loading fails
