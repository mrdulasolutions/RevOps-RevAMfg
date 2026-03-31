# pmlord-cron

Scheduled task management skill for the PMLORD engine.

## What It Does

Manages recurring tasks on defined schedules:

1. **Daily:** Order status checks across all active orders
2. **Monday:** Partner follow-up emails and status requests
3. **Friday:** Weekly PM Summary report generation
4. **Monthly (1st):** Partner scorecards and monthly performance report
5. **Quarterly (1st week):** Quarterly business review

## Usage

```
/pmlord-cron
```

Or ask PMLORD "what's on the schedule today?" or "run scheduled tasks."

## Files

| File | Purpose |
|------|---------|
| `SKILL.md` | Skill instructions and flow |
| `skill.yaml` | Skill manifest |
| `prompts/scheduling-system.md` | System prompt for scheduling logic |
| `references/schedule-definitions.md` | Complete schedule definitions |

## Execution Log

Task execution history is stored at `~/.pmlord/state/cron-log.jsonl`.
