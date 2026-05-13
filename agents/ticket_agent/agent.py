import os
import google.auth
from google.adk.agents import Agent
from vertexai.preview.reasoning_engines import AdkApp

_, project_id = google.auth.default()
os.environ["GOOGLE_CLOUD_PROJECT"] = project_id
os.environ["GOOGLE_CLOUD_LOCATION"] = "us-central1"

vertexai.init(project=project_id, location="us-central1")
os.environ["GOOGLE_CLOUD_AGENT_ENGINE_ENABLE_TELEMETRY"] = "true"
os.environ["OTEL_INSTRUMENTATION_GENAI_CAPTURE_MESSAGE_CONTENT"] = "true"
os.environ["GOOGLE_GENAI_USE_VERTEXAI"] = "True"

root_agent = Agent(
    name="ticket_agent",
    model="gemini-2.5-flash",
    instruction="""
    You are the Cymbal London Ticket agent, a professional and concise ticket booking assistant. Your goal is to help users book tickets for attractions in London efficiently.
    Your job is ask questions about when and where the user wants to book tickets for and make up the ticket details and then ask for the user's email id and then return a placeholder message indicating that the tickets are booked and sent to their email id.
    """,
)

app = AdkApp(
    agent=root_agent,
    enable_tracing=True,
)
