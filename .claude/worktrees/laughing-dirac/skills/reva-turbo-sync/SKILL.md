---
name: reva-turbo-sync
preamble-tier: 1
version: 1.0.0
description: |
  Bidirectional auto-sync between REVA-TURBO and external systems (CRM, email,
  calendar, partner updates). Eliminates double-entry. REVA-TURBO stage changes
  push to CRM. Incoming emails auto-link to orders. Partner shipment updates
  auto-advance milestones. Conflict resolution with PM review.
compatibility: Claude Code, Claude desktop, Claude CoWork
allowed-tools:
  - Bash
  - Read
  - Write
  - Edit
  - Glob
  - Grep
  - AskUserQuestion
---

## Preamble (run first)

```bash
mkdir -p ~/.reva-turbo/analytics
echo '{"skill":"reva-turbo-sync","ts":"'$(date -u +%Y-%m-%dT%H:%M:%SZ)'"}' >> ~/.reva-turbo/analytics/skill-usage.jsonl 2>/dev/null || true
```

## Purpose

Eliminate double-entry between REVA-TURBO and external systems. When REVA-TURBO state changes, external systems update automatically. When external events occur (email, CRM update, partner notification), REVA-TURBO records update with PM confirmation. No more copy-paste between systems.

## Flow

### Step 1 — Sync Configuration

PM configures which systems to sync. Load or create sync config:

```bash
mkdir -p ~/.reva-turbo/state
cat ~/.reva-turbo/state/sync-config.yaml 2>/dev/null || echo "No sync config found. Setting up..."
```

> **Sync Configuration**
>
> Which systems should REVA-TURBO sync with?
>
> | System | Status | Connection |
> |--------|--------|------------|
> | A) CRM (HubSpot/Dynamics) | {{CRM_STATUS}} | {{CRM_CONNECTION}} |
> | B) Email (Gmail/Outlook) | {{EMAIL_STATUS}} | {{EMAIL_CONNECTION}} |
> | C) Calendar (Google/Outlook) | {{CALENDAR_STATUS}} | {{CALENDAR_CONNECTION}} |
> | D) Partner Portal | {{PARTNER_STATUS}} | {{PARTNER_CONNECTION}} |
>
> Select systems to enable/configure, or type "all" to enable all available.

Save configuration:

```yaml
# ~/.reva-turbo/state/sync-config.yaml
crm:
  enabled: true
  provider: hubspot  # or dynamics
  sync_schedule: real-time
  last_sync: null
email:
  enabled: true
  provider: gmail  # or outlook
  sync_schedule: every-15-min
  last_sync: null
calendar:
  enabled: true
  provider: google
  sync_schedule: every-15-min
  last_sync: null
partner:
  enabled: true
  method: email-parse  # or api
  sync_schedule: on-receive
  last_sync: null
```

### Step 2 — Outbound Sync (REVA-TURBO to External)

When REVA-TURBO state changes, push updates to connected systems. Reference `references/sync-mappings.md` for complete field mappings.

#### 2a. Order Stage Change to CRM

| REVA-TURBO Event | CRM Action | CRM Field |
|-------------|-----------|-----------|
| Quote created | Create/update Opportunity | Deal stage = "Quote Sent" |
| Quote accepted (PO received) | Update Opportunity | Deal stage = "PO Received", Amount = PO value |
| Order placed with partner | Update Opportunity | Deal stage = "In Production" |
| Tooling complete | Add activity note | Note = "Tooling approved" |
| Production complete | Update Opportunity | Deal stage = "QC/Inspection" |
| QC passed | Update Opportunity | Deal stage = "Ready to Ship" |
| Shipped | Update Opportunity | Deal stage = "Shipped", add tracking # |
| Delivered | Update Opportunity | Deal stage = "Delivered" |
| Invoice paid | Close Opportunity | Deal stage = "Closed Won", Close date = today |

#### 2b. Customer Communication to CRM

| REVA-TURBO Event | CRM Action |
|-------------|-----------|
| Status update sent to customer | Log Activity (email type) on Contact |
| Quote sent to customer | Log Activity + attach quote document |
| NCR notification sent | Log Activity (note type) on Account |

