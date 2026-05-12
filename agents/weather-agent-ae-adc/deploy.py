import os
import vertexai
from vertexai.agent_engines import AgentEngine
from vertexai import types

# --- Configuration ---
PROJECT_ID = "agentic-platform-demo-495009"
LOCATION = "us-central1"
IMAGE_URI = "us-central1-docker.pkg.dev/agentic-platform-demo-495009/agents/weather_agent:latest"

# Initialize Vertex AI
client = vertexai.Client(
    project=PROJECT_ID,
 location=LOCATION,
# http_options=dict(api_version="v1beta1")
)

def deploy_agent_engine():
    try:
        # Deploy the Agent Engine instance using container_spec
        remote_agent = client.agent_engines.create(
            config={
                # "identity_type": types.IdentityType.AGENT_IDENTITY,
                "display_name": "Weather Agent",
                "description": "Weather Agent deployed with BYOI method.",
                "container_spec": {
                    "image_uri": IMAGE_URI
                },
            }
        )

        print(f"Successfully created Agent Engine: {remote_agent.resource_name}")
        print(f"Deployed from image URI: {IMAGE_URI}")

    except Exception as e:
        print(f"Error deploying Agent Engine: {e}")

if __name__ == "__main__":
    deploy_agent_engine()
    