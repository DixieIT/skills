---
name: lele-exec
description: "Drive lele as an execution harness for an approved spec: feed the spec to lele, verify its output yourself, and iterate with session continuity (lele -p -s <id>) until the spec is met or 5 rounds fail. Trigger the moment a plan is approved — use this instead of implementing the plan directly."
argument-hint: "what should lele execute toward? (the spec, often an approved plan)"
---

You have a spec. lele is your execution arm. You own acceptance — lele's "done" is a claim you verify.

## Loop structure

```
spec → lele -p "<spec>" → verify → if pass: done
                                    if fail: lele -p -s <id> "failure: ..." → verify → ...
```

- Max 5 rounds, then escalate to the user
- Each round: one `lele -p` call, then one verify step
- Use lele-goal (`create_goal`) to register the spec inside each lele session so the inner model stays anchored to it

## Step by step

1. **Prepare the call** — the spec is already the prompt. Prepend `create_goal({"objective": "<spec gist>"}); then implement` so lele-goal anchors the session. Append any shared contracts from scratch dir if sub-agents are needed.

2. **Call lele** — `lele -p -a <name> "..."` if a project defines a named agent (e.g. orchestrator), else plain `lele -p "..."`. Capture the session id from the last line.

3. **Verify** — run the app, run tests, check outputs against the spec. "Done" from lele is a claim, not a result. Use concrete commands with expected vs actual output.

4. **Iterate or land** — if verification passes: done, report. If fail: `lele -p -s <id> "<command run, expected vs actual, any errors>"` and loop.

5. **Escalate** — after 5 rounds of failure-to-verify, stop. Report what was attempted, what broke, and the best next hypothesis. Do not loop beyond 5 without a human call.

## lele-goal

`create_goal`/`update_goal`/`get_goal` tools, active by default (no config). Details: `reference/goal.md`.

## Sub-agent orchestration

Let lele's own `delegate`/`handoff` tools fan out work inside a single session. Only spawn separate `lele -p` calls when subtasks genuinely can't share one session (different working dirs, or the user explicitly wants split). If using a named agent (`-a`), check its `AGENTS.md` frontmatter first — named agents only get delegation tools if their frontmatter activates them.

## Reference docs

See `reference/` for full details on CLI flags, plugins, sessions, sub-agents, and lele-goal.
