# ruff: noqa
# Copyright 2026 Google LLC
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

import datetime
from zoneinfo import ZoneInfo

from google.adk.agents import Agent
from google.adk.apps import App
from google.adk.models import Gemini
from google.genai import types
from google.adk.tools.mcp_tool import McpToolset, StreamableHTTPConnectionParams

import os
import google.auth

_, project_id = google.auth.default()
os.environ["GOOGLE_CLOUD_PROJECT"] = project_id
os.environ["GOOGLE_CLOUD_LOCATION"] = "global"
os.environ["GOOGLE_GENAI_USE_VERTEXAI"] = "True"


def return_instructions_agent() -> str:

    LYLA_SYSTEM_PROMPT = """
    You are the Cymbal London Concierge, a professional and concise London travel planner. Your goal is to help users create a personalized itinerary efficiently.
    You are a travel agent tasked to understand the user's travel preferences.
    Always introduce yourself as Cymbal London Concierge if asked who you are.

    # **RESPONSE FORMATTING (CRITICAL):**
    - **BE CONCISE.** Provide brief, direct conversational answers. Avoid unnecessary pleasantries or filler.
    
     # **Workflow:**
    1. Briefly acknowledge the user's request in `text_response`.
    2. **Prioritize action:** If the user's request is broad, ask minimal clarifying questions (e.g., duration, interests) in `text_response`.
    3. Suggest a few options only if they seem unsure.
    4. **Crucially, use the `search_mcp_tool` tool as soon as you have basic criteria (days and interests) to search for activities and locations.**
    5. Present the list of activities.
    6. Briefly invite feedback for adjustments in `text_response`.
    7. If at any point the user's request is too vague to even ask the 2-3 initial questions, politely ask for more specific information in `text_response`.
    
    If the user wants to know more about a specific activity or location, pass this information along to the (`call_search_agent`), if necessary.
    """
    return LYLA_SYSTEM_PROMPT

search_mcp_server_url = "https://mcp-server-88ee-23134220601.us-central1.run.app/mcp"
search_mcp_tool = McpToolset(
    connection_params=StreamableHTTPConnectionParams(url=search_mcp_server_url),
    tool_filter = ["search_with_natural_language"],
)

root_agent = Agent(
    model="gemini-2.5-flash",
    instruction=return_instructions_agent(),
    name='london_travel_concierge',
    generate_content_config=types.GenerateContentConfig(temperature=0.01),
    tools=[search_mcp_tool],
)


app = App(
    root_agent=root_agent,
    name="app",
)
