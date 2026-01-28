#!/bin/bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail

# --- CONFIGURATION ---
JSON_FILE="import.json"
OUTPUT_FILE="import_substituted.json"

# --- USAGE ---
usage() {
    echo "Usage: $0 <DEST_PROJECT_ID> <DEST_SPACE_ID> [<SOURCE_PROJECT_ID>] [<SOURCE_SPACE_ID>]"
    echo ""
    echo "This script performs target substitution and imports it to Google Cloud Design Center."
    echo ""
    echo "Arguments:"
    echo "  DEST_PROJECT_ID:   The Google Cloud Project where you want to import the template."
    echo "  DEST_SPACE_ID:     The Design Center Space where you want to import the template."
    echo "  SOURCE_PROJECT_ID: (Optional) The Project ID referenced in the source JSON (default: 'SOURCE_PROJECT_ID')."
    echo "  SOURCE_SPACE_ID:   (Optional) The Space ID referenced in the source JSON (default: 'default-space')."
    echo ""
    echo "Example (explicit): $0 my-dest-123 my-dest-space my-source-456 my-source-space"
    echo "Example (defaults): $0 my-dest-123 my-dest-space"
    exit 1
}

# --- VALIDATION AND ASSIGNMENT ---
if [ "$#" -eq 2 ]; then
    DEST_PROJECT_ID=$1
    DEST_SPACE_ID=$2
    SOURCE_PROJECT_ID="SOURCE_PROJECT_ID"
    SOURCE_SPACE_ID="default-space"
elif [ "$#" -eq 4 ]; then
    DEST_PROJECT_ID=$1
    DEST_SPACE_ID=$2
    SOURCE_PROJECT_ID=$3
    SOURCE_SPACE_ID=$4
else
    echo "Error: Invalid number of arguments."
    usage
fi

if [ ! -f "$JSON_FILE" ]; then
    echo "Error: Input file '$JSON_FILE' not found."
    exit 1
fi

# Ensure jq is installed for extraction
if ! command -v jq &> /dev/null; then
    echo "Error: 'jq' is not installed. Please install it to continue."
    exit 1
fi

# --- EXTRACTION ---
# Extract Location and Template ID from the source JSON
LOCATION=$(jq -r '.serialized_application_template.uri' "$JSON_FILE" | grep -oP 'locations/\K[^/]+')
APPLICATION_TEMPLATE_ID=$(jq -r '.serialized_application_template.uri' "$JSON_FILE" | grep -oP 'applicationTemplates/\K[^/]+')

if [[ -z "$LOCATION" || -z "$APPLICATION_TEMPLATE_ID" || "$LOCATION" == "null" ]]; then
    echo "Error: Could not extract LOCATION or APPLICATION_TEMPLATE_ID from $JSON_FILE"
    exit 1
fi

# --- EXECUTION ---
echo "------------------------------------------------"
echo "Starting targeted substitution..."
echo "  Input:       $JSON_FILE"
echo "  Output:      $OUTPUT_FILE"
echo "  Project:     $SOURCE_PROJECT_ID -> $DEST_PROJECT_ID"
echo "  Space:       $SOURCE_SPACE_ID -> $DEST_SPACE_ID"
echo "  Location:    $LOCATION"
echo "  Template ID: $APPLICATION_TEMPLATE_ID"

# Perform substitutions
sed "s|projects/${SOURCE_PROJECT_ID}|projects/${DEST_PROJECT_ID}|g" "$JSON_FILE" | \
sed "s|/spaces/${SOURCE_SPACE_ID}|/spaces/${DEST_SPACE_ID}|g" > "$OUTPUT_FILE"

echo "------------------------------------------------"
echo "Substitution complete."
echo "Created: $OUTPUT_FILE"
echo "------------------------------------------------"

# --- API IMPORT ---
export API_ENDPOINT="designcenter.googleapis.com"
export PROJECT_ID="$DEST_PROJECT_ID"
export SPACE_ID="$DEST_SPACE_ID"
export LOCATION
export APPLICATION_TEMPLATE_ID

echo "Importing application template configuration..."
envsubst < "$OUTPUT_FILE" | curl -X POST \
  "https://${API_ENDPOINT}/v1alpha/projects/${PROJECT_ID}/locations/${LOCATION}/spaces/${SPACE_ID}/applicationTemplates/${APPLICATION_TEMPLATE_ID}:import" \
  -H "Authorization: Bearer $(gcloud auth print-access-token)" \
  -H "Content-Type: application/json" \
  -d @-

echo ""
echo "------------------------------------------------"
echo "Done."
echo "------------------------------------------------"