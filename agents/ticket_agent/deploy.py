import vertexai
import google.auth
from vertexai import types
import os

PROJECT_ID = os.getenv("GOOGLE_CLOUD_PROJECT", "qwiklabs-gcp-01-86960e134c68")
LOCATION = os.getenv("GOOGLE_CLOUD_LOCATION", "us-central1")
STAGING_BUCKET = f'gs://{PROJECT_ID}-adk-bucket'

client = vertexai.Client(
    project=PROJECT_ID,               
    location=LOCATION,  
    http_options=dict(api_version="v1beta1")
)

# https://docs.cloud.google.com/agent-builder/agent-engine/deploy#from-dockerfile
try:
    remote_agent = client.agent_engines.create(
        config={
        "source_packages": [
            "agent.py",
            "config.py",
            "prompts.py",
            "tools.py",
            "utils.py",
            "requirements.txt",
            "Dockerfile",
        ],
        "image_spec": {},
        "display_name": 'ticket_agent',                   
        "description": 'Agent that books tickets for activities in London',                     
        "agent_framework": "google-adk",             
    },
    )
except Exception as e:
    print(e)