#### 2c. NCR/Escalation to CRM

| REVA-TURBO Event | CRM Action |
|-------------|-----------|
| NCR created | Add Note to Account: "NCR-XXXX: [description]" |
| Escalation created | Add Note to Account: "ESCALATION: [description]" |
| NCR resolved | Update Note: "NCR-XXXX RESOLVED: [resolution]" |

**Sync execution:**

```bash
echo '{"ts":"'$(date -u +%Y-%m-%dT%H:%M:%SZ)'","direction":"outbound","source":"reva-turbo","target":"{{TARGET_SYSTEM}}","entity_type":"{{ENTITY_TYPE}}","entity_id":"{{ENTITY_ID}}","action":"{{SYNC_ACTION}}","status":"{{STATUS}}","details":"{{DETAILS}}"}' >> ~/.reva-turbo/state/sync-log.jsonl
```

### Step 3 — Inbound Sync (External to REVA-TURBO)

When external events occur, route them into REVA-TURBO. Reference `references/email-matching.md` for matching rules.

#### 3a. Email to REVA-TURBO

| Email Pattern | REVA-TURBO Action | PM Confirmation |
|--------------|--------------|-----------------|
| Subject contains "RFQ" or "quote request" | Create RFQ intake record | **Yes** — PM confirms before creating |
| Attachment is PO (.pdf) + matches pending quote | Link PO to quote, advance to "PO Received" | **Yes** — PM confirms match |
| From partner domain + contains milestone keyword | Update china-track milestone | **Yes** — PM confirms milestone |
| From customer + contains "change" or "revision" | Flag for change order review | **Yes** — PM reviews |
| From partner + contains tracking number | Update logistics tracking | **Yes** — PM confirms |

Reference `references/email-matching.md` for subject line patterns, domain matching, and keyword extraction.

#### 3b. CRM to REVA-TURBO

| CRM Event | REVA-TURBO Action | PM Confirmation |
|-----------|--------------|-----------------|
| Contact updated (email, phone, title) | Update customer profile | No (auto-sync) |
| New contact added to Account | Add to customer profile contacts | **Yes** — PM confirms |
| Deal note added by sales | Show in customer activity feed | No (informational) |
| Deal stage changed externally | **Flag conflict** — REVA-TURBO is system of record for orders | **Yes** — PM resolves |

#### 3c. Calendar to REVA-TURBO

| Calendar Event | REVA-TURBO Action |
|---------------|--------------|
| Event title contains customer name | Pre-load customer profile + order status for meeting prep |
| Event title contains "factory visit" or "partner" | Pre-load partner scorecard + open orders |
| Event title contains "inspection" | Pre-load inspection checklist for relevant PO |

### Step 4 — Conflict Resolution

When REVA-TURBO and an external system disagree on a value, do not auto-overwrite. Reference `references/conflict-resolution.md` for resolution rules.

> **Sync Conflict Detected**
>
> Field: {{FIELD_NAME}}
> REVA-TURBO value: {{REVA-TURBO_VALUE}} (updated {{REVA-TURBO_UPDATED}})
> {{EXTERNAL_SYSTEM}} value: {{EXTERNAL_VALUE}} (updated {{EXTERNAL_UPDATED}})
>
> **Conflict rule:** {{CONFLICT_RULE}}
>
> A) Keep REVA-TURBO value
> B) Accept {{EXTERNAL_SYSTEM}} value
> C) Enter a different value
> D) Skip (resolve later)

**HUMAN-IN-THE-LOOP:** Financial data conflicts (price, amount, margin) are ALWAYS flagged for PM review, never auto-resolved.

**Conflict resolution logging:**

```bash
echo '{"ts":"'$(date -u +%Y-%m-%dT%H:%M:%SZ)'","event":"conflict","field":"{{FIELD_NAME}}","reva-turbo_value":"{{REVA-TURBO_VALUE}}","external_value":"{{EXTERNAL_VALUE}}","external_system":"{{EXTERNAL_SYSTEM}}","resolution":"{{RESOLUTION}}","resolved_by":"{{PM_NAME}}"}' >> ~/.reva-turbo/state/sync-log.jsonl
```

