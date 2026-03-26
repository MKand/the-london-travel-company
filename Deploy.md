# London Travel Company - Deployment Guide

This document provides step-by-step instructions for deploying the London Travel Company application using Google Cloud App Design Centre (ADC).

## Prerequisites

- Google Cloud CLI (`gcloud`) installed and authenticated
- `jq` installed for JSON processing
- A Google Cloud Project with billing enabled
- **Owner privileges on the Google Cloud Project**
- Docker and Docker Compose (for local development)

## Configuration

Set the following environment variables for your deployment:
```bash
export PROJECT_ID="your-gcp-project-id"
export LOCATION="us-central1"
export SPACE_ID="default-space"
```

---

## Running Locally

To run the application locally using Docker Compose:

1. Create a `.env` file in the root directory:
```env
PROJECT_ID=your-gcp-project-id
LOCATION=us-central1
```

2. Save the Google Cloud service account key as `.key.json` in the root directory. You can use the agent's service account as it has the *roles/aiplatform.user* role that is required by the agent, the london_data_mcp server and the data syncer. Alternatively, you can create a seperate service account with the roles/aiplatform.user role and use that.

3. Start the services:
```bash
docker-compose up -d
```

4. Access the application components:
- **Frontend:** http://localhost:8080
- **Backend Agent API:** http://localhost:8001
- **Data MCP Server:** http://localhost:8002
- **Data Syncer API:** http://localhost:8003

---

## Step 0: Authenticate with Google Cloud

Before proceeding with the deployment, ensure your `gcloud` credentials are set up correctly:

```bash
gcloud auth login
gcloud auth application-default login
```

---

## Step 1: Enable App Design Centre (ADC)

1. Open the Google Cloud Console
2. Navigate to **App Design Centre**
3. Enable the App Design Centre API if not already enabled

Alternatively, via gcloud:
```bash
gcloud services enable designcenter.googleapis.com --project=$PROJECT_ID
```

---

## Step 2: Upload the ADC Template

Before you can upload, you need to create an empty template by the name `london-travel-company-template.json` in the App Design Centre.

The template file `london-travel-company-template.json` is located in `deploy/adc_import_export/`.

Navigate to the ADC import export directory:
```bash
cd deploy/adc_import_export
```

Run the upload script:
```bash
./upload.sh $PROJECT_ID $SPACE_ID
```

This script will:
1. Perform target substitution (replacing project/space placeholders)
2. Import the template to the Design Centre


**Verify successful import:**
- Navigate to App Design Centre in the Google Cloud Console
- Check under Application Templates for `london-travel-company-template`

---

## Step 3: Deploy the Application from ADC

1. In App Design Centre, select the `london-travel-company-template`
2. Click **Deploy** or **Create Deployment**
3. Configure the deployment:
   - Name: `london-travel-deployment`
   - Region: `$LOCATION`
   - Service account (create if needed with appropriate permissions)
4. Deploy the application

---

## Step 4: Populate the Database

After deployment, populate the database with travel data. The Data Syncer service is deployed by ADC with external ingress but requires authentication.

**Sync the travel data:**

```bash
# Get the Cloud Run service URL
DATA_SYNCER_URL=$(gcloud run services describe data-syncer --region=$LOCATION --project=$PROJECT_ID --format="value(status.url)")

# Call the sync endpoint with bearer token authentication
curl -X POST ${DATA_SYNCER_URL}/sync \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $(gcloud auth print-identity-token)" \
  -d '{"admin_db_url": "postgresql://londondatauser:<password>@<CLOUD_SQL_IP>:5432/london_travel"}'
```

Where:
- `<password>`: Get from Cloud SQL credentials or Secret Manager
- `<CLOUD_SQL_IP>`: Get the Cloud SQL instance IP address:
  ```bash
  gcloud sql instances describe <INSTANCE_NAME> --project=$PROJECT_ID --format="value(ipAddresses[0].ipAddress)"
  ```

---

## Step 5: Verify Data Sync

Verify the synced data using the `/read` endpoint:
```bash
curl -X POST ${DATA_SYNCER_URL}/read \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $(gcloud auth print-identity-token)" \
  -d '{"db_url": "postgresql://londondatauser:<password>@<CLOUD_SQL_IP>:5432/london_travel"}'
```

Expected response should include metadata about synced locations and activities.

---

## Step 6: Upload MCP to Registry

Navigate to the MCP Registry (replace `$PROJECT_ID` with your project):
```
https://pantheon.corp.google.com/agent-management/agent-registry?e=AgentManagementLaunch::AgentManagementEnabled&project=$PROJECT_ID
```

