# Gmasiero Skills

My agent skills for daily engineering and productivity work.

To (re)link all skills into local harness directories (`~/.claude/skills`, `~/.agents/skills`):

```bash
./scripts/link-skills.sh
```

## Reference

### Engineering

Skills I use daily for code work.

**User-invoked**

- **[ticket](./skills/engineering/ticket/SKILL.md)** — Take a YouTrack issue end to end: interview it into a spec, hand it to a lele agent in a Herdr worktree/pane, verify, open the GitLab MR.
- **[to-spec](./skills/engineering/to-spec/SKILL.md)** — Turn the current conversation into a spec and publish it to the project issue tracker.
- **[wayfinder](./skills/engineering/wayfinder/SKILL.md)** — Plan a huge chunk of work as a shared map of investigation tickets on your issue tracker.

**Model-invoked**

- **[check-branches-from-test](./skills/engineering/check-branches-from-test/SKILL.md)** — Analyze remote branches not yet merged into test and judge whether each still adds value.
- **[klens-fe-labels-pipeline](./skills/engineering/klens-fe-labels-pipeline/SKILL.md)** — Sync i18n keys between klens-frontend and labels repos, add en-US/it-IT translations, and prepare commits.
- **[lele-exec](./skills/engineering/lele-exec/SKILL.md)** — Drive lele as an execution harness — loop iteratively toward a spec.

### Productivity

General workflow tools, not code-specific.

- **[auto-document](./skills/productivity/auto-document/SKILL.md)** — Keep automatic work notes in Obsidian during tasks.
- **[caveman](./skills/productivity/caveman/SKILL.md)** — Ultra-compressed communication mode.
- **[find-skills](./skills/productivity/find-skills/SKILL.md)** — Help users discover and install agent skills.
- **[grill-me](./skills/productivity/grill-me/SKILL.md)** — Interview the user relentlessly about a plan or design.
- **[handoff](./skills/productivity/handoff/SKILL.md)** — Compact the current conversation into a handoff document.
- **[progress-relay](./skills/productivity/progress-relay/SKILL.md)** — Send short progress updates to Lele while work is running.
- **[self-reminder-memory](./skills/productivity/self-reminder-memory/SKILL.md)** — Set reminders and log them to memory.

## Credits

- **[to-spec](./skills/engineering/to-spec/SKILL.md)**, **[wayfinder](./skills/engineering/wayfinder/SKILL.md)**, **[caveman](./skills/productivity/caveman/SKILL.md)**, **[handoff](./skills/productivity/handoff/SKILL.md)** — from [mattpocock/skills](https://github.com/mattpocock/skills).
- **[grill-me](./skills/productivity/grill-me/SKILL.md)** — from [mattpocock/skills](https://github.com/mattpocock/skills), modified and opinionated to personal workflow.
