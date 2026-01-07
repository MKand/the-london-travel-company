#!/bin/sh

# If API_BASE_URL is not set, use a default value for local dev or handle it
export API_BASE_URL=${API_BASE_URL:-http://localhost:8000}

echo "Injecting API_BASE_URL: $API_BASE_URL"

# Replace variables in the template and write to config.js
envsubst '${API_BASE_URL}' < /usr/share/nginx/html/config.template.js > /usr/share/nginx/html/config.js

# Start Nginx
nginx -g 'daemon off;'
