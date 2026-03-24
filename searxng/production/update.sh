#!/bin/bash
echo "=== Update: $(date -u) ==="
cd ~/searxng
if ! docker compose pull 2>&1; then
    echo "ERROR: pull failed"
fi
docker compose up -d --remove-orphans
docker image prune -f
echo "=== Done: $(date -u) ==="
