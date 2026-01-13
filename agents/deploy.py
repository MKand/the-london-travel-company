from vertexai.preview import reasoning_engines
from vertexai import agent_engines
from london_agent.agent import root_agent
import os
import vertexai

PROJECT_ID = "o11y-movie-guru"
LOCATION = "us-central1"
STAGING_BUCKET = "gs://o11y-movie-guru-agentengine2"

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
            "ENABLE_METRICS": "true",
            "OTEL_EXPORTER_OTLP_ENDPOINT": "http://localhost:4318",
            "GOOGLE_GENAI_USE_VERTEXAI": "TRUE",
            "DB_TYPE": "sqlite",
            "POSTGRES_HOST": "o11y-movie-guru:europe-west4:london-travel-db",
            "POSTGRES_USER": "postgres",
            "POSTGRES_PASSWORD": "YOUR_POSTGRES_PASSWORD",
            "POSTGRES_DB": "LONDON_activities",
        }
    )
except Exception as e:
    print(e)