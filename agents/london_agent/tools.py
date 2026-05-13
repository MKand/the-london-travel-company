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
from london_agent.auth import get_bearer_token
from google.adk.integrations.agent_registry import AgentRegistry

from london_agent.config import Config

logger = logging.getLogger(__name__)
configs = Config()

registry = AgentRegistry(
    project_id=configs.project_id,
    location=configs.location,
)

mcp_server_name = f"projects/{configs.project_id}/locations/{configs.location}/mcpServers/{configs.london_data_mcp_server_name}"

try:
    mcp_tool = registry.get_mcp_toolset(mcp_server_name=mcp_server_name)
except Exception as e:
    logger.error(f"Error getting MCP toolset for server {mcp_server_name}: {e}", exc_info=True)
    raise RuntimeError(f"Failed to load MCP toolset from {mcp_server_name}. Ensure the server exists and is accessible.") from e