import vertexai

PROJECT_ID = "agentic-platform-demo-495009"
LOCATION = "us-central1"

client = vertexai.Client(
    project=PROJECT_ID,
    location=LOCATION,
)

remote_agent = client.agent_engines.create(
    config={
        "display_name": "[byod] currency_exchange_agent",
        "description": "byod testing with example agent",
        "source_packages": [
            # The files in the current directory to upload. You can also use "."
            "currency_exchange_agent",
            "Dockerfile",
            "main.py",
            "requirements.txt",
        ],
        "image_spec": {}, # tells AgentEngine to use the Dockerfile
        "class_methods": [
            # For convenience to interact with the agent through the Python SDK
            # https://docs.cloud.google.com/agent-builder/agent-engine/use/adk
            {'api_mode': '', 'name': 'get_session'},
            {'api_mode': '', 'name': 'list_sessions'},
            {'api_mode': '', 'name': 'create_session'},
            {'api_mode': '', 'name': 'delete_session'},
            {'api_mode': 'async', 'name': 'async_get_session'},
            {'api_mode': 'async', 'name': 'async_list_sessions'},
            {'api_mode': 'async', 'name': 'async_create_session'},
            {'api_mode': 'async', 'name': 'async_delete_session'},
            {'api_mode': 'async', 'name': 'async_add_session_to_memory'},
            {'api_mode': 'async', 'name': 'async_search_memory'},
            {'api_mode': 'stream', 'name': 'stream_query'},
            {'api_mode': 'async_stream', 'name': 'async_stream_query'},
            {'api_mode': 'async_stream', 'name': 'streaming_agent_run_with_events'},
        ],
        "agent_framework": "google-adk", # For usage through the console / UI
    },
)
