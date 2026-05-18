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
from google.adk.integrations.agent_registry import AgentRegistry
from london_agent.config import configs

logger = logging.getLogger(__name__)
mcp_tool = None

registry = AgentRegistry(
    project_id=configs.project_id,
    location=configs.location,
)

try:
    logger.info(f"Listing MCP Servers for project {configs.project_id} in location {configs.location}...")
    mcp_servers_response = registry.list_mcp_servers()
    for server in mcp_servers_response.get("mcpServers", []):
        logger.info(f"  - {server.get('name')} ({server.get('displayName')})")
except Exception as e:
    logger.error(f"Error listing MCP tools for project {configs.project_id}: {e}", exc_info=True)
    
mcp_server_name = f"projects/{configs.project_id}/locations/{configs.location}/mcpServers/{configs.london_data_mcp_server_name}"
logger.info(f"MCP server name: {mcp_server_name}")
try:
    mcp_tool = registry.get_mcp_toolset(mcp_server_name=mcp_server_name)
    logger.info(f"Successfully loaded MCP toolset for server {mcp_server_name}")
except Exception as e:
    logger.error(f"Error getting MCP toolset for server {mcp_server_name}: {e}", exc_info=True)
