#!/usr/bin/env bash
export PATH=$PATH:/usr/local/bin:/usr/bin:/bin
SPACE_ID="default-space"
CATALOG_ID="default-catalog"
export PROJECT_ID=$1

echo "Setting up environment for Project: ${PROJECT_ID}"
gcloud config set project $PROJECT_ID
chmod +x ./adc.sh

gcloud services enable apphub.googleapis.com cloudasset.googleapis.com servicehealth.googleapis.com config.googleapis.com designcenter.googleapis.com apphub.googleapis.com

#!/usr/bin/env bash
# ------------------------------------------------------------------------------
# 1. Create Space
# ------------------------------------------------------------------------------
./adc.sh --function=create-space \
      --space-id=$SPACE_ID \
      --enable-shared-templates

