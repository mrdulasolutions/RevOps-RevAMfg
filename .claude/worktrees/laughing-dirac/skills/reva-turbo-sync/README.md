# reva-turbo-sync

Bidirectional auto-sync skill for the REVA-TURBO engine.

## What It Does

Eliminates double-entry between REVA-TURBO and external systems:

1. **Outbound** (REVA-TURBO to External) — Order stage changes push to CRM, communications log as activities, deliveries close deals
2. **Inbound** (External to REVA-TURBO) — Emails auto-link to orders, PO attachments match to quotes, partner updates advance milestones
3. **Conflict resolution** — When systems disagree, flag for PM review (never auto-overwrite financial data)
4. **Sync health** — Dashboard showing last sync, pending items, failures, and conflicts

## Supported Systems

| System | Direction | Schedule |
|--------|-----------|----------|
| CRM (HubSpot/Dynamics) | Bidirectional | Real-time (out) / 15 min (in) |
| Email (Gmail/Outlook) | Inbound | Every 15 min |
| Calendar (Google/Outlook) | Inbound | Every hour |
| Partner Portal/Email | Inbound | On receive |

## Sync Mappings

| REVA-TURBO Event | External Action |
|-------------|----------------|
| Quote created | CRM: Deal stage = "Quote Sent" |
| PO received | CRM: Deal stage = "PO Received" |
| In production | CRM: Deal stage = "In Production" |
| Shipped | CRM: Deal stage = "Shipped" + tracking |
| Delivered | CRM: Deal stage = "Delivered" |
| Invoice paid | CRM: Deal = "Closed Won" |
| NCR created | CRM: Note on Account |
| Email with RFQ | REVA-TURBO: Create RFQ intake (PM confirms) |
| Email with PO | REVA-TURBO: Link to quote (PM confirms) |
| Partner milestone | REVA-TURBO: Update china-track (PM confirms) |

## Usage

```
/reva-turbo-sync
```

## Files

| File | Purpose |
|------|---------|
| `SKILL.md` | Skill instructions and flow |
| `skill.yaml` | Skill manifest |
| `prompts/sync-system.md` | Sync rules and entity matching |
| `references/sync-mappings.md` | Complete field mappings |
| `references/conflict-resolution.md` | Conflict handling rules |
| `references/email-matching.md` | Email-to-entity matching |
| `bin/sync-check.sh` | Sync health check script |
