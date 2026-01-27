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
import uvicorn
import logging
from google.cloud import logging as cloud_logging
from google.adk.cli.fast_api import get_fast_api_app
from fastapi import FastAPI
from london_agent.sub_agents.search_agent.tools import setup_sqlite_client
from opentelemetry.instrumentation.httpx import HTTPXClientInstrumentor
from opentelemetry.instrumentation.fastapi import FastAPIInstrumentor

import london_agent # doing to make errors importing the agent appear explicity

# Set up Cloud Logging for GCP
# This ensures that standard Python logging.ERROR etc. map correctly to GCP severity
try:
    client = cloud_logging.Client()
    client.setup_logging()
except Exception:
    # Fallback to standard logging if credentials aren't found or initialization fails
    logging.basicConfig(level=logging.INFO)

logger = logging.getLogger(__name__)

# OTEL Configuration
OTEL_SERVICE_NAME = os.getenv("OTEL_SERVICE_NAME", "london-travel-agent")
OTEL_EXPORTER_OTLP_ENDPOINT = os.getenv("OTEL_EXPORTER_OTLP_ENDPOINT", "https://telemetry.googleapis.com")
OTEL_INSTRUMENTATION_GENAI_CAPTURE_MESSAGE_CONTENT = os.getenv("OTEL_INSTRUMENTATION_GENAI_CAPTURE_MESSAGE_CONTENT", "true").lower() in ('true', '1', 't', 'yes', 'y')
ADK_CAPTURE_MESSAGE_CONTENT_IN_SPANS=os.getenv("ADK_CAPTURE_MESSAGE_CONTENT_IN_SPANS", "false").lower() in ('true', '1', 't', 'yes', 'y')
OTEL_PYTHON_LOGGING_AUTO_INSTRUMENTATION_ENABLED=os.getenv("OTEL_PYTHON_LOGGING_AUTO_INSTRUMENTATION_ENABLED", "true").lower() in ('true', '1', 't', 'yes', 'y')
OTEL_INSTRUMENTATION_GENAI_CAPTURE_MESSAGE_CONTENT=os.getenv("OTEL_INSTRUMENTATION_GENAI_CAPTURE_MESSAGE_CONTENT", "false").lower() in ('true', '1', 't', 'yes', 'y')

os.environ["OTEL_SERVICE_NAME"] = OTEL_SERVICE_NAME
os.environ["OTEL_EXPORTER_OTLP_ENDPOINT"] = OTEL_EXPORTER_OTLP_ENDPOINT
os.environ["OTEL_INSTRUMENTATION_GENAI_CAPTURE_MESSAGE_CONTENT"] = str(OTEL_INSTRUMENTATION_GENAI_CAPTURE_MESSAGE_CONTENT)
os.environ["ADK_CAPTURE_MESSAGE_CONTENT_IN_SPANS"] = str(ADK_CAPTURE_MESSAGE_CONTENT_IN_SPANS)
os.environ["OTEL_PYTHON_LOGGING_AUTO_INSTRUMENTATION_ENABLED"] = str(OTEL_PYTHON_LOGGING_AUTO_INSTRUMENTATION_ENABLED)

AGENT_DIR = os.path.dirname(os.path.abspath(__file__))
ALLOWED_ORIGINS = ["*"]

setup_sqlite_client()

# Call the function to get the FastAPI app instance
app: FastAPI = get_fast_api_app(
    agents_dir=AGENT_DIR,
    allow_origins=ALLOWED_ORIGINS,
    web=True,
    trace_to_cloud=False,
    otel_to_cloud=True,
)

HTTPXClientInstrumentor().instrument()
FastAPIInstrumentor.instrument_app(app)


@app.get("/health")
async def read_root():
    return "OK"


if __name__ == "__main__":
   uvicorn.run(app, host="0.0.0.0", port=int(os.environ.get("PORT", 8000)))