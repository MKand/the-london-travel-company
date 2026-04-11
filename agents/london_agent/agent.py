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

from google.adk.agents import Agent
from google.adk.apps import App
from google.genai import types
import google.auth
from london_agent.types import AgentOutput
from london_agent.tools import search_mcp_tool
from london_agent.config import configs
from london_agent.model_armor_guard import create_model_armor_guard
from london_agent.prompts import return_instructions_agent

import logging

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

APP_NAME=configs.app_name

model_armor_guard = create_model_armor_guard(
    project_id=configs.project_id,
    template_name=configs.model_armor_template_name,
    location=configs.location
)

# Initialize the agent outside the request handler for efficiency.
root_agent = Agent(
    model=configs.agent_settings.model,
    instruction=return_instructions_agent(),
    name=configs.agent_settings.name,
    output_schema = AgentOutput,
    generate_content_config=types.GenerateContentConfig(temperature=0.01),
    tools=[
        search_mcp_tool
    ],
    before_model_callback=model_armor_guard.before_model_callback,
    after_model_callback=model_armor_guard.after_model_callback,
)
# --- Create the App ---
app = App(
    name="london_agent",
    root_agent=root_agent,
)
