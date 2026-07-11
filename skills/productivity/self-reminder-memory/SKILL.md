---
name: self-reminder-memory
description: Reliable reminders with OpenClaw cron plus memory logging. Use when user asks to remember something or set reminders ("ricordami", "remind me", "tra X minuti", "domani alle"). Always schedule via cron for timed reminders, then log to memory as context backup.
---

# Self Reminder Memory (Cron-first)

Use OpenClaw cron as the source of truth for timed reminders.

## Mandatory workflow

1. Parse reminder intent and time.
2. If time is specified, create cron job **first**.
3. Log reminder to `memory/YYYY-MM-DD.md`.
4. For stable long-term preferences/rules, also update `MEMORY.md`.
5. Confirm with: reminder text, due time, and cron `jobId`.

## Cron policy

- Timed reminders: always `cron.add` with:
  - `sessionTarget: "main"`
  - `payload.kind: "systemEvent"`
- Prefer one-shot schedule:
  - `schedule: {"kind":"at","at":"<ISO-8601>"}`
- Reminder payload text must be user-facing and explicit, e.g.:
  - `Promemoria: <testo>. Questo è il reminder che mi hai chiesto <contesto tempo>.`

## Time precision (critical)

Follow this exact sequence to avoid timezone/drift mistakes:

1. Get current local time via `session_status` (Europe/Rome runtime truth).
2. Convert user delay to a target timestamp from that runtime time (e.g., `+1 minute`).
3. Use an explicit offset in `schedule.at` (`+01:00` or `+02:00`), never floating/local-only time.
4. Create cron immediately after computing the timestamp (do not reuse stale timestamps).
5. Confirm using the returned `jobId` and local due time.

For short delays (1-10 minutes), prefer exact minute boundaries only if requested; otherwise keep second-level precision from computed time.

## Memory log format

Append one line to daily file:

`- [HH:MM] Reminder set: <text> (due: <ISO/local time>) [cron:<jobId or pending>]`

## Tool usage templates

### Create reminder

Before `cron.add`, call `session_status` and compute `schedule.at` from that timestamp in Europe/Rome.

Use `cron.add` with job:

```json
{
  "sessionTarget": "main",
  "schedule": {"kind": "at", "at": "2026-02-27T18:30:00+01:00"},
  "payload": {"kind": "systemEvent", "text": "Promemoria: <testo>."},
  "enabled": true
}
```

### Append memory log

```bash
python ~/.agents/skills/self-reminder-memory/scripts/append_memory.py --text "<testo>" --due "<when>"
```

## Ambiguity handling

- If the time is ambiguous, ask exactly one clarification question.
- If no time is given, store only in memory and ask whether to schedule a cron reminder.

## Safety

- Never claim a reminder is scheduled without returning a cron `jobId`.
- Never overwrite memory files; only append.
- Keep reminder text concise and private-safe.
