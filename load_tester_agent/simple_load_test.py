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
from datetime import datetime

from load_tester_agent.scenarios import (
    generate_test_request,
    get_random_mood,
)


LONDON_AGENT_URL = os.getenv("LONDON_AGENT_URL", "http://localhost:8000")
END_SIGNALS = [
    "thanks", "thank you", "bye", "goodbye", "that's all", "done", "finished",
    "ok thanks", "great thanks", "perfect", "helpful", "that's helpful",
]


def should_end_conversation(response_text: str) -> bool:
    response_lower = response_text.lower()
    for signal in END_SIGNALS:
        if signal in response_lower:
            return True
    return False


async def create_session(session: aiohttp.ClientSession, agent_url: str, session_id: str) -> bool:
    try:
        async with session.post(
            f"{agent_url}/sessions",
            json={"session_id": session_id},
            timeout=aiohttp.ClientTimeout(total=30)
        ) as resp:
            return resp.status in (200, 201)
    except Exception:
        return False


async def send_message(session: aiohttp.ClientSession, agent_url: str, session_id: str, message: str) -> str:
    try:
        async with session.post(
            f"{agent_url}/runs",
            json={
                "user_id": session_id,
                "session_id": session_id,
                "user_message": message,
            },
            timeout=aiohttp.ClientTimeout(total=120)
        ) as resp:
            if resp.status == 200:
                data = await resp.json()
                text_response = ""
                if "content" in data:
                    for part in data.get("content", []):
                        if part.get("part", {}).get("text"):
                            text_response += part["part"]["text"]
                elif "text" in data:
                    text_response = data["text"]
                return text_response
            return ""
    except Exception as e:
        print(f"  ERROR sending message: {e}")
        return ""


async def close_session(session: aiohttp.ClientSession, agent_url: str, session_id: str):
    try:
        await session.delete(
            f"{agent_url}/sessions/{session_id}",
            timeout=aiohttp.ClientTimeout(total=10)
        )
    except:
        pass


async def run_conversation(session: aiohttp.ClientSession, agent_url: str):
    mood = get_random_mood()
    session_id = f"load_test_{random.randint(10000, 99999)}"
    
    if not await create_session(session, agent_url, session_id):
        print(f"  Failed to create session {session_id}")
        return 0
    
    initial_request = generate_test_request()
    print(f"[{datetime.now().strftime('%H:%M:%S')}] Session {session_id} | Mood: {mood['name']}")
    print(f"  -> {initial_request[:60]}...")
    
    messages = [initial_request]
    turn_count = 0
    end_turn_count = random.randint(1,10)
    while end_turn_count:
        turn_count += 1
        try:
            response_text = await send_message(session, agent_url, session_id, messages[-1])
            if not response_text:
                break
            print(f"  <- {response_text[:100]}...")
            
            if should_end_conversation(response_text) or turn_count >= 5:
                break
            
            follow_ups = [
                "What about transport?",
                "Are there kid-friendly options?",
                "How much time should I allow?",
                "What's nearby to visit?",
                "Can you add more details?",
            ]
            user_input = random.choice(follow_ups)
            print(f"  -> {user_input}")
            messages.append(user_input)
            
        except Exception as e:
            print(f"  ERROR: {e}")
            break
    
    await close_session(session, agent_url, session_id)
    return turn_count


async def main():
    print(f"Starting load tester")
    print(f"London Agent: {LONDON_AGENT_URL}")
    print(f"Started at: {datetime.now().isoformat()}")
    print("Press Ctrl+C to stop\n")
    
    total_conversations = 0
    total_turns = 0
    
    while True:
        try:
            async with aiohttp.ClientSession() as client:
                turns = await run_conversation(client, LONDON_AGENT_URL)
                total_conversations += 1
                total_turns += turns
                
                if total_conversations % 10 == 0:
                    print(f"\n[{datetime.now().strftime('%H:%M:%S')}] Stats: {total_conversations} convs, {total_turns} turns\n")
                    
        except KeyboardInterrupt:
            break
        except Exception as e:
            print(f"Conversation error: {e}")
            await asyncio.sleep(1)
    
    print(f"\nFinal: {total_conversations} conversations, {total_turns} turns")


if __name__ == "__main__":
    asyncio.run(main())