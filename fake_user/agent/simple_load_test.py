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
from datetime import datetime
from google import genai
from agent.scenarios import get_random_prompt_vars, should_end_conversation
from agent.prompts import LOAD_TESTER_SYSTEM_PROMPT
import logging

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

genai_client = genai.Client()


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
    
    session_id = f"test_s_{int(datetime.now().timestamp())}_{random.randint(1000, 9999)}"
    agent_name = "london_agent"
    user_id = prompt_vars['name']
    
        
    create_session_endpoint = f"{base_url}/apps/{agent_name}/users/{user_id}/sessions/{session_id}"
    try:
        async with client.post(create_session_endpoint, json={}) as resp:
            if resp.status != 200:
                logger.error(f"Failed to create session: {resp.status}")
                return 0
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
        


async def main():
    logger.info(f"Starting load tester")
    logger.info(f"London Agent: {LONDON_AGENT_URL}")
    logger.info(f"Started at: {datetime.now().isoformat()}")
    logger.info("Press Ctrl+C to stop\n")
    
    total_conversations = 0
    total_turns = 0
    
    while True:
        try:
            async with aiohttp.ClientSession() as client:
                turns = await run_conversation(client, LONDON_AGENT_URL)
                time.sleep(1)
                total_conversations += 1
                total_turns += turns
                if total_conversations % 10 == 0:
                    logger.info(f"\n[{datetime.now().strftime('%H:%M:%S')}] Stats: {total_conversations} convs, {total_turns} turns\n")
                    
        except KeyboardInterrupt:
            break
        except Exception as e:
            logger.error(f"Conversation error: {e}")
            await asyncio.sleep(1)
    
    logger.info(f"\nFinal: {total_conversations} conversations, {total_turns} turns")


if __name__ == "__main__":
    asyncio.run(main())