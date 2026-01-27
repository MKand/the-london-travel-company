#!/bin/bash

# Configuration
ENDPOINT=${1:-"http://35.193.13.152/api"}  # Default to provided IP with /api prefix
AGENT_NAME="london_agent"
USER_ID="u_load_test"
ITERATIONS=${2:-5}  # Default to 5 iterations
SLEEP_TIME=${3:-1}  # Default to 1 second sleep between requests

echo "Starting load test on $ENDPOINT"
echo "Targeting $ITERATIONS iterations with $SLEEP_TIME second delay..."

for ((i=1; i<=ITERATIONS; i++))
do
    SESSION_ID="s_load_$(date +%s)_$i"
    echo "--- Iteration $i: $SESSION_ID ---"

    # Step 1: Create Session
    echo "Creating session..."
    CREATE_STATUS=$(curl -s -o /dev/null -w "%{http_code}" -X POST \
        "$ENDPOINT/apps/$AGENT_NAME/users/$USER_ID/sessions/$SESSION_ID" \
        -H "Content-Type: application/json" \
        -d '{}')

    if [ "$CREATE_STATUS" != "200" ]; then
        echo "Error: Failed to create session (HTTP $CREATE_STATUS)"
        continue
    fi

    # Step 2: Send Message
    echo "Sending message..."
    RESPONSE=$(curl -s -X POST "$ENDPOINT/run" \
        -H "Content-Type: application/json" \
        -d "{
          \"appName\": \"$AGENT_NAME\",
          \"userId\": \"$USER_ID\",
          \"sessionId\": \"$SESSION_ID\",
          \"newMessage\": {
            \"role\": \"user\",
            \"parts\": [{\"text\": \"Give me a quick tip for London travel iteration $i\"}]
          }
        }")

    echo "Response received."
    # echo "Response: $RESPONSE" # Uncomment to see full JSON

    sleep "$SLEEP_TIME"
done

echo "Load test complete."
