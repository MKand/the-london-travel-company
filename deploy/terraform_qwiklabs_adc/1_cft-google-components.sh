SPACE_ID="default-space"
CATALOG_ID="default-catalog"
export PROJECT_ID=$1

echo "Setting up environment for Project: ${PROJECT_ID}"
gcloud config set project $PROJECT_ID


#!/usr/bin/env bash
# ------------------------------------------------------------------------------
# Tags
# ------------------------------------------------------------------------------
./adc.sh --function=create-catalog-template \
      --space-id=$SPACE_ID --catalog-id=$CATALOG_ID \
      --catalog-template-id="tags" \
      --display-name="Google Cloud Tags" \
      --description="This Terraform module makes it easier to create tags and bind them to different resources/services for your Google Cloud environment."

./adc.sh --function=create-catalog-template-revision \
      --space-id=$SPACE_ID --catalog-id=$CATALOG_ID \
      --catalog-template-id="tags" --revision-id="r1" \
      --public-repo-url="GoogleCloudPlatform/terraform-google-tags" \
      --ref-tag="v0.3.0" \
      --roles="roles/resourcemanager.tagAdmin,roles/resourcemanager.tagUser" \
      --provider-versions='[{"source": "hashicorp/google", "version": ">= 4.48, < 8"}]' \
      --terraform-version-constraint=">= 1.3"

# ------------------------------------------------------------------------------
# Vertex - Model Armor Floor Settings
# ------------------------------------------------------------------------------
./adc.sh --function=create-catalog-template \
  --space-id=$SPACE_ID \
  --catalog-id=$CATALOG_ID \
  --catalog-template-id="vertex-model-armor-floorsetting" \
  --display-name="Model Armor Floor Settings" \
  --description="This module is used to create Model Armor floor settings." 

./adc.sh --function=create-catalog-template-revision \
  --space-id=$SPACE_ID \
  --catalog-id=$CATALOG_ID \
  --catalog-template-id="vertex-model-armor-floorsetting" --revision-id="r1"  \
  --ref-tag="v2.3.1" \
  --public-repo-url="GoogleCloudPlatform/terraform-google-vertex-ai" \
  --dir="modules/model-armor-floorsetting" \
  --roles="roles/aiplatform.admin,roles/compute.admin,roles/compute.networkAdmin,roles/notebooks.admin,roles/iam.securityAdmin,roles/iam.serviceAccountAdmin,roles/iam.serviceAccountUser,roles/cloudkms.admin,roles/iam.roleAdmin,roles/storage.admin,roles/cloudkms.cryptoKeyEncrypterDecrypter,roles/modelarmor.admin,roles/modelarmor.floorSettingsAdmin" \
  --terraform-version-constraint=">= 1.3" \
  --provider-versions='[{"source": "hashicorp/google", "version": ">= 6.6.0, < 8"}, {"source": "hashicorp/google-beta", "version": ">= 6.6.0, < 8"}]' 

# ------------------------------------------------------------------------------
# Vertex - Model Armor Template
# ------------------------------------------------------------------------------
./adc.sh --function=create-catalog-template \
  --space-id=$SPACE_ID \
  --catalog-id=$CATALOG_ID \
  --catalog-template-id="vertex-model-armor-template" \
  --display-name="Model Armor Template" \
  --description="This module is used to create Model Armor template." 

./adc.sh --function=create-catalog-template-revision \
  --space-id=$SPACE_ID \
  --catalog-id=$CATALOG_ID \
  --catalog-template-id="vertex-model-armor-template" \
  --revision-id="r1" \
  --ref-tag="v2.4.1" \
  --public-repo-url="singhalbhaskar/terraform-google-vertex-ai" \
  --dir="modules/model-armor-template" \
  --roles="roles/aiplatform.admin,\
roles/compute.admin,\
roles/compute.networkAdmin,\
roles/notebooks.admin,\
roles/iam.securityAdmin,\
roles/iam.serviceAccountAdmin,\
roles/iam.serviceAccountUser,\
roles/cloudkms.admin,\
roles/iam.roleAdmin,\
roles/storage.admin,\
roles/cloudkms.cryptoKeyEncrypterDecrypter,\
roles/modelarmor.admin,\
roles/modelarmor.floorSettingsAdmin" \
  --terraform-version-constraint=">= 1.3" \
  --provider-versions='[
    {"source": "hashicorp/google", "version": ">= 6.6.0, < 8"},
    {"source": "hashicorp/google-beta", "version": ">= 6.6.0, < 8"}
  ]'
