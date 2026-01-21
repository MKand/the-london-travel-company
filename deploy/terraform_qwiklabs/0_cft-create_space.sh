#!/usr/bin/env bash
SPACE_ID="default-space"
CATALOG_ID="default-catalog"
LOCATION="us-central1"
export PROJECT_ID=$1

# ------------------------------------------------------------------------------
# 0. Setup Environment
# ------------------------------------------------------------------------------
echo "Setting up environment for Project: ${PROJECT_ID}"
gcloud config set project $PROJECT_ID

gcloud components update

# ------------------------------------------------------------------------------
# 1. Enable APIs
# ------------------------------------------------------------------------------
gcloud services enable \
config.googleapis.com \
servicehealth.googleapis.com \
apphub.googleapis.com \
cloudasset.googleapis.com \
designcenter.googleapis.com \
cloudasset.googleapis.com

# ------------------------------------------------------------------------------
# 2. Create AppHub Boundary
# ------------------------------------------------------------------------------
gcloud apphub boundary update \
    --crm-node=projects/$PROJECT_ID \
    --project=$PROJECT_ID \
    --location=global

# ------------------------------------------------------------------------------
# 2. Make adc.sh executable
# ------------------------------------------------------------------------------
chmod +x ./adc.sh

#!/usr/bin/env bash
# ------------------------------------------------------------------------------
# 1. Create Space
# ------------------------------------------------------------------------------
./adc.sh --function=create-space \
      --space-id=$SPACE_ID \
      --enable-shared-templates

# ------------------------------------------------------------------------------
# 2. Create Catalog
# ------------------------------------------------------------------------------
gcloud design-center spaces catalogs create $CATALOG_ID \
--space=$SPACE_ID \
--project=$PROJECT_ID \
--location=$LOCATION 

# ------------------------------------------------------------------------------
# 3. Create Share
# Not sure if this is necessary
# ------------------------------------------------------------------------------
gcloud design-center spaces catalogs shares create my-share \
--destination-space=$SPACE_ID \
--project=$PROJECT_ID \
--location=$LOCATION \
--space=$SPACE_ID \
--catalog=$CATALOG_ID




