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
        → worktree + lele attached → send-text "/goal <spec>" + send-keys enter
        → send-text "implement it now" + send-keys enter → wait for "Goal achieved" → verify from your own shell
        → if pass: glab mr create, done
          if fail: send-text "failure: ..." + send-keys enter → wait → ...
```

- Set lele's goal yourself with the `/goal <objective>` command — this is a real command from lele's own `goal` plugin, not a request you write into a prose prompt. Running `/goal <spec>` sets the objective and shows a persistent "Pursuing goal (…)" status line in the pane, and arms lele's own reminder to call `update_goal({"status": "complete"})` once it's done — no need to ask lele for that in your own words.
- **`/goal` only records the objective — it does not tell lele to start working.** Sending `/goal <spec>` alone leaves lele sitting idle with a "Pursuing goal" banner and nothing running. Always follow it with a second, separate message telling lele to actually start (e.g. "Implementa ora la feature descritta nel goal: ... poi fai commit."). (Confirmed by running this skill for real: after `/goal` alone, lele's pane stayed idle — the user had to point out nothing had started.)
- This keeps the whole task transparent and steerable: check the goal's status any time by reading the pane's banner text — `Pursuing goal (…` while running, `Goal achieved (✓ …` once done — and stay free to redirect lele directly throughout. `get_goal`/`update_goal` are tools lele calls itself — you never invoke them, you only read their rendered effect in the pane. (Confirmed by running this skill for real: the user finds this hands-on style clearer than handing the whole task to an autonomous multi-hat loop preset, which once stopped mid-task with no visible error while lele quietly kept working via a self-created goal fallback.)
- Talk to lele's pane with `herdr pane send-text <pane_id> "<text>"` followed by `herdr pane send-keys <pane_id> enter` as two separate calls — treat this as the reliable way to submit text. (Confirmed by running this skill for real, twice: `herdr agent send` only types and never submits; `herdr pane run` has also silently failed to submit anything, with no error and no "[Pasted]" placeholder, in the same session where send-text+send-keys worked immediately after. Always read the pane back after sending to confirm the text actually landed before moving on.)
- Wait on the literal text `Goal achieved` — that's the plugin's own rendered status once lele calls `update_goal({"status": "complete"})`. There's no separate way to cross-check it yourself; treat the rendered text as the signal and verify the actual work independently instead (git log, running the app), not lele's internal goal state.
- Nudge lele directly with a concrete fix whenever it looks stuck (e.g. re-deriving a library API from compiled internals, wrong tool/Node version) — point it at the right command or the right file to model after, then let it continue. Staying hands-on like this is the whole point of driving lele through `/goal` instead of an autonomous preset.

## Step by step

1. **Resolve the issue** — extract the leading issue key (`[A-Z]+-\d+`) from $ARGUMENTS; ignore any trailing title text you were pasting for your own reference. `get_issue` to pull it.

2. **Grill it into a spec** — always, even if the ticket looks complete. Run a `/grilling`-style interview with the user, one question at a time, until the ticket's intent, scope, and acceptance criteria are pinned down as a real spec. This is the point of the workflow: minimal tickets don't get charged at blind.

3. **Write the spec back** — `add_issue_comment` with the finished spec. Never touch the description; the comment is the record of how the ticket got sharpened.

4. **Pick the base branch** — ask the user which branch to base off. Repos vary (main, develop, test); don't guess from `main`/`master` alone.

5-7b. **Spin up the worktree + lele, armed with the goal** — mechanical glue for creating the worktree, starting lele on it, setting `/goal`, and telling it to start. Before writing the spec file, fold in whatever environment/toolchain quirks you already know about this repo (required Node/nvm version, "fresh worktrees need `npm install` first", any non-obvious setup step) — lele starts from zero in a brand-new worktree and will otherwise burn rounds rediscovering them itself. Run `scripts/spinup-lele.sh <ISSUE-ID> <chosen-branch> feature/<ISSUE-ID>-<slug> <repo-path> <spec-file> [start-message]` — write the finished spec (plus that environment context) to a temp file, then pass that file's path (it's sent verbatim as `/goal <contents>`). `<repo-path>` is the herdr-registered source repo checkout — always pass it explicitly, herdr's context resolution isn't "this shell's cwd" and an unscoped call can land the worktree on the wrong repo. Prints `{tab_id, pane_id, checkout_path}` on success. If the native worktree helper doesn't fit the repo's layout, fall back to `git fetch origin <chosen-branch>` + `git worktree add` and do the rest by hand.

    The script only sends — it does not confirm. Read the pane back yourself (`herdr pane read`) to verify the banner shows `Pursuing goal (…` and that it's moved on to working before starting the background wait in step 8.

8. **Watch and steer** — run `herdr wait output "<lele_pane_id>" --match "Goal achieved" --timeout <N>` in the background and follow it with the Monitor tool (or a background Bash task). Check in on the pane periodically with `herdr pane read`/`herdr agent read` while it runs; the moment lele looks stuck, send it a concrete nudge with `send-text`+`send-keys enter` — point it at the fix (the right command, the right file to model after) and let it continue. `get_goal`/`update_goal` are tools inside lele's own session, not something you call directly — you only ever see the goal's state by reading the pane's rendered banner text: `Pursuing goal (…` while running, `Goal achieved (✓ …` once done. When "Goal achieved" fires (or you've steered it to a clear stopping point):
   - `herdr agent read "<ISSUE-ID>"` to see what lele did and its final report.
   - Verify independently from your own shell, `cd`'d into `<checkout_path>` — run the app, run tests, check outputs against the spec, check `git status`/`git log` for actual commits. Treat lele's self-report as a claim to confirm, not a result to trust outright.
   - Pass → step 9. Fail (max 5 rounds total) → send-text+send-keys the failure to `<lele_pane_id>` (command run, expected vs actual, any errors), then back to the background wait.

9. **Land it, or escalate** — verified pass: `glab mr create` targeting the chosen base branch, title/body including the issue id (e.g. `KL-2322: <summary>`) so it cross-references the ticket even without smart-commit integration. 5 failed rounds without a pass: stop instead, leave the pane open, and report the tab label, branch, and your best next hypothesis — do not loop beyond 5 without a human call.

10. **Report and step back** — tab label, branch, and MR link (or the escalation above). Don't babysit the pane; you'll check in via the tab bar or the next Monitor notification.