# ------------------------------------------------------------------------------
# Agent Engine
# ------------------------------------------------------------------------------
./adc.sh --function=create-catalog-template \
  --space-id=$SPACE_ID \
  --catalog-id=$CATALOG_ID \
  --catalog-template-id="agent-engine" \
  --display-name="Agent Engine" \
  --description="The module creates Agent Engine and related dependencies. It supports both source based deployments (aka in-line deployment) and serialized object deployment (aka pickle deployment)." 

./adc.sh --function=create-catalog-template-revision \
  --space-id=$SPACE_ID \
  --catalog-id=$CATALOG_ID \
  --catalog-template-id="agent-engine" \
  --revision-id="r1" \
  --ref-tag="v1.0" \
  --public-repo-url="singhalbhaskar/agent-engine" \
  --dir="" \
  --roles="roles/aiplatform.user,roles/storage.objectViewer,roles/viewer" \
  --terraform-version-constraint=">= 1.3" \
  --provider-versions='[
    {"source": "hashicorp/google", "version": ">= 7.13.0, < 8"},
    {"source": "hashicorp/google-beta", "version": ">= 7.13.0, < 8"}
  ]'

# ------------------------------------------------------------------------------
# Cloud Run
# ------------------------------------------------------------------------------
./adc.sh --function=create-catalog-template \
  --space-id=$SPACE_ID \
  --catalog-id=$CATALOG_ID \
  --catalog-template-id="cloud-run" \
  --display-name="Cloud Run" \
  --description="Cloud Run is a fully managed serverless compute platform that lets you deploy and run containerized applications and jobs. It abstracts away all infrastructure management, automatically scaling your services from zero to handle sudden traffic surges so you can focus on building great applications." 

./adc.sh --function=create-catalog-template-revision \
  --space-id=$SPACE_ID \
  --catalog-id=$CATALOG_ID \
  --catalog-template-id="cloud-run" --revision-id="r1"  \
  --ref-tag="v0.21.6" \
  --public-repo-url="GoogleCloudPlatform/terraform-google-cloud-run" \
  --dir="modules/v2" \
  --roles="roles/run.admin,roles/iam.serviceAccountAdmin,roles/iam.serviceAccountUser,roles/serviceusage.serviceUsageViewer,roles/resourcemanager.projectIamAdmin,roles/compute.viewer,roles/iap.admin" \
  --terraform-version-constraint=">= 1.3" \
  --provider-versions='[{"source": "hashicorp/google", "version": ">= 6.6.0, < 8"}, {"source": "hashicorp/google-beta", "version": ">= 6.6.0, < 8"}]' 

# ------------------------------------------------------------------------------
# Cloud SQL (Postgresql)
# ------------------------------------------------------------------------------
./adc.sh --function=create-catalog-template \
  --space-id=$SPACE_ID \
  --catalog-id=$CATALOG_ID \
  --catalog-template-id="postgresql" \
  --display-name="Cloud SQL (Postgresql)" \
  --description="Cloud SQL for PostgreSQL is a fully-managed database service that helps you set up, maintain, manage, and administer your PostgreSQL relational databases on Google Cloud Platform." 

./adc.sh --function=create-catalog-template-revision \
  --space-id=$SPACE_ID \
  --catalog-id=$CATALOG_ID \
  --catalog-template-id="postgresql" --revision-id="r1"  \
  --ref-tag="v26.2.2" \
  --public-repo-url="terraform-google-modules/terraform-google-sql-db" \
  --dir="modules/postgresql" \
  --roles="roles/cloudsql.admin,roles/resourcemanager.projectIamAdmin,roles/iam.serviceAccountUser,roles/compute.networkAdmin,roles/cloudkms.admin,roles/cloudkms.autokeyAdmin,roles/storage.admin,roles/cloudkms.cryptoKeyEncrypterDecrypter,roles/logging.logWriter" \
  --terraform-version-constraint=">= 1.3" \
  --provider-versions='[{"source": "hashicorp/google", "version": ">= 6.6.0, < 8"}, {"source": "hashicorp/google-beta", "version": ">= 6.6.0, < 8"}]' 

