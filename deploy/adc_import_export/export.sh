#!/bin/bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail

# 1. Configuration Variables
LOCATION="us-central1"

# --- USAGE ---
usage() {
    echo "Usage: $0 <SOURCE_PROJECT_ID> <SOURCE_SPACE_ID> <SOURCE_APP_TEMPLATE>"
    echo ""
    echo "Example: $0 source-project-123 source-space-456 source-app-template"
    echo ""
    echo "This script performs target substitution and imports it to Google Cloud Design Center."
    exit 1
}

# --- VALIDATION ---
if [ "$#" -ne 3 ]; then
    echo "Error: Invalid number of arguments."
    usage
fi

SOURCE_PROJECT_ID=$1
SOURCE_SPACE_ID=$2
SOURCE_APP_TEMPLATE=$3

# Ensure jq is installed for extraction
if ! command -v jq &> /dev/null; then
    echo "Error: 'jq' is not installed. Please install it to continue."
    exit 1
fi

# 2. Construct the Resource Name
RESOURCE_PATH="projects/$SOURCE_PROJECT_ID/locations/$LOCATION/spaces/$SOURCE_SPACE_ID/applicationTemplates/$SOURCE_APP_TEMPLATE"

# 3. Execute GET and save to file.txt
echo "Fetching template and saving to file.txt..."

curl -s -X GET \
  -H "Authorization: Bearer $(gcloud auth print-access-token)" \
  -H "Content-Type: application/json" \
  "https://designcenter.googleapis.com/v1alpha/$RESOURCE_PATH" > original-extract.json

#echo "Done! You can view the output by running: cat original-extract.json"

# This command reads your source file, extracts the inner object, 
# and wraps it in the correct key name for the Import API.
jq '{serialized_application_template: .serializedApplicationTemplate}' original-extract.json > import.json

echo "Done! You can view the output by running: cat import.json"

# Create a new bucket for the exported template
export BUCKET_NAME="${SOURCE_PROJECT_ID}-adc-templates"

# Create the bucket if it doesn't exist
echo "Creating bucket: $BUCKET_NAME..."
gsutil mb -p "$SOURCE_PROJECT_ID" "gs://$BUCKET_NAME"

gsutil -m cp -r ./import.json gs://$BUCKET_NAME/templates/$SOURCE_APP_TEMPLATE/

echo "Cleaning Up.."

rm -rf original-extract.json

echo "Done"