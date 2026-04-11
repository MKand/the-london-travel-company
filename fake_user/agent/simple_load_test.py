#!/usr/bin/env python3
"""
Simple load tester that runs in a loop, creating conversations with the London agent.
Uses ADK web API directly (no A2A).
"""

import asyncio
import random
import os
import json
import aiohttp
import time
from datetime import datetime, timedelta
import logging
from google import genai
from fastapi import FastAPI
import uvicorn
from agent.scenarios import get_random_prompt_vars, should_end_conversation
from agent.prompts import LOAD_TESTER_SYSTEM_PROMPT

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

genai_client = genai.Client(
    project=os.getenv("GOOGLE_CLOUD_PROJECT"),
    location=os.getenv("GOOGLE_CLOUD_LOCATION"),
    vertexai=True
)


LONDON_AGENT_URL = os.getenv("LONDON_AGENT_URL", "http://localhost:8001") # Using host port 8001 by default


async def run_conversation(client: aiohttp.ClientSession, base_url: str) -> int:
    prompt_vars = get_random_prompt_vars()
    
    scenario_str = (
        f"Profile:\n"
        f"- Name: {prompt_vars['name']}\n"
        f"- Days: {prompt_vars['days']}\n"
        f"- Group: {prompt_vars['travellers']}\n"
        f"- Interests: {prompt_vars['interest']}\n"
        f"- Mood: {prompt_vars['mood']}\n"
        f"- Current State: {prompt_vars['state']}\n"
    )
    
    conversation_history = []
    
    agent_name = "london_agent"
    user_id = prompt_vars['name']
    
    create_session_endpoint = f"{base_url}/apps/{agent_name}/users/{user_id}/sessions"
    try:
        async with client.post(create_session_endpoint, json={}) as resp:
            if resp.status != 200:
                logger.error(f"Failed to create session: {resp.status}")
                return 0
            resp_json = await resp.json()
            session_id = resp_json["id"]
    except Exception as e:
        logger.error(f"Error creating session: {e}")
        return 0

    turns = 0
    while True:
        # 1. Ask Simulation Agent what to say
        history_text = "\n".join(conversation_history)
        simulation_prompt = (
            LOAD_TESTER_SYSTEM_PROMPT.format(
                name=prompt_vars['name'],
                days=prompt_vars['days'],
                travellers=prompt_vars['travellers'],
                interest=prompt_vars['interest'],
                mood=prompt_vars['mood'],
                history=history_text
            )
        )
        
        try:
            logger.debug("\nRunning the agent...")
            response = genai_client.models.generate_content(
                model=os.getenv("LLM_MODEL_NAME", "gemini-2.5-flash"),
                contents=simulation_prompt
            )
            user_message_text = response.text
            logger.debug(user_message_text)

        except Exception as e:
            logger.error(f"Simulation Agent Error: {e}")
            break

        # 2. Send to London Agent
        run_endpoint = f"{base_url}/run"
        payload = {
            "appName": agent_name,
            "userId": user_id,
            "sessionId": session_id,
            "newMessage": {
                "role": "user",
                "parts": [{"text": user_message_text}]
            }
        }
        
        try:
            async with client.post(run_endpoint, json=payload) as resp:
                if resp.status != 200:
                    logger.error(f"Failed to run query: {resp.status}")
                    break
                
                london_resp_json = await resp.json()
                london_response_text = ""
                try:
                    # Try parsing standard ADK response structure
                    london_response_text = london_resp_json[-1]["content"]["parts"][0]["text"]
                except:
                    london_response_text = str(london_resp_json) # fallback
                    
        except Exception as e:
            logger.error(f"Error calling London Agent: {e}")
            break

        conversation_history.append(f"User: {user_message_text}")
        conversation_history.append(f"Concierge: {london_response_text}")
        turns += 1

        if should_end_conversation(london_response_text):
            logger.debug(f"Ending conversation after {turns} turns (random probability).")
            break

    return turns
        


class LoadTestStats:
    def __init__(self):
        self.events = [] # List of {"time": datetime, "type": str, "status": str, "turns": int}

    def track(self, event_type: str, status: str, turns: int = 0):
        self.events.append({
            "time": datetime.now(),
            "type": event_type,
            "status": status,
            "turns": turns
        })

    def get_summary(self, hours: int = 2):
        cutoff = datetime.now() - timedelta(hours=hours)
        filtered = [e for e in self.events if e["time"] > cutoff]
        
        successes = len([e for e in filtered if e["status"] == "success"])
        failures = len([e for e in filtered if e["status"] == "failure"])
        turns = sum([e["turns"] for e in filtered])
        
        return {
            "period_hours": hours,
            "conversations": len(filtered),
            "successes": successes,
            "failures": failures,
            "total_turns": turns
        }

stats = LoadTestStats()
simulation_task = None

app = FastAPI()

async def simulation_loop():
    logger.info(f"Starting load tester loop")
    while True:
        try:
            async with aiohttp.ClientSession() as client:
                turns = await run_conversation(client, LONDON_AGENT_URL)
                if turns > 0:
                    stats.track("conversation", "success", turns)
                else:
                    stats.track("conversation", "failure", 0)
                await asyncio.sleep(1)
        except Exception as e:
            logger.error(f"Conversation error: {e}")
            stats.track("conversation", "failure", 0)
            await asyncio.sleep(1)

@app.get("/")
async def root():
    return {"message": "Fake User Metadata Server running"}

@app.get("/status")
async def get_status():
    summary = stats.get_summary()
    is_running = simulation_task is not None and not simulation_task.done()
    return {
        "status": "running" if is_running else "stopped",
        "stats_last_2_hours": summary
    }

@app.post("/start")
async def start():
    global simulation_task
    if simulation_task and not simulation_task.done():
        return {"message": "Simulation already running"}
    simulation_task = asyncio.create_task(simulation_loop())
    logger.info("Simulation task started")
    return {"message": "Simulation started"}

@app.post("/stop")
async def stop():
    global simulation_task
    if simulation_task and not simulation_task.done():
        simulation_task.cancel()
        try:
            await simulation_task
        except asyncio.CancelledError:
            pass
        simulation_task = None
        logger.info("Simulation task stopped")
        return {"message": "Simulation stopped"}
    return {"message": "Simulation not running"}

if __name__ == "__main__":
    port = int(os.getenv("PORT", 8080))
    logger.info(f"Running FastAPI on port {port}")
    uvicorn.run(app, host="0.0.0.0", port=port)