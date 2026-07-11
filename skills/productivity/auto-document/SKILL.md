---
name: auto-document
description: Keep automatic work notes in Obsidian during tasks. Use when starting/finishing coding or ops work to append concise progress logs, changed files, and outcomes into the notes vault daily file.
---

# Auto Document

Use this skill to keep a clean work trail in Obsidian notes.

## Vault

Default vault path:
- `/home/gmasiero/.openclaw/workspace/notes`

Override with env:
- `NOTES_VAULT=/path/to/vault`

## Command

```bash
~/.agents/skills/auto-document/scripts/log_work.sh "title" "summary" [repo_path]
```

Examples:

```bash
~/.agents/skills/auto-document/scripts/log_work.sh "start" "Begin task: fix F5 status error" /home/gmasiero/.openclaw/workspace/openclaw-command-center
~/.agents/skills/auto-document/scripts/log_work.sh "done" "Patched live status + tests passed" /home/gmasiero/.openclaw/workspace/openclaw-command-center
```

## Rules

- Log at least `start` and `done` for multi-step work.
- Keep summaries short and factual.
- Include repo path when task is code-related.
