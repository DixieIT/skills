# Gmasiero Skills

A collection of agent skills I use daily.

## Language

**Skill**:
A reusable agent capability — a `SKILL.md` file in one of the bucket folders, either user-invoked (slash command) or model-invoked (auto-reachable by the agent).

**Bucket**:
A category folder under `skills/` — `engineering/`, `productivity/`, `personal/`, `misc/`, `in-progress/`, `deprecated/`.

**Promoted bucket**:
`engineering/` or `productivity/` — skills here are listed in the top-level `README.md` and `.claude-plugin/plugin.json`.

**User-invoked skill**:
A skill with `disable-model-invocation: true` — only reachable by typing its slash command.

**Model-invoked skill**:
A skill without `disable-model-invocation` — reachable by the model automatically when the task fits, or by the user typing its name.
