# pmlord-pulse

Real-time alert feed and PM nervous system for the PMLORD engine.

## What It Does

Continuously monitors PMLORD state files for exception conditions and pushes targeted alerts to the PM through their preferred channels. Pulse is not noisy — it only speaks up when something matters.

1. PM configures alert channels (Slack, iMessage, email, or in-system)
2. Alert rules detect delays, NCRs, expiring quotes, overdue payments, score drops, escalations, and capacity warnings
3. Smart filtering deduplicates, groups related alerts, suppresses during off-hours, and respects snooze settings
4. CRITICAL alerts push immediately via Slack and iMessage
5. WARNING alerts queue for the next check-in window
6. INFO alerts collect into the daily digest
7. Weekly pulse report surfaces patterns and trends

## Usage

```
/pmlord-pulse
```

Or Pulse runs automatically in the background via pmlord-cron.

## Inputs

- PM channel configuration (one-time setup)
- Alert priority customization (optional)
- PM actions on alerts (acknowledge, snooze, escalate, act)

## Outputs

- Alert records in `~/.pmlord/state/pulse-alerts.jsonl`
- Alert actions in `~/.pmlord/state/pulse-actions.jsonl`
- Digest records in `~/.pmlord/state/pulse-digests.jsonl`
- Push notifications via Slack, iMessage, and/or email

## Files

| File | Purpose |
|------|---------|
| `SKILL.md` | Skill instructions and flow |
| `skill.yaml` | Skill manifest |
| `prompts/pulse-system.md` | Alert generation and priority rules |
| `references/alert-definitions.md` | Complete alert catalog (14 alert types) |
| `references/channel-config.md` | Channel configuration and MCP tools |
| `references/filtering-rules.md` | Dedup, grouping, snooze, off-hours rules |
| `templates/Daily Digest.md` | Morning digest template |
| `templates/Weekly Pulse.md` | Weekly summary template |
| `bin/pulse-check.sh` | Alert detection scan script |

## Alert Priorities

| Priority | Behavior | Examples |
|----------|----------|----------|
| CRITICAL | Immediate push via Slack + iMessage | Delay, NCR, payment overdue, escalation |
| WARNING | Next check-in window | Quote expiring, partner score drop |
| INFO | Daily digest only | Delivery approaching, milestone completed |
