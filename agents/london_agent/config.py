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
if os.getenv("GOOGLE_CLOUD_PROJECT") == "" or os.getenv("GOOGLE_CLOUD_PROJECT") is None:
    _, project_id = google.auth.default()
    os.environ["GOOGLE_CLOUD_PROJECT"] = project_id
PROJECT_ID = os.getenv("GOOGLE_CLOUD_PROJECT")

LOCATION = os.getenv("GOOGLE_CLOUD_LOCATION", "us-central1")

# Set the location for the Vertex AI client
# https://docs.cloud.google.com/stackdriver/docs/instrumentation/ai-agent-adk#configure
os.environ["GOOGLE_CLOUD_AGENT_ENGINE_ENABLE_TELEMETRY"] = "true"
os.environ["OTEL_INSTRUMENTATION_GENAI_CAPTURE_MESSAGE_CONTENT"] = "true"
os.environ["OTEL_PYTHON_LOGGING_AUTO_INSTRUMENTATION_ENABLED"] = "true"
os.environ["ADK_CAPTURE_MESSAGE_CONTENT_IN_SPANS"] = "true"
os.environ["OTEL_SERVICE_NAME"] = "cymbal-london-concierge-agent"
os.environ["GOOGLE_API_PREVENT_AGENT_TOKEN_SHARING_FOR_GCP_SERVICES"] = "false"
os.environ["GOOGLE_GENAI_USE_VERTEXAI"] = "True"

# Default values for the agent
LLM_MODEL_NAME = os.getenv("LLM_MODEL_NAME", 'gemini-2.5-flash')

MODEL_ARMOR_TEMPLATE_NAME = os.getenv("MODEL_ARMOR_TEMPLATE_NAME")

USE_MODEL_ARMOR = False
if MODEL_ARMOR_TEMPLATE_NAME == "" or MODEL_ARMOR_TEMPLATE_NAME is None:
    USE_MODEL_ARMOR = False
    logger.info("Not using Model Armor")
else:
    USE_MODEL_ARMOR = True
    logger.info(f"Using Model Armor with template: {MODEL_ARMOR_TEMPLATE_NAME}")


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
LONDON_DATA_MCP_SERVER_NAME = os.environ.get("LONDON_DATA_MCP_SERVER_NAME", "agentregistry-00000000-0000-0000-c480-d4fa4f98aead")

class Config(BaseSettings):
    """Configuration settings ."""
    agent_name: str = Field(default="london_holiday_agent")
    model: str = Field(default=LLM_MODEL_NAME)
    project_id: str = PROJECT_ID
    location:str = LOCATION
    london_data_mcp_server_name: str = LONDON_DATA_MCP_SERVER_NAME
    model_armor_template_name: str | None = Field(default=MODEL_ARMOR_TEMPLATE_NAME)
    use_model_armor: bool = Field(default=USE_MODEL_ARMOR)
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
