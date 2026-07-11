# Session management

## Storage

Append-only JSONL files in `~/.lele/sessions/<session_id>.jsonl`.
Survives crashes, greppable, diffable.

## Session ID

Format: `YYYYMMDD_HHMMSS_<6-hex-chars>` — sortable timestamp + random suffix.
Printed at the end of every `lele -p` run.

```text
Result: ...
[session: 20260710_204234_d523a9]
```

## Continue a session

```bash
lele -p -s 20260710_204234_d523a9 "<next instruction>"
```

This loads the full conversation history so far and appends the new instruction.
The model sees everything from the previous run — no context loss.

## Resume last session (-r)

```bash
lele -p -r "<next instruction>"
```

Resumes the most recent session for this cwd.
Less precise than `-s` once multiple runs exist for the same project.

## List sessions

```bash
lele --list-sessions
```

Shows session id + first prompt excerpt.

## fork

TUI command: `/fork <message_index>` — copies session up to a chosen message into a new session id.
Useful for branching: "retry from that point with a different approach."

## Session lifecycle

- Auto-saved after each turn (both TUI and headless)
- Session start/end events are emitted to plugins
- Auto-compaction at 80% of context window: replaces earlier history with LLM summary
