import vertexai
import google.auth
from vertexai import types
from ticket_agent.agent import root_agent
import os

PROJECT_ID = os.getenv("GOOGLE_CLOUD_PROJECT")
LOCATION = os.getenv("GOOGLE_CLOUD_LOCATION", "us-central1")
STAGING_BUCKET = f'gs://{PROJECT_ID}-adk-bucket'

client = vertexai.Client(
    project=PROJECT_ID,               
    location=LOCATION,  
    http_options=dict(api_version="v1beta1")
)

try:
    remote_agent = client.agent_engines.create(
        agent=root_agent,                                  
        config={
        "staging_bucket": STAGING_BUCKET,  
        "extra_packages": ['ticket_agent'],               
        "display_name": 'ticket_agent',                   
        "description": 'Agent that books tickets for activities in London',                     
        "identity_type":  types.IdentityType.AGENT_IDENTITY,                 
        "min_instances": 0,                 
        "max_instances": 2,                 
        "container_concurrency": 2, 
        "agent_framework": "google-adk",             
    },
    )
except Exception as e:
    print(e)
