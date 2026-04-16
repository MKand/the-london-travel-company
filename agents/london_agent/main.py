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
from london_agent.config import configs
from google.adk.cli.fast_api import get_fast_api_app
from fastapi import FastAPI
from opentelemetry.instrumentation.httpx import HTTPXClientInstrumentor
from opentelemetry.instrumentation.fastapi import FastAPIInstrumentor
from a2a.server.apps import A2AFastAPIApplication
from a2a.server.request_handlers import DefaultRequestHandler
from a2a.server.tasks import InMemoryTaskStore
from a2a.types import AgentCapabilities, AgentCard
from google.adk.a2a.executor.a2a_agent_executor import A2aAgentExecutor
from google.adk.a2a.utils.agent_card_builder import AgentCardBuilder
from contextlib import asynccontextmanager
from collections.abc import AsyncIterator

from a2a.utils.constants import (
    AGENT_CARD_WELL_KNOWN_PATH,
    EXTENDED_AGENT_CARD_PATH,
)
from google.adk.artifacts import GcsArtifactService, InMemoryArtifactService
from google.adk.runners import Runner
from google.adk.sessions import VertexAiSessionService, InMemorySessionService
from google.adk.memory import VertexAiMemoryBankService, InMemoryMemoryService
from london_agent.utils import setup_logging, setup_telemetry
from london_agent.config import Config

configs = Config()

AGENT_DIR = os.path.dirname(os.path.abspath(__file__))
ALLOWED_ORIGINS = ["*"]

setup_logging()

# Artifact bucket for ADK (created by Terraform, passed via env var)
artifact_service = (
    GcsArtifactService(bucket_name=configs.logs_bucket_name)
    if configs.logs_bucket_name
    else InMemoryArtifactService()
)

if configs.use_agent_engine:
    session_service = VertexAiSessionService(project=configs.project_id, location=configs.location, agent_engine_id=configs.agent_engine_id)
    memory_service = VertexAiMemoryBankService(project=configs.project_id, location=configs.location, agent_engine_id=configs.agent_engine_id)
else:
    session_service = InMemorySessionService()
    memory_service = InMemoryMemoryService()

# Call the function to get the FastAPI app instance
app: FastAPI = get_fast_api_app(
    agents_dir=os.path.dirname(AGENT_DIR),
    allow_origins=ALLOWED_ORIGINS,
    memory_service_uri=configs.memory_service_uri,
    otel_to_cloud=True,
    web=True
)

HTTPXClientInstrumentor().instrument()
FastAPIInstrumentor.instrument_app(app)


@app.get("/health")
async def health_check():
    return "OK"


if __name__ == "__main__":
   uvicorn.run(app, host="0.0.0.0", port=int(configs.port))