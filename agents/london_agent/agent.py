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
from google.adk.apps import App
from google.genai import types
import google.auth
from london_agent.types import AgentOutput
from london_agent.tools import search_mcp_tool
from london_agent.config import configs
from google.adk.plugins.bigquery_agent_analytics_plugin import BigQueryAgentAnalyticsPlugin, BigQueryLoggerConfig
from google.adk.tools.bigquery import BigQueryToolset, BigQueryCredentialsConfig
from london_agent.model_armor_guard import create_model_armor_guard
from google.cloud import bigquery
import logging

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

APP_NAME=configs.app_name

_plugins = []
if configs.project :
    try:
        bq = bigquery.Client(project=configs.project)
        bq.create_dataset(f"{configs.project}.{configs.bq_dataset_id}", exists_ok=True)
        bq_config = BigQueryLoggerConfig(
            enabled=True,
            log_multi_modal_content=False,
            max_content_length=500 * 1024, # 500 KB limit for inline text
            batch_size=1, 
            shutdown_timeout=10.0
        )
        _plugins.append(
            BigQueryAgentAnalyticsPlugin(
                project_id=configs.project,
                dataset_id=configs.bq_dataset_id,
                location=configs.location,
                config=bq_config
            )
        )
    except Exception as e:
        logging.warning(f"Failed to initialize BigQuery Analytics: {e}")

model_armor_guard = create_model_armor_guard(
    project_id=configs.project,
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
    plugins=_plugins,
)
