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
import google.auth

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Google Cloud Configuration
PROJECT_ID= os.getenv("GOOGLE_CLOUD_PROJECT")
LOCATION=os.getenv("GOOGLE_CLOUD_LOCATION", "us-central1")

# Set the location for the Vertex AI client
# https://docs.cloud.google.com/stackdriver/docs/instrumentation/ai-agent-adk#configure
os.environ["GOOGLE_CLOUD_LOCATION"] = LOCATION
os.environ["GOOGLE_GENAI_USE_VERTEXAI"] = "true"
os.environ["OTEL_SERVICE_NAME"] = "cymbal-LONDON-concierge-agent"
os.environ["OTEL_PYTHON_LOGGING_AUTO_INSTRUMENTATION_ENABLED"] = "true"
os.environ["OTEL_INSTRUMENTATION_GENAI_CAPTURE_MESSAGE_CONTENT"] = "true"
os.environ["ADK_CAPTURE_MESSAGE_CONTENT_IN_SPANS"] = "false"

# Default values for the agent
LLM_MODEL_NAME = os.getenv("LLM_MODEL_NAME", 'gemini-2.5-flash')
DATASET_ID = os.environ.get("BIG_QUERY_DATASET_ID")
if DATASET_ID == "" or DATASET_ID is None:
    USE_BQ_ANALYTICS = False
    logger.info("BIG_QUERY_DATASET_ID is not set, disabling BQ Analytics")
else:
    USE_BQ_ANALYTICS = True
    logger.info(f"Using BQ Analytics with dataset ID: {DATASET_ID}")

MODEL_ARMOR_TEMPLATE_NAME = os.getenv("MODEL_ARMOR_TEMPLATE_NAME")

USE_MODEL_ARMOR = False
if MODEL_ARMOR_TEMPLATE_NAME == "" or MODEL_ARMOR_TEMPLATE_NAME is None:
    USE_MODEL_ARMOR = False
    logger.info("Not using Model Armor")
else:
    USE_MODEL_ARMOR = True
    logger.info(f"Using Model Armor with template: {MODEL_ARMOR_TEMPLATE_NAME}")


LOGS_BUCKET_NAME = os.getenv("LOGS_BUCKET_NAME")

AGENT_ENGINE_ID = os.getenv("AGENT_ENGINE_ID", "")
if "/" in AGENT_ENGINE_ID:
    AGENT_ENGINE_ID = AGENT_ENGINE_ID.split("/")[-1]
if AGENT_ENGINE_ID == "" or AGENT_ENGINE_ID is None:
    USE_AGENT_ENGINE = False
    logger.info("Not using Agent Engine")
else:
    USE_AGENT_ENGINE = True
    logger.info(f"Using Agent Engine with ID: {AGENT_ENGINE_ID}")

SESSION_SERVICE_URI = f"agentengine://{AGENT_ENGINE_ID}" if AGENT_ENGINE_ID else ""
MEMORY_SERVICE_URI = f"agentengine://{AGENT_ENGINE_ID}" if AGENT_ENGINE_ID else ""
REMOTE_TICKET_AGENT_URL = os.getenv("REMOTE_TICKET_AGENT_URL")

if REMOTE_TICKET_AGENT_URL == "" or REMOTE_TICKET_AGENT_URL is None:
    USE_REMOTE_TICKET_AGENT = False
    logger.info("Not using Remote Ticket Agent")
else:
    USE_REMOTE_TICKET_AGENT = True
    logger.info(f"Using Remote Ticket Agent at: {REMOTE_TICKET_AGENT_URL}")

if PROJECT_ID == "":
    _, PROJECT_ID = google.auth.default()

# Database Configuration
DATA_BACKEND_URL = os.environ.get("DATA_BACKEND_URL", "http://localhost:8002")

PORT = os.environ.get("PORT", 8080)

class AgentModel(BaseModel):
    """Agent model settings."""
    name: str = Field(default="london_holiday_agent")
    model: str = Field(default=LLM_MODEL_NAME)

class Config(BaseSettings):
    """Configuration settings for the london holiday agent."""
    project_id: str = PROJECT_ID
    location:str = LOCATION
    app_name: str = "Cymbal London Concierge"
    data_backend_url: str = DATA_BACKEND_URL
    agent_settings: AgentModel = Field(default_factory=AgentModel) 
    model_armor_template_name: str | None = Field(default=MODEL_ARMOR_TEMPLATE_NAME)
    use_model_armor: bool = Field(default=USE_MODEL_ARMOR)
    bq_dataset_id: str | None = Field(default=DATASET_ID)
    use_bq_analytics: bool = Field(default=USE_BQ_ANALYTICS)
    use_agent_engine: bool = Field(default=USE_AGENT_ENGINE)
    agent_engine_id: str | None = Field(default=AGENT_ENGINE_ID)
    logs_bucket_name: str | None = Field(default=LOGS_BUCKET_NAME)
    port: int = Field(default=PORT)
    session_service_uri: str | None = Field(default=SESSION_SERVICE_URI)
    memory_service_uri: str | None = Field(default=MEMORY_SERVICE_URI)
    remote_ticket_agent_url: str | None = Field(default=REMOTE_TICKET_AGENT_URL)
    use_remote_ticket_agent: bool = Field(default=USE_REMOTE_TICKET_AGENT)

try:
    configs = Config()
except ValidationError as e:
    logger.error(
        f"Pydantic ValidationError loading configuration in config.py. "
        f"Details: {e.errors()}"
    )
except Exception as e:
    logger.error(f"Unexpected error loading configuration in config.py: {e}")
