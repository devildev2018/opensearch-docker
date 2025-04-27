#!/bin/bash

set -e

OUTPUT_DIR="./certs"
IMAGE="opensearchproject/opensearch:latest"
SCRIPT_PATH="/usr/share/opensearch/plugins/opensearch-security/tools/securityadmin.sh"

echo "[*] Creating output directory at $OUTPUT_DIR..."
mkdir -p "$OUTPUT_DIR"

echo "[*] Pulling OpenSearch image if not already present..."
docker pull $IMAGE

echo "[*] Copying securityadmin.sh from container to host..."
CONTAINER_ID=$(docker create $IMAGE)
docker cp "$CONTAINER_ID:$SCRIPT_PATH" "$OUTPUT_DIR/securityadmin.sh"
docker rm "$CONTAINER_ID"

chmod +x "$OUTPUT_DIR/securityadmin.sh"

echo "[✓] securityadmin.sh copied to $OUTPUT_DIR/securityadmin.sh"
