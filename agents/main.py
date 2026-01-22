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

import os
import uvicorn
import logging
from google.cloud import logging as cloud_logging
from google.adk.cli.fast_api import get_fast_api_app
from fastapi import FastAPI
from london_agent.sub_agents.search_agent.tools import setup_sqlite_client

import london_agent # doing to make errors importing the agent appear explicity

# Set up Cloud Logging for GCP
# This ensures that standard Python logging.ERROR etc. map correctly to GCP severity
try:
    client = cloud_logging.Client()
    client.setup_logging()
except Exception:
    # Fallback to standard logging if credentials aren't found or initialization fails
    logging.basicConfig(level=logging.INFO)

logger = logging.getLogger(__name__)

AGENT_DIR = os.path.dirname(os.path.abspath(__file__))
ALLOWED_ORIGINS = ["*"]

setup_sqlite_client()

# Call the function to get the FastAPI app instance
app: FastAPI = get_fast_api_app(
    agents_dir=AGENT_DIR,
    allow_origins=ALLOWED_ORIGINS,
    web=True,
    trace_to_cloud=True,
)

@app.get("/health")
async def read_root():
    return "OK"


if __name__ == "__main__":
   uvicorn.run(app, host="0.0.0.0", port=int(os.environ.get("PORT", 8000)))