### MCP Information

**Name:**
```
london-data-backend
```

**Description:**
```
London Data MCP Server - Provides semantic search capabilities for London travel data including locations and activities. Uses Vertex AI embeddings and pgvector for semantic search. The server offers a single tool: search_with_natural_language which accepts a natural language query and returns matching London locations and activities ranked by relevance.
```

**JSON Tool Specification:**
```json
{
  "name": "search_with_natural_language",
  "description": "Search for London locations and activities using natural language.\n    \n    Args:\n        query: The natural language query to search for.\n        limit: The maximum number of results to return. Defaults to 10. This needs to be proportional to the number of days.\n            \n    Returns:\n        List[SearchResult]: A list of location or activity search results.",
  "inputSchema": {
    "type": "object",
    "properties": {
      "query": {
        "type": "string",
        "description": "The natural language query to search for.",
        "default": "fun activities"
      },
      "limit": {
        "type": "number",
        "description": "The maximum number of results to return. Defaults to 10.",
        "default": 10
      }
    },
    "required": []
  }
}
```

**Full MCP Tool Spec:**
```json
{
  "tools": [
    {
      "name": "search_with_natural_language",
      "description": "Search for London locations and activities using natural language.\n    \n    Args:\n        query: The natural language query to search for.\n        limit: The maximum number of results to return. Defaults to 10. This needs to be proportional to the number of days.\n            \n    Returns:\n        List[SearchResult]: A list of location or activity search results.",
      "inputSchema": {
        "type": "object",
        "properties": {
          "query": {
            "type": "string",
            "description": "The natural language query to search for.",
            "default": "fun activities"
          },
          "limit": {
            "type": "number",
            "description": "The maximum number of results to return. Defaults to 10.",
            "default": 10
          }
        },
        "required": []
      }
    }
  ]
}
```

---

## MCP Server Connection Details

When configuring the MCP in the registry, use the following endpoint:
- **URL:** `https://<MCP_SERVER_CLOUD_RUN_URL>/mcp`
- **Transport:** `streamable-http`
- **Port:** `8002`

### Database Configuration

The MCP Server supports switching between SQLite (for local development) and PostgreSQL (for production Cloud SQL). Configure this via environment variables:

| Variable | Description | Default |
|----------|-------------|---------|
| `DB_TYPE` | Database type: `sqlite` or `postgres` | `sqlite` |
| `SQLITE_DB_PATH` | Path to SQLite database file | `data/london_travel.db` |
| `POSTGRES_HOST` | PostgreSQL host | `localhost` |
| `POSTGRES_PORT` | PostgreSQL port | `5432` |
| `POSTGRES_DB` | PostgreSQL database name | `london_travel` |
| `POSTGRES_USER` | PostgreSQL username | `user` |
| `POSTGRES_PASSWORD` | PostgreSQL password | `password` |

For production with Cloud SQL, set:

```bash
DB_TYPE=postgres
```

And configure the host using the Cloud SQL instance IP address:

```bash
# Get the Cloud SQL instance IP
POSTGRES_HOST=$(gcloud sql instances describe <INSTANCE_NAME> --project=$PROJECT_ID --format="value(ipAddresses[0].ipAddress)")
```

---

## Service URLs (Post-Deployment)

After deployment, services will be available at:
- **Frontend:** `https://london-travel-agent-frontend-*.run.app`
- **Backend Agent API:** `https://london-travel-agent-backend-*.run.app`
- **Data MCP Server:** `https://london-travel-agent-mcp-*.run.app`
- **Data Syncer API:** `https://london-travel-agent-syncer-*.run.app`

---

## Troubleshooting

### Check Cloud Run services
```bash
gcloud run services list --region=$LOCATION --project=$PROJECT_ID
```

### View logs
```bash
gcloud logs read --service=agents --region=$LOCATION --project=$PROJECT_ID
gcloud logs read --service=mcpserver --region=$LOCATION --project=$PROJECT_ID
```

### Database connection issues
Ensure the database credentials secret is properly configured in the ADC template deployment.


# Downloading an ADC Template for Future Use

To download an existing template from ADC for backup or migration:

```bash
cd deploy/adc_import_export
./download.sh $SOURCE_PROJECT_ID $SOURCE_SPACE_ID $SOURCE_APP_TEMPLATE
```

This will:
1. Fetch the template from ADC
2. Save it as `$SOURCE_APP_TEMPLATE.json`
