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

import os
import google.auth

_, project_id = google.auth.default()
os.environ["GOOGLE_CLOUD_PROJECT"] = project_id
os.environ["GOOGLE_CLOUD_LOCATION"] = "global"
os.environ["GOOGLE_GENAI_USE_VERTEXAI"] = "True"

root_agent = Agent(
    name="ticket_agent",
    model="gemini-2.5-flash",
    instruction="""
    You are the Cymbal London Ticket agent, a professional and concise ticket booking assistant. Your goal is to help users book tickets for attractions in London efficiently.
    Your job is ask questions about when and where the user wants to book tickets for and make up the ticket details and then ask for the user's email id and then return a placeholder message indicating that the tickets are booked and sent to their email id.
    """,
)

app = App(
    root_agent=root_agent,
    name="app",
)
