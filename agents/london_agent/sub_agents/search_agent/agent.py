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
from google.adk.agents.callback_context import CallbackContext
from google.genai import types
from london_agent.sub_agents.search_agent.tools import search_mcp_tool
from london_agent.sub_agents.search_agent.prompts import return_instructions_search
from london_agent.config import Config
from london_agent.sub_agents.search_agent.types import SearchResult

configs = Config()

search_agent = Agent(
    model=configs.agent_settings.model,
    name="search_agent",
    instruction=return_instructions_search(),
    tools=[
        search_mcp_tool
    ],
    output_schema = SearchResult,
    generate_content_config=types.GenerateContentConfig(temperature=0.01),
)