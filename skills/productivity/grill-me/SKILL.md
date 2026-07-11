---
name: grill-me
description: Interview the user relentlessly about a plan or design until reaching shared understanding, resolving each branch of the decision tree. Use when user wants to stress-test a plan, get grilled on their design, or mentions "grill me".
---

Interview me relentlessly about every aspect of this plan until we reach a shared understanding. Walk down each branch of the design tree, resolving dependencies between decisions one-by-one. For each question, provide your recommended answer.

Ask the questions one at a time.

If a question can be answered by exploring the codebase, explore the codebase instead.

## After the plan is finalized

Once we reach shared understanding and the implementation plan is settled, do this automatically:

1. **Guard the base branch.** Read the current branch (`git branch --show-current`). If it is `main`, `master`, `test`, or `develop`, STOP — do not touch YouTrack or create a branch. Tell the user to switch to a feature branch first.

2. **Resolve the issue key.** Extract the YouTrack key from the branch name (pattern `[A-Z]+-\d+`, e.g. `feature/KL-2505-audit` → `KL-2505`). A feature branch always maps to an existing issue — if no key is in the name, search YouTrack (`mcp__plugin_youtrack_youtrack__search_issues`) or ask the user for the key. Never create an issue.

3. **Prettify the plan into the issue.** Format the finalized plan as clean Markdown (summary, decisions made, step-by-step tasks) and write it to that issue via `mcp__plugin_youtrack_youtrack__update_issue` (description). Confirm the write.

4. **Cut the agent branch.** From the current feature branch, create and checkout `agent-feature/<name>`, where `<name>` is the current branch name with any leading type prefix stripped (`feature/`, `fix/`, `bugfix/`, etc.) — so both `KL-2552-refactor-audit-portal` and `feature/KL-2552-refactor-audit-portal` become `agent-feature/KL-2552-refactor-audit-portal`. If it already exists, just check it out.
