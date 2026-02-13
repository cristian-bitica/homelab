#!/bin/bash
set -euo pipefail

PROJECT_DIR="."
ENV_FILE="${PROJECT_DIR}/.env"
BACKUP_ROOT="/media/backup/opencloud_backup"

# Load environment
if [ -f "$ENV_FILE" ]; then
    export $(grep -v '^#' "$ENV_FILE" | xargs)
else
    echo ".env not found: $ENV_FILE"
    exit 1
fi

SRC_CONFIG="${OC_CONFIG_DIR:?OC_CONFIG_DIR not set}/"
SRC_DATA="${OC_DATA_DIR:?OC_DATA_DIR not set}/"

TIMESTAMP=$(date +"%Y%m%d-%H%M")
DEST="${BACKUP_ROOT}/${TIMESTAMP}"
LATEST="${BACKUP_ROOT}/latest"

mkdir -p "$DEST"
cd "$PROJECT_DIR"

echo "Stopping compose stack..."
docker compose stop

echo "Running rsync..."
rsync -aAX --delete \
  --link-dest="$LATEST/config" \
  "$SRC_CONFIG" "$DEST/config"

rsync -aAX --delete \
  --link-dest="$LATEST/data" \
  "$SRC_DATA" "$DEST/data"

echo "Starting compose stack..."
docker compose start

echo "Updating latest symlink..."
rm -f "$LATEST"
ln -s "$DEST" "$LATEST"

echo "Cleaning backups older than 14 days..."
find "$BACKUP_ROOT" -mindepth 1 -maxdepth 1 -type d -mtime +14 ! -name "latest" -exec rm -rf {} +

echo "Backup completed: $DEST"