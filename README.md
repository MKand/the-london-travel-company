# The London Travel Company

The London Travel Company is a generative AI-powered travel assistant that helps users plan their trips to London. It provides information about attractions, activities, and other points of interest.

## Architecture

The application consists of the following components:

* **Frontend:** (Not yet started) A Vue.js frontend with Tailwind CSS.
* **Backend:** A Python backend built with FastAPI. The backend uses a generative AI agent to process user queries.
* **Database:** A PostgreSQL database with the pgvector extension for storing and querying vector embeddings.

The backend and database are deployed to Google Kubernetes Engine (GKE).

## Getting Started

### Prerequisites

* Docker
* docker-compose
* Google cloud project with owner priviliges (to create a Service account with necessary roles)

## Deployment to Cloud

The application can be deployed to GKE using the provided Helm charts and Terraform scripts.

### Deploying app infra with Terraform in a NEW project

Clone the repository

```bash
git clone https://github.com/GoogleCloudPlatform/the-london-travel-company.git
cd the-london-travel-company
```

The Terraform scripts in the `deploy/terraform_qwiklabs` directory can be used to provision the necessary infrastructure on GCP for running the application. This will create a GKE cluster, and all the necessary APIs and service accounts.

Before running the Terraform scripts, you need to update the `backend.tf` with your GCS bucket information and `variables.tf` with your GCP project ID and other variables.

## Workbook

For a more detailed explanation of the infrastructure and architecture, please refer to the [Workbook doc]([Workbook.md](https://docs.google.com/document/d/10NkZJ-7KkRBjSxGRK9K8QohmDgEFzMdtj3-6QNiA2aU/edit?usp=sharing&resourcekey=0-32fAkFlRtWcoiF7S6-pIfQ)) and skip ahead to `Part 1`. This is readable only by Alphabet employees for now.

## [For Repo Maintainers] Creating a host project to host the artifacts required for this app

The `deploy/terraform` directory is only needed to bootstrap a host project where the Helm charts and Docker images are stored (currently o11y-movie-guru). This central host project is where all other application projects get their images and artifacts. Run the Terraform scripts in `deploy/terraform` to create the infrastructure in the base project. The CI pipeline is described in more detail in the `Helm.md` file.

The Docker images can be created or updated by running the `build_images.sh` script, which triggers a build pipeline.

### Running the app locally

1. Clone the repository

```bash
git clone https://github.com/GoogleCloudPlatform/the-london-travel-company.git
cd the-london-travel-company
```

1. Create a service account with the following roles `roles/aiplatform.user`, `roles/monitoring.metricWriter`, `roles/cloudtrace.agent`, `roles/logging.logWriter`, `roles/telemetry.writer`.

1. Download the service account json key and store it as `.key.json` in the root directory of the project.

1. **Create a .env file:**
    Create a `.env` file in the root directory of the project and add the following environment variables: `PROJECT_ID`, `LOCATION`

1. **Start the application:**

    ```bash
    docker-compose up -d
    ```

1. **Access the application:**
    The backend will be available at [http://localhost:8001](http://localhost:8001)