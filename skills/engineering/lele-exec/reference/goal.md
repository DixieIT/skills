# lele-goal plugin

Installed at `~/.lele/plugins/goal/`. Tracks a objective/status through a lele session.

## Tools (available to the model)

| Tool | Description |
|------|-------------|
| `create_goal({"objective": "..."})` | Set a new goal |
| `update_goal({"status": "active"\|"paused"\|"complete"})` | Change status |
| `get_goal({})` | Return `{"objective": "...", "status": "..."}` as JSON |

## Slash command (TUI only)

- `/goal <objective>` — set goal
- `/goal pause|resume|clear` — manage state
- `/goal` — show current

## Lifecycle behavior

After `/goal` is used, a `<harness>Session goal (active): "..."</harness>` note is injected into the next turn's context. The model sees it automatically.

## Usage for spec convergence

1. `create_goal({"objective": "<spec description>"})` — register the spec
2. Run work toward the spec
3. `get_goal({})` — check current state
4. `update_goal({"status": "complete"})` — mark done when spec is met

The goal inject is ephemeral per session — each `lele -p` call is a fresh session, so the goal must be re-set at the start of each call.
