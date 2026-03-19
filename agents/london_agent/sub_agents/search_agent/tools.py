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

"""This file contains the tools used by the database agent."""

import logging
import json
import asyncio
from typing import Any, Dict, List, Optional
from pydantic import BaseModel
from mcp import ClientSession
from mcp.client.sse import sse_client
from google.adk.tools import ToolContext
from london_agent.config import Config

logger = logging.getLogger(__name__)
configs = Config()

class activity(BaseModel):
    """Activity model for type consistency."""
    activity_id: str
    name: str
    description: Optional[str] = None
    cost: Optional[float] = None
    duration_min: Optional[int] = None
    duration_max: Optional[int] = None
    kid_friendliness_score: Optional[int] = None

class ActivitiesSearchOutput(BaseModel):
    """Container for search results."""
    activities_list: Optional[List[activity]] = None
    error_message: str = ""

def write_to_tool_context(key: str, value: Any, tool_context: ToolContext):
    """Helper to write to tool context if available."""
    if tool_context and hasattr(tool_context, "state"):
        tool_context.state[key] = value

async def mcp_call(tool_name: str, arguments: dict) -> str:
    """Generic helper to call the data-backend MCP server."""
    mcp_endpoint = f"{configs.data_backend_url}/mcp/sse"
    try:
        async with sse_client(mcp_endpoint) as (read, write):
            async with ClientSession(read, write) as session:
                await session.initialize()
                result = await session.call_tool(tool_name, arguments=arguments)
                
                if result.isError:
                    error_msg = f"MCP Error: {result.content}"
                    logger.error(error_msg)
                    return json.dumps({"error": error_msg})
                
                # Extract text content
                results_text = ""
                for content in result.content:
                    if hasattr(content, "text"):
                        results_text += content.text
                return results_text
    except Exception as e:
        logger.error(f"Failed to call MCP {tool_name}: {e}")
        return json.dumps({"error": str(e)})

async def search_locations_tool(
    query: str,
    tool_context: ToolContext = None,
) -> str:
    """
    Search for attractions/locations in London using semantic search.
    Args:
        query: Natural language query about attractions (e.g., 'royal palaces')
    """
    write_to_tool_context("search_locations_tool_input", query, tool_context)
    results = await mcp_call("enriched_search", {"query": query, "type": "locations"})
    write_to_tool_context("search_locations_tool_output", results, tool_context)
    return results

async def get_activities_tool(
    query: str,
    tool_context: ToolContext = None,
) -> str:
    """
    Search for specific activities in London (tours, events, etc) using semantic search.
    Args:
        query: Natural language query about activities (e.g., 'family friendly workshops' or 'evening tours')
    """
    write_to_tool_context("get_activities_tool_input", query, tool_context)
    results = await mcp_call("enriched_search", {"query": query, "type": "activities"})
    write_to_tool_context("get_activities_tool_output", results, tool_context)
    return results

async def search_attractions_tool(
    query: str,
    tool_context: ToolContext = None,
) -> str:
    """
    Unified search for both locations and activities in London.
    Args:
        query: General query about things to do in London.
    """
    write_to_tool_context("search_attractions_tool_input", query, tool_context)
    results = await mcp_call("enriched_search", {"query": query, "type": "all"})
    write_to_tool_context("search_attractions_tool_output", results, tool_context)
    return results

# Legacy wrapper to avoid breaking other imports if any, but cleaned up
def get_database_settings():
    """Mock for legacy setup calls."""
    return {}
