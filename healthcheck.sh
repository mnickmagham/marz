#!/bin/bash

# Health check script for Marzban
# This script checks if the application is running properly

MAX_RETRIES=30
RETRY_INTERVAL=2
API_URL="http://localhost:8000/api/system"

echo "Starting health check for Marzban..."

for i in $(seq 1 $MAX_RETRIES); do
    echo "Health check attempt $i/$MAX_RETRIES"
    
    # Check if the API endpoint is responding
    if curl -f -s "$API_URL" > /dev/null 2>&1; then
        echo "✅ Marzban is healthy and ready!"
        exit 0
    fi
    
    echo "⏳ Waiting for Marzban to be ready..."
    sleep $RETRY_INTERVAL
done

echo "❌ Health check failed after $MAX_RETRIES attempts"
exit 1
