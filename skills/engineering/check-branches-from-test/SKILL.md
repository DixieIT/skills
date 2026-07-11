---
name: check-branches-from-test
description: Analyze remote branches not yet merged into test, compare them against what is already in origin/test, and judge whether each open branch still adds practical value.
---

# Check Branches From Test

Use this skill when the user asks questions like:

- which branches are still outside `test`
- what is missing from `test`
- are open branches still useful to merge into `test`
- analyze branches detached from `test`

## Goal

Produce a decision-oriented analysis of branches not yet merged into `origin/test`.

Do not stop at listing branch names. Compare each branch with what already exists in `origin/test` and state whether it still looks useful.

## Default assumptions

- Base branch: `origin/test`
- Remote prefix: `origin/`
- Work on remote branches unless the user explicitly asks for local branches too.

## Primary command

List the relevant branches with:

```bash
~/.agents/skills/check-branches-from-test/scripts/list_test_gap_branches.sh [base-branch] [ref-prefix]
```

Examples:

```bash
~/.agents/skills/check-branches-from-test/scripts/list_test_gap_branches.sh
~/.agents/skills/check-branches-from-test/scripts/list_test_gap_branches.sh origin/test
~/.agents/skills/check-branches-from-test/scripts/list_test_gap_branches.sh origin/develop origin/
```

## Analysis workflow

1. Get the list of branches not merged into `origin/test`.
2. Inspect recent history on `origin/test` to understand what is already present.
3. For each open branch, inspect:
   - recent commits
   - diff summary against `origin/test`
   - touched areas/modules
   - whether it looks like feature, fix, hotfix, refactor, release, spike, or misc
4. Judge each branch against `origin/test`:
   - `useful`: clearly adds missing value
   - `maybe useful`: seems relevant but needs verification
   - `probably not useful`: likely obsolete, superseded, redundant, or risky for low value
5. Call out generic branches separately:
   - `develop`
   - `release/*`
   - long-lived integration branches

## Suggested git commands

Use only what is needed. Typical commands:

```bash
git branch -r --no-merged origin/test
git log --oneline --decorate -n 30 origin/test
git log --oneline --decorate -n 15 <branch>
git diff --stat origin/test...<branch>
git diff --name-only origin/test...<branch>
git merge-base origin/test <branch>
```

## Output format

Return a compact report with these sections:

### Branches analyzed

List all branches considered.

### Per-branch assessment

For each branch include:

- `Name`
- `Type`
- `What it adds`
- `Status vs test`: `useful` / `maybe useful` / `probably not useful`
- `Reason`
- `Risks or notes`

### Merge priority

Group branches under:

- `High`
- `Medium`
- `Low`

### Probably obsolete or already covered

List branches that appear superseded by `origin/test` or by other branches.

### Final recommendation

State:

- what should be evaluated for merge first
- what needs manual verification
- what can likely be ignored or closed

## Rules

- Be concrete and opinionated.
- Prefer practical usefulness over exhaustive commentary.
- If evidence is weak, say so explicitly.
- Give extra weight to fixes and hotfixes that close gaps already visible in `test`.
- Do not assume the branch name alone is enough; inspect commits and diff summary.
