#!/usr/bin/env bash
# Mechanical glue for /ticket steps 5-7b: create the herdr worktree, start lele
# on it, set the goal, and tell it to start. Grilling the spec, picking the
# base branch, watching/nudging/verifying, and landing the MR stay manual —
# this only removes the JSON-parsing/id-threading chores around setup.
set -euo pipefail

usage() {
  cat >&2 <<'EOF'
Usage: spinup-lele.sh <ISSUE_ID> <BASE_BRANCH> <BRANCH_NAME> <REPO_PATH> <SPEC_FILE> [START_MESSAGE]

  ISSUE_ID       e.g. KIT-6 — used as the herdr worktree/agent label
  BASE_BRANCH    branch to fork the worktree from (develop, main, ...)
  BRANCH_NAME    full branch name for the new worktree, e.g. feature/KIT-6-min-fix-ui
  REPO_PATH      path to the herdr-registered source repo checkout to branch
                 from — always passed explicitly as --cwd. Never omit this:
                 herdr's default context resolution is ambient (whatever
                 pane/session it picks), not "this shell's cwd" — that's how
                 an unscoped call can land on the wrong repo, or worse, the
                 same pane the current agent is running in.
  SPEC_FILE      path to a file containing the full spec text (sent as "/goal <contents>")
  START_MESSAGE  optional; defaults to a generic "start now" nudge

Prints a JSON object {tab_id, pane_id, checkout_path} on success — feed these
into the watch/verify steps (herdr pane read, herdr wait output, ...) yourself.
EOF
  exit 1
}

[ "$#" -ge 5 ] || usage
command -v herdr >/dev/null || { echo "herdr not found on PATH" >&2; exit 1; }
command -v jq >/dev/null || { echo "jq not found on PATH" >&2; exit 1; }

ISSUE_ID=$1
BASE_BRANCH=$2
BRANCH_NAME=$3
REPO_PATH=$4
SPEC_FILE=$5
START_MESSAGE=${6:-"Implementa ora quanto descritto nel goal, poi fai commit."}

[ -d "$REPO_PATH" ] || { echo "repo path not found: $REPO_PATH" >&2; exit 1; }
[ -f "$SPEC_FILE" ] || { echo "spec file not found: $SPEC_FILE" >&2; exit 1; }
SPEC_TEXT=$(cat "$SPEC_FILE")

echo "Creating worktree ${BRANCH_NAME} (base ${BASE_BRANCH}, repo ${REPO_PATH})..." >&2
WORKTREE_JSON=$(herdr worktree create --cwd "$REPO_PATH" --branch "$BRANCH_NAME" --base "$BASE_BRANCH" --label "$ISSUE_ID" --no-focus --json)
TAB_ID=$(jq -r '.result.tab.tab_id // empty' <<<"$WORKTREE_JSON")
CHECKOUT_PATH=$(jq -r '.result.worktree.path // empty' <<<"$WORKTREE_JSON")
ROOT_PANE_ID=$(jq -r '.result.root_pane.pane_id // empty' <<<"$WORKTREE_JSON")
if [ -z "$TAB_ID" ] || [ -z "$CHECKOUT_PATH" ]; then
  echo "could not read tab_id/checkout_path from worktree create output:" >&2
  echo "$WORKTREE_JSON" >&2
  exit 1
fi

echo "Starting lele on tab ${TAB_ID} at ${CHECKOUT_PATH}..." >&2
# `agent start` always opens its own pane regardless of --split, so the
# worktree's root pane (a bare, unused shell) is left sitting next to it.
# Verification (step 8) happens from the orchestrator's own shell against
# $CHECKOUT_PATH, not a dedicated pane, so that root pane is dead weight —
# close it explicitly below once lele's pane is confirmed up.
# `agent start` has no --json flag (unlike `worktree create`) but emits JSON regardless.
AGENT_JSON=$(herdr agent start "$ISSUE_ID" --tab "$TAB_ID" --cwd "$CHECKOUT_PATH" --no-focus -- lele)
PANE_ID=$(jq -r '.result.agent.pane_id // empty' <<<"$AGENT_JSON")
if [ -z "$PANE_ID" ]; then
  echo "could not read pane_id from agent start output:" >&2
  echo "$AGENT_JSON" >&2
  exit 1
fi

if [ -n "$ROOT_PANE_ID" ] && [ "$ROOT_PANE_ID" != "$PANE_ID" ]; then
  echo "Closing the now-unused root pane ${ROOT_PANE_ID}..." >&2
  herdr pane close "$ROOT_PANE_ID"
fi

echo "Waiting for lele's TUI to come up before sending anything..." >&2
sleep 5

echo "Setting goal on pane ${PANE_ID}..." >&2
herdr pane send-text "$PANE_ID" "/goal ${SPEC_TEXT}"
herdr pane send-keys "$PANE_ID" enter
sleep 2

echo "Telling lele to start..." >&2
herdr pane send-text "$PANE_ID" "$START_MESSAGE"
herdr pane send-keys "$PANE_ID" enter

jq -n --arg tab "$TAB_ID" --arg pane "$PANE_ID" --arg path "$CHECKOUT_PATH" \
  '{tab_id: $tab, pane_id: $pane, checkout_path: $path}'
