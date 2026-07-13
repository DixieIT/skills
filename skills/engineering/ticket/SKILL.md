---
name: ticket
description: Take a YouTrack issue end to end — interview it into a real spec, hand it to a lele agent running in its own Herdr worktree/pane, verify the result yourself, and open the GitLab MR.
argument-hint: "<YouTrack issue id or pasted ref, e.g. KL-2322 SS Fase 3>"
disable-model-invocation: true
---

Issue ref: $ARGUMENTS

You own this ticket end to end. The steps below pin down the YouTrack/Herdr/GitLab wiring — worktrees, verification, and MRs aren't new to you.

## Loop structure

```
issue id → get_issue → grill into a spec → post spec as comment
        → worktree (own tab+pane) + split lele off it → pane run "/ralph spec-driven <spec>"
        → wait for "LOOP_COMPLETE" → verify in shell pane → if pass: glab mr create, done
                                                              if fail: pane run "failure: ..." → wait → ...
```

- Max 5 rounds of send/verify at the orchestration level, then escalate to the user. Inside each round, lele's own `ralph` plugin retries/fixes internally (up to its preset's `max_iterations`) — you're not the one re-sending every failed test.
- lele runs once, interactively, in its own pane — no session id to track; `herdr pane run` just keeps talking to the same conversation
- Always use `herdr pane run <pane_id> "<text>"` to talk to lele's pane, never `herdr agent send` — `agent send` only types the text into the input box, it does **not** submit it (confirmed by running this skill for real: the spec sat unsent until an explicit Enter). `pane run` types and submits in one call.
- Prefer `ralph`'s literal `LOOP_COMPLETE` marker over `herdr`'s `agent-status`/`idle` as the completion signal — `idle` just means the pane stopped streaming, which is ambiguous (mid-thought pause vs. actually done) whereas `LOOP_COMPLETE` is an explicit, unambiguous signal from the loop itself.

## Step by step

1. **Resolve the issue** — extract the leading issue key (`[A-Z]+-\d+`) from $ARGUMENTS; ignore any trailing title text you were pasting for your own reference. `get_issue` to pull it.

2. **Grill it into a spec** — always, even if the ticket looks complete. Run a `/grilling`-style interview with the user, one question at a time, until the ticket's intent, scope, and acceptance criteria are pinned down as a real spec. This is the point of the workflow: minimal tickets don't get charged at blind.

3. **Write the spec back** — `add_issue_comment` with the finished spec. Never touch the description; the comment is the record of how the ticket got sharpened.

4. **Pick the base branch** — ask the user which branch to base off. Repos vary (main, develop, test); don't guess from `main`/`master` alone.

5. **Create the worktree** — `herdr worktree create --branch feature/<ISSUE-ID>-<slug> --base <chosen-branch> --label <ISSUE-ID>`. This spins up its own workspace + tab, with a root pane already sitting at the worktree cwd — that root pane *is* your shell pane, don't create a separate tab for it. If the native helper doesn't fit the repo's layout, fall back to `git fetch origin <chosen-branch>` + `git worktree add`.

6. **Split lele off the worktree's root pane** — `herdr agent start "<ISSUE-ID>" --tab <tab_id> --cwd <worktree_path> --split right --no-focus -- lele`, where `<tab_id>` is the tab `worktree create` just returned. lele runs in TUI mode, one persistent session for the whole ticket. The root pane stays a plain shell — this is where you run your own verification commands, not lele's.

7. **Hand off the spec via ralph** — `herdr pane run "<lele_pane_id>" "/ralph spec-driven <the spec from step 2>"`. The `spec-driven` preset (Specifier → Implementer → Verifier → Committer) drives lele through its own write/implement/verify/commit cycle, retrying failed items internally instead of bouncing every failure back to you. Pick a different preset (`/ralph presets` to list) if the ticket is a better fit for `debug` or `refactor`.

8. **Oversee, don't poll** — run `herdr wait output "<lele_pane_id>" --match "LOOP_COMPLETE" --timeout <N>` in the background and watch it with the Monitor tool. When it fires:
   - `herdr agent read "<ISSUE-ID>"` to see what ralph committed and its final report.
   - Verify independently in the shell pane (or via `herdr pane run` against the shell pane) — run the app, run tests, check outputs against the spec. ralph's `LOOP_COMPLETE` is a claim, not a result; its Verifier hat is the same model checking its own work, not an outside check.
   - Pass → step 9. Fail → `herdr pane run "<lele_pane_id>" "<command run, expected vs actual, any errors>"` (this re-enters the loop lele was already in, so ralph can pick it up), then back to the background wait.

9. **Escalate** — after 5 failed rounds, stop. Report the tab label, branch, and your best next hypothesis. Leave the pane open; do not loop beyond 5 without a human call.

10. **Land it** — once verified, `glab mr create` targeting the chosen base branch. Title and body include the issue id (e.g. `KL-2322: <summary>`) so it cross-references the ticket even without smart-commit integration.

11. **Report and step back** — tab label, branch, MR link. Don't babysit the pane; you'll check in via the tab bar or the next Monitor notification.
