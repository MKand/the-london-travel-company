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
from google.adk.tools import load_memory
from google.adk.tools.agent_tool import AgentTool
from google.adk.agents.remote_a2a_agent import AGENT_CARD_WELL_KNOWN_PATH, RemoteA2aAgent
from google.adk.plugins.bigquery_agent_analytics_plugin import BigQueryAgentAnalyticsPlugin, BigQueryLoggerConfig
from google.cloud import bigquery

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

if configs.use_model_armor:
    model_armor_guard = create_model_armor_guard()
    before_model_callback = model_armor_guard.before_model_callback
    after_model_callback = model_armor_guard.after_model_callback
else:
    before_model_callback = None
    after_model_callback = None

if configs.use_remote_ticket_agent:
    ticket_agent_remote = RemoteA2aAgent(
        name="ticket_agent_remote",
        description="Agent that books tickets for activities in London",
        agent_card=f"{configs.remote_ticket_agent_url}{AGENT_CARD_WELL_KNOWN_PATH}",
    )
    tools = [search_mcp_tool, load_memory, AgentTool(ticket_agent_remote)]
else:
    tools = [search_mcp_tool, load_memory]



# Initialize the agent outside the request handler for efficiency.
root_agent = Agent(
    model=configs.agent_settings.model,
    instruction=return_instructions_agent(),
    name=configs.agent_settings.name,
    output_schema = AgentOutput,
    generate_content_config=types.GenerateContentConfig(temperature=0.01),
    tools=tools,
    before_model_callback=before_model_callback,
    after_model_callback=after_model_callback,
)


plugins = []
if configs.use_bq_analytics:
    try:
        bq = bigquery.Client(project=configs.project_id)
        bq.create_dataset(f"{configs.project_id}.{configs.bq_dataset_id}", exists_ok=True)
        bq_config = BigQueryLoggerConfig(
            enabled=True,
            log_multi_modal_content=False,
            max_content_length=500 * 1024, # 500 KB limit for inline text
            batch_size=1, 
            shutdown_timeout=10.0
        )
        bq_analytics_plugin = BigQueryAgentAnalyticsPlugin(
            project_id=configs.project_id,
            dataset_id=configs.bq_dataset_id,
            location="US",
            config=bq_config
        )
        plugins.append(bq_analytics_plugin)
    except Exception as e:
        logging.warning(f"Failed to initialize BigQuery Analytics: {e}")

logger.info(f"ADK plugins being initialized: {plugins}")
  

# --- Create the App ---
app = App(
    name="london_agent",
    root_agent=root_agent,
    plugins=plugins,
)


