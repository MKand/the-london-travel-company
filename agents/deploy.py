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

try:
    db_type = os.getenv("DB_TYPE", "sqlite")
    env_vars = {
        "GOOGLE_GENAI_USE_VERTEXAI": "TRUE",
        "DB_TYPE": db_type,
    }
    
    if db_type == "postgres":
        env_vars.update({
            "POSTGRES_USER": os.getenv("POSTGRES_USER"),
            "POSTGRES_PASSWORD": os.getenv("POSTGRES_PASSWORD"),
            "POSTGRES_HOST": os.getenv("POSTGRES_HOST"),
            "POSTGRES_PORT": os.getenv("POSTGRES_PORT", "5432"),
            "POSTGRES_DB": os.getenv("POSTGRES_DB"),
        })

    remote_agent = agent_engines.AgentEngine.create(
        agent_engine=root_agent,                                
        requirements="./requirements.txt",
        extra_packages=["./london_agent"],
        display_name="LondonAgent",
        description="London Travel Agent",
        env_vars=env_vars
    )
except Exception as e:
    print(e)