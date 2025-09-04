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

from .config import Config
from .prompts import return_instructions_lyla
from google.adk.agents import Agent
from google.adk.agents.callback_context import CallbackContext
from .sub_agents.search_agent.tools import (
    get_database_settings,
)
from .tools.tools import call_db_agent
from google.genai import types

APP_NAME="LYLA"
configs = Config()

def setup_before_agent_call(callback_context: CallbackContext):
    """Setup the agent."""
    db_settings = dict()
    db_settings["use_database"] = "SQLite"
    callback_context.state["all_db_settings"] = db_settings
    # setting up schema in instruction
    if callback_context.state["all_db_settings"]["use_database"] == "SQLite":
        callback_context.state["database_settings"] = get_database_settings()
        schema = callback_context.state["database_settings"]["sqlite_ddl_schema"]

        callback_context._invocation_context.agent.instruction = (
            return_instructions_lyla()
            + f"""

    --------- The sqlite schema of the relevant data with a few sample rows. ---------
    {schema}

    """
)
# Initialize the agent outside the request handler for efficiency.
root_agent = Agent(
    model=configs.agent_settings.model,
    instruction=return_instructions_lyla(),
    name=configs.agent_settings.name,
    tools=[
        call_db_agent,
    ],
    before_agent_callback=setup_before_agent_call,
    generate_content_config=types.GenerateContentConfig(temperature=0.01),
)

