# lele CLI

Entry point: `lele [flags]`

## Flags

| Flag | Description |
|------|-------------|
| `-p PROMPT` | One-shot prompt; runs headless, prints result, exits |
| `-a NAME` | Named agent from `.lele/agents/` (default: single agent) |
| `-s ID` | Session id to continue (or path to `.jsonl`) |
| `-r` | Resume last session for this cwd |
| `--list-sessions` | List saved sessions |
| `--debug` | Wire-level logging + live tmux pane |

## Modes

- **TUI** (no `-p`): interactive chat UI, slash commands, persistent
- **Headless** (`-p`): single-shot, print result and exit. Use for one lele call in a loop.

## Iteration

- `lele -p "<task>"` → prints result + session id
- `lele -p -s <id> "<next instruction>"` → continues that session
- `-r` resumes the most recent session for this cwd (less precise than `-s` once multiple runs exist)

## Named agents (-a)

Agents live in `.lele/agents/<name>/AGENTS.md` with YAML front-matter.
Fallback: lele's built-in agents: `explore`, `agent-smith`, `config-smith`.

Named agents only get `delegate`/`handoff` if their frontmatter activates them.
Default agent (no `-a`) has all skills active.
