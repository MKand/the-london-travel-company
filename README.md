# The London Travel Company

The London Travel Company is a generative AI-powered travel assistant based on the Google Agent Development Kit (ADK) designed to help users plan trips to London. It features semantic search capabilities using Vertex AI embeddings and pgvector.

## Folder Structure

- `agents/`: The main FastAPI backend containing the hierarchical AI agents (london agent and ticket agent).
- `frontend/`: The Vue 3 frontend application built with Vite and Tailwind CSS.
- `london_data_mcp/`: The Data MCP Server built to query the PostgreSQL database.
- `data_syncer/`: A FastAPI service that synchronizes initial travel data into the database.
- `deploy/`: Deployment configurations including ADC templates and scripts.
- `fake_user/`: A load tester / user simulator service.
- `codelab/`: Codelab documentation for the project.
- `data_london/`: Contains data files or scripts.
- `docker-compose.yaml`: Local container orchestration configuration to easily spin up all services.

## Requirements

### Local Development

- Docker and Docker Compose
- Node.js 18+ and npm
- A Google Cloud Project with a Service Account key downloaded as `.key.json` in the project root. (Requires roles: `roles/aiplatform.user`, `roles/monitoring.metricWriter`, `roles/logging.logWriter`, `roles/telemetry.writer`)

### Cloud Deployment

- Terraform CLI installed
- Google Cloud CLI (`gcloud`) installed and authenticated
- Google Cloud Project with billing enabled

## Running Locally

1. Create a `.env` file in the root directory:

   ```env
   PROJECT_ID=your-gcp-project-id
   LOCATION=your-gcp-region
   ```

2. Start the services using Docker Compose:

   ```bash
   docker-compose up -d
   ```

3. Initialize the database and sync the data:

   ```bash
   # Initialize the database and user
   curl -X POST http://localhost:8003/init -H "Content-Type: application/json" -d '{"admin_db_url": "postgresql://user:password@postgres:5432/postgres"}'
   
   # Synchronize travel data
   curl -X POST http://localhost:8003/sync -H "Content-Type: application/json" -d '{"admin_db_url": "postgresql://user:password@postgres:5432/london_travel"}'
   ```

   *Verify the synced metadata:*

   ```bash
   curl -X POST http://localhost:8003/read -H "Content-Type: application/json" -d '{"admin_db_url": "postgresql://user:password@postgres:5432/london_travel"}'
   ```

4. Access the application components:
   - **Frontend:** http://localhost:8080
   - **Backend Agent API:** http://localhost:8001
   - **Data MCP Server:** http://localhost:8002
   - **Data Syncer API:** http://localhost:8003

## Cloud Deployment

To deploy the full architecture to a GCP project using Cloud Run and App Hub:

1. Navigate to the main Terraform deployment directory:
   ```bash
   cd deploy/terraform_qwiklabs
   ```

2. Initialize and apply the configuration:

   ```bash
   terraform init
   terraform apply -var="project_id=your-gcp-project-id" -var="region=your-gcp-region"
   ```

## Importing the MCP server to the registry

Registry link (Internal to Google): https://pantheon.corp.google.com/agent-management/agent-registry?e=AgentManagementLaunch::AgentManagementEnabled&project=$PROJECT_ID

ADK: API Registry: https://google.github.io/adk-docs/integrations/api-registry/#use-with-agent



  curl -X POST https://data-syncer-96bb-390120015761.us-central1.run.app/sync -H "Content-Type: application/json" -d '{"admin_db_url": "postgresql://londondatauser:UbLUvhYgwE6YYW2bSpt2VCExXctEsvM8@34.171.180.7/london_travel"}'

