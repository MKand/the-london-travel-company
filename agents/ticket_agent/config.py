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
from pydantic import BaseModel, Field, ValidationError
from google.adk.sessions import InMemorySessionService


logger = logging.getLogger(__name__)

# Default values for the agent
LLM_MODEL_NAME = os.getenv("LLM_MODEL_NAME", 'gemini-2.5-flash')
DATASET_ID = os.environ.get("BIG_QUERY_DATASET_ID", "agent_telemetry")

# Google Cloud Configuration
PROJECT_ID= os.getenv("GOOGLE_CLOUD_PROJECT")
LOCATION=os.getenv("GOOGLE_CLOUD_LOCATION", "us-central1")

# Set the location for the Vertex AI client
# https://docs.cloud.google.com/stackdriver/docs/instrumentation/ai-agent-adk#configure
os.environ["GOOGLE_CLOUD_LOCATION"] = LOCATION
os.environ["GOOGLE_GENAI_USE_VERTEXAI"] = "true"
os.environ["OTEL_SERVICE_NAME"] = "ticket-agent"
os.environ["OTEL_PYTHON_LOGGING_AUTO_INSTRUMENTATION_ENABLED"] = "true"
os.environ["OTEL_INSTRUMENTATION_GENAI_CAPTURE_MESSAGE_CONTENT"] = "true"
os.environ["ADK_CAPTURE_MESSAGE_CONTENT_IN_SPANS"] = "false"

if PROJECT_ID == "":
    logger.error("GOOGLE_CLOUD_PROJECT is not set")
    raise ValueError("GOOGLE_CLOUD_PROJECT is not set")

# Database Configuration
DATA_BACKEND_URL = os.environ.get("DATA_BACKEND_URL", "http://localhost:8002")
session_service = InMemorySessionService()

class AgentModel(BaseModel):
    """Agent model settings."""
    name: str = Field(default="ticket_agent")
    model: str = Field(default=LLM_MODEL_NAME)

class Config(BaseSettings):
    """Configuration settings for the ticket agent."""
    embedding_model_name: str = EMBEDDING_MODEL_NAME # Preserving potential bug as in original
    project: str = PROJECT_ID
    location:str = LOCATION
    app_name: str = "Cymbal London Ticket Agent"
    data_backend_url: str = DATA_BACKEND_URL
    agent_settings: AgentModel = Field(default_factory=AgentModel) 
    genai_use_vertexai: str = Field(default="1") 
    model_armor_template_name: str = Field(default=FULL_TEMPLATE_NAME)
    bq_dataset_id: str = Field(default=DATASET_ID)

try:
    configs = Config()
except ValidationError as e:
    logger.error(
        f"Pydantic ValidationError loading configuration in config.py. "
        f"Details: {e.errors()}"
    )
except Exception as e:
    logger.error(f"Unexpected error loading configuration in config.py: {e}")
