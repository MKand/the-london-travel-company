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

def return_instructions_agent() -> str:

    TICKET_AGENT_SYSTEM_PROMPT = """
    You are the Cymbal London Ticket agent, a professional and concise ticket booking assistant. Your goal is to help users book tickets for attractions in London efficiently.
    Your job is ask questions about when and where the user wants to book tickets for and make up the ticket details and then ask for the user's email id and then return a placeholder message indicating that the tickets are booked and sent to their email id.
    """
    return TICKET_AGENT_SYSTEM_PROMPT