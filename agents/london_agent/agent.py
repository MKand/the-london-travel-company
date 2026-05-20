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
import logging
import os
from london_agent.config import configs

from google.adk.agents import Agent
from google.adk.apps import App
from google.genai import types
from google.adk.tools import load_memory

import google.auth
from london_agent.types import AgentOutput
from london_agent.model_armor_guard import create_model_armor_guard
from london_agent.prompts import return_instructions_agent
from london_agent.tools import mcp_tool
import vertexai
from vertexai.preview.reasoning_engines import AdkApp

import logging

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


logger.info("GOOGLE_API_PREVENT_AGENT_TOKEN_SHARING_FOR_GCP_SERVICES is %s", os.environ.get("GOOGLE_API_PREVENT_AGENT_TOKEN_SHARING_FOR_GCP_SERVICES"))

vertexai.init(project=configs.project_id, location=configs.location)

if configs.use_model_armor:
    model_armor_guard = create_model_armor_guard()
    before_model_callback = model_armor_guard.before_model_callback
    after_model_callback = model_armor_guard.after_model_callback
else:
    before_model_callback = None
    after_model_callback = None

tools = []
if mcp_tool is not None:
    tools.append(mcp_tool)
    logger.info(f"Adding MCP toolset")
else:
    logger.info(f"Not adding MCP toolset")

# Initialize the agent outside the request handler for efficiency.
root_agent = Agent(
    model=configs.model,
    instruction=return_instructions_agent(),
    name=configs.agent_name,
    output_schema = AgentOutput,
    generate_content_config=types.GenerateContentConfig(temperature=0.01),
    tools=tools,
    before_model_callback=before_model_callback,
    after_model_callback=after_model_callback,
)

# --- Create the App ---
app = AdkApp(
    agent=root_agent,
    enable_tracing=True,
)


