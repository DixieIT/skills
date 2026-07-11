#!/usr/bin/env bash
set -euo pipefail

# Usage:
#   notify_progress.sh start "Refactor started on module X"
#   notify_progress.sh milestone "Tests passed (12/12)"
#   notify_progress.sh done "Deploy completed"
#
# Env:
#   RELAY_URL   default: http://127.0.0.1:8787/chat
#   RELAY_TOKEN optional bearer token

STAGE="${1:-update}"
shift || true
MESSAGE="${*:-No details}"

RELAY_URL="${RELAY_URL:-http://127.0.0.1:8787/chat}"
RELAY_TOKEN="${RELAY_TOKEN:-}"

PAYLOAD=$(python - <<'PY' "$STAGE" "$MESSAGE"
import json,sys
stage=sys.argv[1]
msg=sys.argv[2]
text=f"[Progress/{stage}] {msg}"
print(json.dumps({"message": text}))
PY
)

if [[ -n "$RELAY_TOKEN" ]]; then
  curl -sS -X POST "$RELAY_URL" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer ${RELAY_TOKEN}" \
    -d "$PAYLOAD" >/dev/null
else
  curl -sS -X POST "$RELAY_URL" \
    -H "Content-Type: application/json" \
    -d "$PAYLOAD" >/dev/null
fi

echo "sent ${STAGE}: ${MESSAGE}"
