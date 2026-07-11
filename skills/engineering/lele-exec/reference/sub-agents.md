# Sub-agents

lele has three sub-agent primitives, all availabile as native JSON tools.

## delegate

Synchronous sub-agent call. Blocks and returns result inline. Multiple `delegate` calls in the same turn run in parallel.

Use when: you need a result before continuing, and subtasks are independent enough to parallelize.

## handoff

Asynchronous background sub-agent. Returns an id immediately. Read results later via `collect <id>` (bash command).

Use when: the sub-agent runs independently and you check in later.

## Shared contract pattern

Before delegating to sub-agents, write the shared API/contract to a scratch file.
Point each sub-agent at it — independent sub-agents avoid diverging (one assumes PATCH, another PUT).
The scratch dir is per-project and shown in the env header.

## Default agent vs named agents

| | delegate | handoff |
|--|----------|---------|
| Default (no `-a`) | yes | yes |
| Named agent (`-a <name>`) | only if frontmatter activates it | same |

Named agents only get delegation if their `.lele/agents/<name>/AGENTS.md` frontmatter sets it.
