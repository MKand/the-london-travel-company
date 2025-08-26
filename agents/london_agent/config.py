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
from pydantic_settings import BaseSettings
from pydantic import BaseModel, Field, ValidationError
from google.adk.sessions import InMemorySessionService

logging.basicConfig(level=logging.DEBUG)
logger = logging.getLogger(__name__)

os.environ["GOOGLE_GENAI_USE_VERTEXAI"] = "TRUE"
os.environ["GOOGLE_CLOUD_PROJECT"] = os.getenv("GOOGLE_CLOUD_PROJECT","o11y-movie-guru")
os.environ["GOOGLE_CLOUD_LOCATION"] = os.getenv("GOOGLE_CLOUD_LOCATION", "us-central1")

DB_NAME = os.getenv('DB_NAME', 'london')
MAX_NUM_ROWS = os.getenv('MAX_NUM_ROWS', 20)
embedding_model_name = os.getenv("EMBEDDING_MODEL_NAME", 'text-embedding-005')
EMBEDDING_DIMENSION = 768
DEBUG_STATE = os.getenv("DEBUG_STATE", "false").lower() in ('true', '1', 't', 'yes', 'y')

session_service = InMemorySessionService()

class AgentModel(BaseModel):
    """Agent model settings."""
    name: str = Field(default="london_holiday_agent")
    model: str = Field(default="gemini-2.0-flash-001")


class Config(BaseSettings):
    """Configuration settings for the london holiday agent."""

    db_name: str = DB_NAME
    embedding_model_name: str = embedding_model_name
    max_rows: int = MAX_NUM_ROWS
    debug_state:bool = DEBUG_STATE
    project: str = os.getenv("GOOGLE_CLOUD_PROJECT","o11y-movie-guru")
    location:str = os.getenv("GOOGLE_CLOUD_LOCATION", "us-central1")
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
