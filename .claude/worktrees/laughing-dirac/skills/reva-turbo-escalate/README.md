# reva-turbo-escalate

Escalation workflow skill for the REVA-TURBO engine.

## What It Does

Manages the escalation process when issues exceed standard PM authority:

1. Assesses escalation triggers (quality, delay, complaint, partner score, payment)
2. Routes to the correct level (Senior PM, then Donovan Weber)
3. Generates documented escalation notes
4. Tracks escalations through to resolution
5. Logs all actions in the audit trail

## Escalation Triggers

| Trigger | Threshold |
|---------|-----------|
| Quality Issue | NCR severity Major or Reject |
| Delay | > 2 weeks (15+ calendar days) |
| Customer Complaint | Formal complaint received |
| Partner Score | Drops below C grade |
| Payment Issue | Overdue > 30 days or dispute |

## Escalation Chain

PM -> Senior PM -> Donovan Weber (President)

## Usage

```
/reva-turbo-escalate
```

Or triggered automatically by other REVA-TURBO skills when escalation thresholds are met.

## Files

| File | Purpose |
|------|---------|
| `SKILL.md` | Skill instructions and flow |
| `skill.yaml` | Skill manifest |
| `prompts/escalation-system.md` | System prompt for escalation logic |
| `prompts/escalation-user-template.md` | User interaction template |
| `references/escalation-matrix.md` | Routing and trigger definitions |
| `references/documentation-requirements.md` | Documentation standards |
| `templates/Escalation Note.md` | Escalation note template |
