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
from google.adk.tools.mcp_tool import McpToolset, StreamableHTTPConnectionParams
from london_agent.auth import get_bearer_token

from london_agent.config import Config

logger = logging.getLogger(__name__)
configs = Config()

token = get_bearer_token(configs.data_backend_url)

search_mcp_server_url = f"{configs.data_backend_url}/mcp"
search_mcp_tool = McpToolset(
    connection_params=StreamableHTTPConnectionParams(url=search_mcp_server_url,
    headers={"Authorization": f"Bearer {token}"}),
    tool_filter = ["search_with_natural_language"],
)

