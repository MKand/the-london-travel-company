from fastapi import FastAPI, HTTPException
from pydantic import BaseModel, Field
from google.adk.runners import Runner
from google.genai import types 
from .config import session_service
from .agent import root_agent, configs, setup_before_agent_call

import uuid

APP_NAME="LYLA"

app = FastAPI(
    title="Lyla - ADK-Powered Travel Planner",
    description="API for the Lyla AI travel agent using Google's ADK.",
    version="1.0.0"
)

class ChatRequest(BaseModel):
    latest_message: str
    session_id: str = Field(..., description="Unique session ID")
    user_id: str = Field(default=None, description="Unique user ID")

@app.post("/chat")
async def chat_with_lyla(chat_request: ChatRequest):
    """
    This endpoint now uses the ADK's Agent to handle the conversation.
    The complex orchestration loop is now handled cleanly by the ADK.
    """
    try:
        user_id=str(chat_request.user_id)
        content = types.Content(role='user', parts=[types.Part(text=chat_request.latest_message)])

        # Convert the incoming message history to the ADK's Message format.
        if not chat_request.session_id:
            session_id = "abc" # str(uuid.uuid4())
            await session_service.create_session(
            app_name=APP_NAME,
            session_id=session_id,
            user_id=user_id
            )
            print(f"New Session Created: {session_id}")
        else:
            session_id = chat_request.session_id
        
        final_response_text = "Agent did not produce a final response." # Default

        # Use the ADK Runner to execute the agent.
        runner = Runner(agent=root_agent, session_service=session_service, app_name=APP_NAME)
        async for event in runner.run_async(user_id=user_id, session_id=session_id, new_message=content):
            print(f"[Event] Author: {event.author}, Type: {type(event).__name__}, Final: {event.is_final_response()}, Content: {event.content}")

            if event.is_final_response():
                if event.content and event.content.parts:
                    # Assuming text response in the first part
                    final_response_text = event.content.parts[0].text
                elif event.actions and event.actions.escalate: # Handle potential errors/escalations
                    final_response_text = f"Agent escalated: {event.error_message or 'No specific message.'}"
                
                break 
        
        return {"type": "text", "content": final_response_text, "session_id": session_id}

    except Exception as e:
        print(f"An error occurred: {e}")
        raise HTTPException(status_code=500, detail="Internal Server Error")        


async def main():
    chat_request = ChatRequest(
    user_id="manasa",
    session_id="",
    latest_message="I'm in a hurry. I will be in london for 4 days, plan some activities. I want to do fun things."
    )   
    response = await chat_with_lyla(chat_request)
    print(response)
    return response

if __name__ == "__main__":
    import asyncio
    root_agent
    asyncio.run(main())