### Step 5 — Sync Log

Every sync event is logged:

```bash
mkdir -p ~/.reva-turbo/state
echo '{"ts":"'$(date -u +%Y-%m-%dT%H:%M:%SZ)'","direction":"{{DIRECTION}}","source":"{{SOURCE}}","target":"{{TARGET}}","entity_type":"{{ENTITY_TYPE}}","entity_id":"{{ENTITY_ID}}","action":"{{ACTION}}","status":"{{STATUS}}","details":"{{DETAILS}}"}' >> ~/.reva-turbo/state/sync-log.jsonl
```

Log fields:
- `direction` — inbound or outbound
- `source` — originating system
- `target` — receiving system
- `entity_type` — order, customer, quote, ncr, contact
- `entity_id` — REVA-TURBO reference ID
- `action` — create, update, link, flag
- `status` — success, failed, conflict, pending
- `details` — human-readable description

### Step 6 — Sync Health Dashboard

Show the PM sync health at a glance:

> **Sync Health Dashboard**
>
> | Channel | Last Sync | Status | Pending | Failed |
> |---------|-----------|--------|---------|--------|
> | CRM (HubSpot) | 5 min ago | OK | 0 | 0 |
> | Email (Gmail) | 12 min ago | OK | 2 | 0 |
> | Calendar | 1 hour ago | OK | 0 | 0 |
> | Partner Email | 3 hours ago | Warning | 1 | 1 |
>
> **Pending items (2):**
> - Email from john@acme.com with PO attachment — needs matching
> - Email from partner with milestone update — needs confirmation
>
> **Failed items (1):**
> - CRM update for ORD-2026-0142 — API timeout (will retry)

Run sync health check:

```bash
bash ~/.reva-turbo/../bin/sync-check.sh 2>/dev/null || echo "Sync check script not found. Reading sync log directly..."
tail -20 ~/.reva-turbo/state/sync-log.jsonl 2>/dev/null || echo "No sync log found."
```

### Step 7 — Manual Sync

PM can force a sync for a specific entity:

- "sync order ORD-2026-0142" — push all order data to CRM
- "sync customer Acme" — push/pull all customer data
- "sync all" — full bidirectional sync of all entities

> **Manual Sync: ORD-2026-0142**
>
> | Direction | System | Action | Result |
> |-----------|--------|--------|--------|
> | Out | CRM | Update deal stage to "In Production" | Success |
> | Out | CRM | Log 2 activity notes | Success |
> | In | Email | Link 3 related emails | Success |
> | In | CRM | Contact phone updated | Auto-synced |
>
> Sync complete. 0 conflicts found.

### Step 8 — Sync Schedule

Configure how often each channel syncs:

| Schedule | Behavior |
|----------|----------|
| `real-time` | Sync on every REVA-TURBO state change (outbound) |
| `every-15-min` | Batch sync every 15 minutes |
| `every-hour` | Batch sync every hour |
| `daily` | Sync once daily at configured time |
| `on-receive` | Sync when external event is detected |
| `manual` | Only sync when PM requests |

> **Current sync schedule:**
>
> | Channel | Schedule | Next Sync |
> |---------|----------|-----------|
> | CRM outbound | real-time | On next change |
> | CRM inbound | every-15-min | 3 min from now |
> | Email inbound | every-15-min | 3 min from now |
> | Calendar | every-hour | 48 min from now |
> | Partner | on-receive | Waiting for email |
>
> A) Change a schedule
> B) Force sync now
> C) OK

## State Tracking

Sync config: `~/.reva-turbo/state/sync-config.yaml`
Sync log: `~/.reva-turbo/state/sync-log.jsonl`

## References

- `prompts/sync-system.md` — Sync rules, conflict resolution, entity matching
- `references/sync-mappings.md` — Complete field mappings per system
- `references/conflict-resolution.md` — Conflict handling rules
- `references/email-matching.md` — Email-to-entity matching patterns
- `bin/sync-check.sh` — Sync health check script
