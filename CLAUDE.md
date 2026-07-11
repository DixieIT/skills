Skills are organized into bucket folders under `skills/`:

- `engineering/` — daily code work
- `productivity/` — daily non-code workflow tools
- `personal/` — tied to my own setup, not promoted
- `misc/` — kept around but rarely used, not promoted
- `in-progress/` — drafts not yet ready to ship
- `deprecated/` — no longer used

Every skill in `engineering/` or `productivity/` (the **promoted** buckets) must have a reference in the top-level `README.md` and an entry in `.claude-plugin/plugin.json`. Skills in `personal/`, `misc/`, `in-progress/`, and `deprecated/` must not appear in either.

Each skill entry in the top-level `README.md` must link the skill name to its `SKILL.md`.

Each bucket folder has a `README.md` that lists every skill in the bucket with a one-line description, with the skill name linked to its `SKILL.md`. The promoted buckets' `README.md`s and the top-level `README.md` group entries into **User-invoked** and **Model-invoked**; non-promoted bucket `README.md`s (`misc/`, `personal/`) use a flat list.

Every `SKILL.md` is either user-invoked (`disable-model-invocation: true`, reachable only by the human) or model-invoked (model- or user-reachable). See [.agents/invocation.md](./.agents/invocation.md).

No docs pages are published for this repo (no public-facing docs website).

To (re)link every skill into the local harness skill directories (`~/.claude/skills`, `~/.agents/skills`), run `scripts/link-skills.sh`. Each entry is a symlink into this repo, so a `git pull` keeps installed skills current; re-run the script after adding, removing, or renaming a skill.
