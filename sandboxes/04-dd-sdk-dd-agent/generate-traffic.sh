#!/usr/bin/env bash
set -euo pipefail

BASE_URL="${1:-http://localhost:8080}"
ITERATIONS="${2:-50}"

echo "Sending $ITERATIONS rounds of requests to $BASE_URL ..."

for i in $(seq 1 "$ITERATIONS"); do
    curl -s "$BASE_URL/" > /dev/null
    curl -s "$BASE_URL/items" > /dev/null
    curl -s "$BASE_URL/items/1" > /dev/null
    curl -s "$BASE_URL/items/2" > /dev/null
    curl -s "$BASE_URL/items/999" > /dev/null          # 404
    curl -s "$BASE_URL/error" > /dev/null 2>&1 || true  # 500
    echo "  Round $i/$ITERATIONS complete"
    sleep 1
done

echo "Traffic generation complete. Check Datadog APM for traces."
