# Audit Trail Requirements

## Purpose

The PMLORD audit trail serves three functions:

1. **Accountability** — Document who made what decision and when
2. **Traceability** — Link every action to its order, customer, and PM
3. **Compliance** — Provide documentation for quality audits, customer audits, and internal reviews

## Retention Policy

- **Minimum retention:** 5 years from date of entry
- **Backup:** Audit trail file should be backed up with regular system backups
- **No purging:** Do not delete entries even after retention period. Archive if necessary.

## What Must Be Logged

### Mandatory Audit Events

| Event | Skill Source | Type |
|-------|-------------|------|
| RFQ received and processed | pmlord-rfq-intake | system |
| RFQ qualification decision | pmlord-rfq-qualify | decision |
| Quote generated and sent | pmlord-rfq-quote | approval |
| PO received and acknowledged | pmlord-order-track | system |
| Each stage transition | pmlord-order-track | system |
| Routing decision (direct vs inspect) | pmlord-logistics | decision |
| Routing override | pmlord-logistics | override |
| Shipment booked | pmlord-logistics | system |
| Inspection result (pass/fail) | pmlord-inspect | decision |
| NCR created | pmlord-ncr | system |
| NCR disposition decision | pmlord-ncr | decision |
| Repackaging work order issued | pmlord-repackage | system |
| Repackaging completed | pmlord-repackage | system |
| Escalation initiated | pmlord-escalate | escalation |
| Escalation resolved | pmlord-escalate | decision |
| Partner score updated | pmlord-partner-scorecard | system |
| Customer communication (significant) | pmlord-customer-comms | communication |
| Delay reported | pmlord-order-track | system |
| Order closed | pmlord-order-track | system |

### Optional Audit Events

| Event | When to Log |
|-------|------------|
| PM note or comment | PM wants to document a thought or context |
| Meeting notes summary | After significant customer or partner meeting |
| Price adjustment | Any change to quoted or invoiced price |
| Terms change | Any modification to PO terms |
| Partner feedback | Significant positive or negative partner feedback |

## Access Control

- **Write access:** All PMLORD skills (automatic), PMs (manual entries)
- **Read access:** PMs, Senior PM, Donovan Weber (President)
- **No delete access:** Nobody. The trail is immutable.

## Audit Review Schedule

| Review | Cadence | Reviewer |
|--------|---------|----------|
| Spot check (random entries) | Weekly | Senior PM |
| Full review (specific order) | Per customer audit request | PM + Senior PM |
| Integrity verification | Monthly | System (automated) |
| Annual audit review | Yearly | Donovan Weber + Senior PM |

## Entry Format

Every entry is a single line of valid JSON in the audit-trail.jsonl file. Fields:

```json
{
  "ts": "2026-03-30T14:30:00Z",
  "type": "decision",
  "ref": "PO-2026-0042",
  "customer": "Acme Corp",
  "action": "Approved routing as inspect-and-forward based on new customer status",
  "justification": "",
  "pm": "Ray Yeh",
  "skill": "pmlord-logistics",
  "detail": "Customer's first order, standard matrix recommendation"
}
```
