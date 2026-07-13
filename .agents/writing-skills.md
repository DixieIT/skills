# Writing skills

A skill is a directory under `skills/` containing at minimum a `SKILL.md`. This guide covers how to write one that fits this repo's conventions.

## SKILL.md anatomy

Every `SKILL.md` has two parts:

**Frontmatter** (YAML between `---` delimiters):

```yaml
---
name: my-skill
description: "One-liner that determines who can invoke this skill."
---
```

- `name` — directory name, kebab-case. Matches the folder it lives in.
- `description` — the invocation trigger. See "Writing an accurate description" below.
- `disable-model-invocation: true` — set to make it user-invoked only (see [invocation.md](./invocation.md) for the full model).

**Body** — everything after the closing `---`. Markdown. Starts with the core instruction — what this skill does, when to reach for it. The reader is an agent with the full contents of this file injected as a system message, so the first paragraph should be the most actionable statement of purpose.

### Supplementary directories

| directory | purpose |
|-----------|---------|
| `reference/` | detail too deep for the body; see "Progressive disclosure" below |
| `scripts/` | shell/python scripts the skill's instructions reference |
| `assets/` | images, templates, example outputs |

All three are optional. A skill with no scripts or assets needs none of them.

## Writing an accurate description

The `description` field is the **sole trigger** for model-invoked skills — the model decides whether to activate based on it. Follow these rules:

- **Model-invoked** (the default): Write a trigger-rich description the model can pattern-match against. Use phrases like "Use when the user asks for…", "Use when…", "Analyze…", "Compare…". Examples from this repo:

  > Analyze remote branches not yet merged into test, compare them against what is already in origin/test, and judge whether each open branch still adds practical value.

  > Drive lele as an execution harness — loop iteratively toward a spec. Trigger as soon as a plan gets approved: instead of coding directly, feed the spec into lele, verify the result, and iterate with session continuity until the spec is met (or max rounds exhausted).

- **User-invoked** (`disable-model-invocation: true`): The description is **human-facing** — a concise one-liner the user reads in a command list. Strip model-trigger phrasing. Examples:

  > Turn the current conversation into a spec and publish it to the project issue tracker — no interview, just synthesis of what you've already discussed.

  > Plan a huge chunk of work — more than one agent session can hold — as a shared map of investigation tickets on your issue tracker, and resolve them one at a time until the way to the destination is clear.

Do not add a separate trigger list in the description body for model-invoked skills — the `description` field is the trigger. If a few concrete user phrasings help, list them *in the body* after the opening paragraph (see `check-branches-from-test` for an example).

## User-invoked vs model-invoked

See [invocation.md](./invocation.md) for the full model. The short version:

- **User-invoked** — `disable-model-invocation: true`. Only reachable when the human types its name. Description is human-facing.
- **Model-invoked** — default. Reachable by model or user. Description is model-facing with trigger phrasing.

This file does **not** restate the mechanics — read `invocation.md` for the canonical explanation, the rules around chaining, and how bucket READMEs group entries.

## Progressive disclosure

A `SKILL.md` body is a system message — it's injected in full every time the skill fires. Keep it short enough to read in seconds.

Push the following into `reference/` files:

- **CLI reference** — every flag, every option. The body says "See reference/cli.md".
- **Plugin internals** — how a plugin works under the hood, not how to use it.
- **Edge cases** — rare configurations, migration paths, troubleshooting.
- **Historical context** — why a decision was made, not what the decision is.

Keep in the body:

- **The core loop** — what happens, in what order.
- **Required contracts** — things the agent **must** do (call this API, check this file, run this command).
- **Rules** — non-negotiable constraints.
- **Defaults** — what to assume when the user doesn't specify.

Good example: `lele-exec/SKILL.md` — the body covers the loop structure and step-by-step; the last line points to `reference/` for flags, plugins, sessions, sub-agents.

## Tone convention

This repo's skills are written in a consistent voice: **terse, imperative, no filler**. Read `skills/engineering/lele-exec/SKILL.md` and `skills/engineering/to-spec/SKILL.md` — both demonstrate it.

Rules of thumb:

- Start with a direct statement of purpose. "You have a spec. lele is your execution arm." Not "This skill is designed to help you execute specs using lele."
- Use imperatives: "List the relevant branches", not "You should list the relevant branches".
- Omit meta-commentary like "In this section, we will cover" — just write the section.
- Headings are short nouns or verb phrases: "Loop structure", "Step by step", not "Understanding the loop structure".
- One sentence per point is usually enough. Two signals an opportunity to trim.
- Code blocks render literally — use them for commands, templates, expected output.

The `caveman` skill (`skills/productivity/caveman/SKILL.md`) is an extreme expression of the same instinct — readable as a reference for *how* the repo compresses communication, not a style to match verbatim.

## Bundled skill-creator

This repo includes a `build-exe` skill in the harness for drafting and testing new skills. Run `load-skill build-exe` to load it.
