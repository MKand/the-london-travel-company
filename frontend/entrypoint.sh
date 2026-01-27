#!/bin/sh

# If API_BASE_URL is not set, use a default value for local dev or handle it
export API_BASE_URL=${API_BASE_URL:-http://localhost:8000}

# Automatically detect the system DNS resolver
export DNS_RESOLVER=$(grep nameserver /etc/resolv.conf | head -n1 | awk '{print $2}')
export DNS_RESOLVER=${DNS_RESOLVER:-8.8.8.8}

echo "Injecting API_BASE_URL: $API_BASE_URL"
echo "Detected DNS_RESOLVER: $DNS_RESOLVER"

# Replace variables in the template and write to config.js
envsubst '$API_BASE_URL' < /usr/share/nginx/html/config.template.js > /usr/share/nginx/html/config.js

# Replace variables in the nginx config template (must use commas or $VAR syntax for multiple)
envsubst '$API_BASE_URL,$DNS_RESOLVER' < /etc/nginx/conf.d/default.conf.template > /etc/nginx/conf.d/default.conf

# Start Nginx
nginx -g 'daemon off;'
