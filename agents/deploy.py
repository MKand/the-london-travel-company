from vertexai.preview import reasoning_engines
from vertexai import agent_engines
from london_agent.agent import root_agent
import os
import vertexai

# Deploy for sqlite version

PROJECT_ID = os.getenv("PROJECT_ID")
LOCATION = os.getenv("LOCATION")
STAGING_BUCKET = os.getenv("STAGING_BUCKET")

vertexai.init(
    project=PROJECT_ID,
    location=LOCATION,
    staging_bucket=STAGING_BUCKET,
)

adk_app = reasoning_engines.AdkApp(
    agent=root_agent,
    enable_tracing=True,
)

print(os.getcwd())
try:
    remote_agent = agent_engines.AgentEngine.create(
        agent_engine=root_agent,                                
        requirements="./requirements.txt",
        extra_packages=["./london_agent"],
        display_name="LondonAgent",
        description="London Travel Agent",
        env_vars={
            "GOOGLE_GENAI_USE_VERTEXAI": "TRUE",
            "DB_TYPE": "sqlite",        }
    )
except Exception as e:
    print(e)