# ------------------------------------------------------------------------------
# Service Account
# ------------------------------------------------------------------------------
./adc.sh --function=create-catalog-template \
  --space-id=$SPACE_ID \
  --catalog-id=$CATALOG_ID \
  --catalog-template-id="service-account" \
  --display-name="Service Account" \
  --description="A service account is a special kind of account typically used by an application or compute workload, such as a Compute Engine instance, rather than a person. A service account is identified by its email address, which is unique to the account." 

./adc.sh --function=create-catalog-template-revision \
  --space-id=$SPACE_ID \
  --catalog-id=$CATALOG_ID \
  --catalog-template-id="service-account" --revision-id="r1"  \
  --ref-tag="v4.6.0" \
  --public-repo-url="terraform-google-modules/terraform-google-service-accounts" \
  --dir="modules/simple-sa" \
  --roles="roles/resourcemanager.projectIamAdmin,roles/iam.serviceAccountAdmin,roles/iam.serviceAccountUser,roles/logging.logWriter" \
  --terraform-version-constraint=">= 1.3" \
  --provider-versions='[{"source": "hashicorp/google", "version": ">= 6.6.0, < 8"}, {"source": "hashicorp/google-beta", "version": ">= 6.6.0, < 8"}]' 

# ------------------------------------------------------------------------------
# GCS Bucket
# ------------------------------------------------------------------------------
./adc.sh --function=create-catalog-template \
  --space-id=$SPACE_ID \
  --catalog-id=$CATALOG_ID \
  --catalog-template-id="gcs-storage" \
  --display-name="GCS Bucket" \
  --description="Cloud Storage allows world-wide storage and retrieval of any amount of data at any time. You can use Cloud Storage for a range of scenarios including serving website content, storing data for archival and disaster recovery, or distributing large data objects to users via direct download." 

./adc.sh --function=create-catalog-template-revision \
  --space-id=$SPACE_ID \
  --catalog-id=$CATALOG_ID \
  --catalog-template-id="gcs-storage" --revision-id="r1"  \
  --ref-tag="v12.0.0" \
  --public-repo-url="terraform-google-modules/terraform-google-cloud-storage" \
  --dir="modules/simple_bucket" \
  --roles="roles/storage.admin,roles/iam.serviceAccountAdmin,roles/iam.serviceAccountUser,roles/resourcemanager.projectIamAdmin,roles/serviceusage.serviceUsageAdmin" \
  --terraform-version-constraint=">= 1.3" \
  --provider-versions='[{"source": "hashicorp/google", "version": ">= 6.6.0, < 8"}, {"source": "hashicorp/google-beta", "version": ">= 6.6.0, < 8"}]' 

# ------------------------------------------------------------------------------
# Secret Manager
# ------------------------------------------------------------------------------
./adc.sh --function=create-catalog-template \
  --space-id=$SPACE_ID \
  --catalog-id=$CATALOG_ID \
  --catalog-template-id="secret-manager" \
  --display-name="Secret Manager" \
  --description="Secret Manager is a secure and convenient storage system for API keys, passwords, certificates, and other sensitive data." 

./adc.sh --function=create-catalog-template-revision \
  --space-id=$SPACE_ID \
  --catalog-id=$CATALOG_ID \
  --catalog-template-id="secret-manager" --revision-id="r1"  \
  --ref-tag="v0.9.0" \
  --public-repo-url="GoogleCloudPlatform/terraform-google-secret-manager" \
  --dir="modules/simple-secret" \
  --roles="roles/secretmanager.admin,roles/iam.serviceAccountUser,roles/logging.logWriter" \
  --terraform-version-constraint=">= 1.3" \
  --provider-versions='[{"source": "hashicorp/google", "version": ">= 6.6.0, < 8"}, {"source": "hashicorp/google-beta", "version": ">= 6.6.0, < 8"}]' 

# ------------------------------------------------------------------------------
# Global Load Balancing (Frontend)
# ------------------------------------------------------------------------------
./adc.sh --function=create-catalog-template \
  --space-id=$SPACE_ID \
  --catalog-id=$CATALOG_ID \
  --catalog-template-id="global-lb-frontend" \
  --display-name="Global Load Balancing (Frontend)" \
  --description="Configure the load balancer frontend IP address, port, and protocol. Configure an SSL certificate if using HTTPS." 

