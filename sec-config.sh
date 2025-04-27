#!/bin/bash

IMAGE="opensearchproject/opensearch:latest"
CONTAINER_NAME="opensearch-temp"
OUTPUT_DIR="./securityconfig"

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Run a temporary container
docker run -d --name $CONTAINER_NAME $IMAGE tail -f /dev/null

# Wait a bit to ensure the container is up
sleep 5

# Path to security config files inside the container
CONTAINER_CONFIG_PATH="/usr/share/opensearch/config/opensearch-security/"

# Copy security config files to local machine
docker cp "$CONTAINER_NAME:$CONTAINER_CONFIG_PATH/." "$OUTPUT_DIR"

# Stop and remove the container
docker rm -f $CONTAINER_NAME

echo "✅ Default OpenSearch security configuration files copied to: $OUTPUT_DIR"
