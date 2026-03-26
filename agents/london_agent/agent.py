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

from london_agent.prompts import return_instructions_agent
from google.adk.agents import Agent
from google.genai import types
from london_agent.types import AgentOutput
from london_agent.tools import search_mcp_tool
from london_agent.config import configs

APP_NAME=configs.app_name

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
)

