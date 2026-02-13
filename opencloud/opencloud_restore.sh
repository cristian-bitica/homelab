#!/bin/bash
set -euo pipefail

PROJECT_DIR="."
ENV_FILE="${PROJECT_DIR}/.env"

# Load .env
if [ -f "$ENV_FILE" ]; then
    export $(grep -v '^#' "$ENV_FILE" | xargs)
else
    echo ".env not found: $ENV_FILE"
    exit 1
fi

# Backup to restore (default = latest)
RESTORE_FROM="${1:-latest}"
SOURCE="${BACKUP_ROOT}/${RESTORE_FROM}"

if [ ! -d "$SOURCE" ]; then
    echo "Backup not found: $SOURCE"
    exit 1
fi

DEST_CONFIG="${OC_CONFIG_DIR:?OC_CONFIG_DIR not set}/"
DEST_DATA="${OC_DATA_DIR:?OC_DATA_DIR not set}/"

cd "$PROJECT_DIR"

echo "Stopping compose stack..."
docker compose stop

echo "Restoring config..."
rsync -aAX --delete \
    "${SOURCE}/config/" \
    "$DEST_CONFIG"

echo "Restoring data..."
rsync -aAX --delete \
    "${SOURCE}/data/" \
    "$DEST_DATA"

echo "Starting compose stack..."
docker compose start

echo "Restore completed from: $SOURCE"