./adc.sh --function=create-catalog-template-revision \
  --space-id=$SPACE_ID \
  --catalog-id=$CATALOG_ID \
  --catalog-template-id="global-lb-frontend" --revision-id="r1"  \
  --ref-tag="v13.2.0" \
  --public-repo-url="terraform-google-modules/terraform-google-lb-http" \
  --dir="modules/frontend" \
  --roles="roles/storage.admin,roles/iap.admin,roles/certificatemanager.owner,roles/iam.serviceAccountUser,roles/compute.admin" \
  --terraform-version-constraint=">= 1.3" \
  --provider-versions='[{"source": "hashicorp/google", "version": ">= 6.6.0, < 8"}, {"source": "hashicorp/google-beta", "version": ">= 6.6.0, < 8"}]' 

# ------------------------------------------------------------------------------
# Global Load Balancing (Backend)
# ------------------------------------------------------------------------------
./adc.sh --function=create-catalog-template \
  --space-id=$SPACE_ID \
  --catalog-id=$CATALOG_ID \
  --catalog-template-id="global-lb-backend" \
  --display-name="Global Load Balancing (Backend)" \
  --description="Create a backend service for incoming traffic" 

./adc.sh --function=create-catalog-template-revision \
  --space-id=$SPACE_ID \
  --catalog-id=$CATALOG_ID \
  --catalog-template-id="global-lb-backend" --revision-id="r1"  \
  --ref-tag="v13.2.0" \
  --public-repo-url="terraform-google-modules/terraform-google-lb-http" \
  --dir="modules/backend" \
  --roles="roles/compute.admin,roles/storage.admin,roles/run.admin,roles/compute.networkAdmin,roles/iap.admin,roles/iam.serviceAccountUser,roles/iam.serviceAccountAdmin" \
  --terraform-version-constraint=">= 1.3" \
  --provider-versions='[{"source": "hashicorp/google", "version": ">= 6.6.0, < 8"}, {"source": "hashicorp/google-beta", "version": ">= 6.6.0, < 8"}]' 

# ------------------------------------------------------------------------------
# BigQuery
# ------------------------------------------------------------------------------
./adc.sh --function=create-catalog-template \
  --space-id=$SPACE_ID \
  --catalog-id=$CATALOG_ID \
  --catalog-template-id="bigquery" \
  --display-name="BigQuery" \
  --description="BigQuery is Google Clouds fully managed, petabyte-scale, and cost-effective analytics data warehouse that lets you run analytics over vast amounts of data in near real time." 

./adc.sh --function=create-catalog-template-revision \
  --space-id=$SPACE_ID \
  --catalog-id=$CATALOG_ID \
  --catalog-template-id="bigquery" --revision-id="r1"  \
  --ref-tag="v10.2.1" \
  --public-repo-url="terraform-google-modules/terraform-google-bigquery" \
  --roles="roles/bigquery.admin,roles/storage.admin,roles/cloudkms.cryptoKeyEncrypterDecrypter" \
  --terraform-version-constraint=">= 1.3" \
  --provider-versions='[{"source": "hashicorp/google", "version": ">= 6.6.0, < 8"}, {"source": "hashicorp/google-beta", "version": ">= 6.6.0, < 8"}]' 

# ------------------------------------------------------------------------------
#  MCP-BQ
# ------------------------------------------------------------------------------
./adc.sh --function=create-catalog-template \
      --space-id=$spaceid \
      --catalog-id=$catalogid \
      --catalog-template-id="mcp-bq" \
      --display-name="MCP BigQuery" \
      --description="This module handles the API enablement of BQ MCP."

./adc.sh --function=create-catalog-template-revision \
      --space-id=$spaceid \
      --catalog-id=$catalogid \
      --catalog-template-id="mcp-bq" \
      --revision-id="r1" \
      --public-repo-url="raj-830/mcp" \
      --ref-tag="1.0" \
      --dir="/modules" \
      --roles="roles/bigquery.admin,roles/storage.admin,roles/iam.serviceAccountUser,roles/iam.serviceAccountAdmin,roles/serviceusage.serviceUsageAdmin" \
      --terraform-version-constraint=">= 1.3" \
      --provider-versions='[{"source": "hashicorp/google", "version": ">= 6.6.0, < 8"}]'