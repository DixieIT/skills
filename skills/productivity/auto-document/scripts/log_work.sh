#!/usr/bin/env bash
set -euo pipefail

# Usage:
# log_work.sh "title" "summary" [repo_path]

TITLE="${1:-work update}"
SUMMARY="${2:-no summary}"
REPO="${3:-$PWD}"
VAULT="${NOTES_VAULT:-/home/gmasiero/.openclaw/workspace/notes}"
TODAY="$(date +%F)"
TIME="$(date +%H:%M)"
DAILY_FILE="$VAULT/daily/$TODAY.md"

mkdir -p "$VAULT/daily"

if [[ ! -f "$DAILY_FILE" ]]; then
  cat > "$DAILY_FILE" <<EOF
# $TODAY Daily

## Focus

## Work log

## Follow-ups

## Learnings

EOF
fi

CHANGED=""
if [[ -d "$REPO/.git" ]]; then
  CHANGED=$(git -C "$REPO" status --short 2>/dev/null | sed 's/^/- /' || true)
fi

{
  echo "- [$TIME] **$TITLE** — $SUMMARY"
  if [[ -n "$CHANGED" ]]; then
    echo "  - changed files:"
    echo "$CHANGED" | sed 's/^/    /'
  fi
} >> "$DAILY_FILE"

echo "$DAILY_FILE"
