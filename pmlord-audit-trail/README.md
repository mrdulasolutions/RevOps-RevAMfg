# pmlord-audit-trail

Audit trail management skill for the PMLORD engine.

## What It Does

Maintains a complete, immutable record of every significant PM action and decision:

1. Logs audit entries from all PMLORD skills (automatic) and manual PM entries
2. Supports querying by PO, customer, PM, date, action type, or skill
3. Generates formatted audit reports
4. Verifies audit trail integrity

## Usage

```
/pmlord-audit-trail
```

Or ask PMLORD to log a decision, query the audit trail, or generate an audit report.

## Key Principle

The audit trail is **append-only**. Entries are never modified or deleted. This ensures complete accountability and traceability.

## Files

| File | Purpose |
|------|---------|
| `SKILL.md` | Skill instructions and flow |
| `skill.yaml` | Skill manifest |
| `prompts/audit-system.md` | System prompt for audit management |
| `prompts/audit-user-template.md` | User interaction template |
| `references/audit-requirements.md` | Requirements and policies |
| `templates/Audit Trail Entry.md` | Audit report template |

## Data

Audit entries are stored at `~/.pmlord/state/audit-trail.jsonl` as newline-delimited JSON.
