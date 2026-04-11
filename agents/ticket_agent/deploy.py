import vertexai
import google.auth
from vertexai import types
from agent import root_agent


_, project = google.auth.default()

vertexai.init(
    project=project,               # Your project ID.
    location="us-central1",  
    http_options=dict(api_version="v1beta1")
)

remote_agent = client.agent_engines.create(
    agent=root_agent,                                  # Optional.
    config={
        "extra_packages": ['ticket_agent'],               # Optional.
        "display_name": 'ticket_agent',                   # Optional.
        "description": 'Agent that books tickets for activities in London',                     # Optional.
        "identity_type":  types.IdentityType.AGENT_IDENTITY,                 # Optional.
        "min_instances": 0,                 # Optional.
        "max_instances": 2,                 # Optional.
        "container_concurrency": 2, # Optional
        "agent_framework": "google-adk",             # Optional.
    },
)