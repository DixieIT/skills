---
name: progress-relay
description: Send short progress updates to Lele while work is running. Use when tasks are multi-step, take more than a few seconds, or involve background work. Sends start/milestone/done/error updates through the local FastAPI relay so BibiBot chat receives live status.
---

# Progress Relay

Use this skill to keep Lele updated in real time during longer operations.

## When to send updates

Always send these checkpoints:
1. **start**: right before work begins
2. **milestone**: when a meaningful step completes
3. **done**: when task is complete
4. **error**: if blocked/failing

Keep updates short and concrete.

## Command

Script path:
- `~/.agents/skills/progress-relay/scripts/notify_progress.sh`

Examples:

```bash
~/.agents/skills/progress-relay/scripts/notify_progress.sh start "Starting refactor for openclaw-command-center"
~/.agents/skills/progress-relay/scripts/notify_progress.sh milestone "Backend relay running and health check OK"
~/.agents/skills/progress-relay/scripts/notify_progress.sh done "Task completed and tests passed"
```

## Relay config

Defaults:
- `RELAY_URL=http://127.0.0.1:8787/chat`
- `RELAY_TOKEN` optional

If token is required, export it before sending:

```bash
export RELAY_TOKEN="bibi-relay-local"
```

## Message style

- one line
- no fluff
- include what changed and current state
- avoid spam: only start + major milestone(s) + done/error
