# Weather Agent for ADC

This folder contains the Weather Agent configured for deployment via App Design Center (ADC) on Vertex AI Reasoning Engines.

## Folder Structure

- `agent/`: Contains the core agent code.
  - `__init__.py`: Exposes the `root_agent`.
  - `agent.py`: Defines the agent and its configuration.
  - `requirements.txt`: Dependencies for the agent.
- `main.py`: FastAPI application entry point (used for local testing or if not using ADC inline source).
- `deploy.py`: Helper script for deploying via Python SDK (optional if using Terraform/ADC).

## Requirements

### Cloud Deployment (ADC)
To deploy via ADC/Terraform, you need to package the *contents* of the `agent/` directory and provide it as a base64 encoded tarball in your Terraform configuration.

1. Package the files:
   ```bash
   cd agent
   tar -czvf ../agent.tar.gz *
   cd ..
   ```
2. Encode to base64:
   ```bash
   base64 agent.tar.gz -w 0 > agent.tar.gz.b64
   ```
3. Use the contents of `agent.tar.gz.b64` in your Terraform `source_archive` field.

## Terraform Configuration

To configure the nightly agent engine component in your Terraform code, you can use the `agent-engine-nightly` module with the following spec:

```hcl
module "agent-engine-1" {
  source       = "github.com/GoogleCloudPlatform/terraform-google-vertex-ai//modules/agent-engine-nightly?ref=v5.3.2"
  display_name = var.agent-engine-1_display_name
  project_id   = var.agent-engine-1_project_id
  region       = var.agent-engine-1_region
  
  spec = {
    agent_framework = "google-adk"
    class_methods = [{
      api_mode    = "async_stream"
      method_name = "async_stream_query"
    }]
    deployment_spec = {
      container_concurrency = 1
      env = {
        GOOGLE_CLOUD_AGENT_ENGINE_ENABLE_TELEMETRY         = "true"
        OTEL_INSTRUMENTATION_GENAI_CAPTURE_MESSAGE_CONTENT = "true"
        GOOGLE_GENAI_USE_VERTEXAI = "true"
      }
      max_instances = 3
      min_instances = 1
    }
    identity_type = "AGENT_IDENTITY"
    source_code_spec = {
      inline_source = {
        source_archive = "YOUR_BASE64_ENCODED_STRING_HERE"
      }
      python_spec = {
        entrypoint_module = "agent"  # folder name, or name defined in __init__.py
        entrypoint_object = "app"   # entrypoint object
        requirements_file = "requirements.txt"  # requirements file
        version           = "3.11"   # python version
      }
    }
  }
}
```

Replace `"YOUR_BASE64_ENCODED_STRING_HERE"` with the contents of the `agent.tar.gz.b64` file you generated.

## Local Running

To run the application locally:
1. Ensure you have Python 3.11 installed.
2. Install dependencies:
   ```bash
   pip install -r agent/requirements.txt
   ```
3. Run the Uvicorn server:
   ```bash
   uvicorn main:app --host 0.0.0.0 --port 8080
   ```
