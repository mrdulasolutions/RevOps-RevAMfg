# reva-turbo-reminder

PM reminder system skill for the REVA-TURBO engine.

## What It Does

Provides proactive, time-based reminders so nothing falls through the cracks:

1. **Quote no-response (T+3):** Follow up when customer has not responded to a quote in 3 business days
2. **Quote expiration (T-5):** Alert when a quote expires in 5 days
3. **Delivery approaching (T-7, T-3, T-1):** Countdown reminders for upcoming deliveries
4. **Inspection due:** Reminder when product is received and awaiting inspection
5. **NCR corrective action due:** Deadline reminder for NCR corrective actions
6. **Post-delivery satisfaction (T+3):** Customer satisfaction check 3 days after delivery

## Usage

```
/reva-turbo-reminder
```

Typically triggered automatically by reva-turbo-cron as part of the daily routine.

## Files

| File | Purpose |
|------|---------|
| `SKILL.md` | Skill instructions and flow |
| `skill.yaml` | Skill manifest |
| `references/reminder-triggers.md` | Complete trigger definitions |

## Data

Reminder history is stored at `~/.reva-turbo/state/reminder-log.jsonl`.
