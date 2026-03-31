# Conflict Resolution Rules

Rules for handling data conflicts between PMLORD and external systems.

---

## General Principles

1. **System of record wins** — Each data type has a designated system of record. When in doubt, prefer the system of record.
2. **Financial data is sacred** — Never auto-resolve conflicts involving price, amount, cost, margin, or payment. Always flag for PM review.
3. **Newer is not always better** — Just because a value is more recent does not make it correct. Context matters.
4. **Log everything** — Every conflict detection, resolution, and override is logged.
5. **PM has final authority** — When rules don't cover a case, the PM decides.

---

## System of Record Assignments

| Data Category | System of Record | Rationale |
|--------------|-----------------|-----------|
| Customer contact info (name, email, phone, title) | CRM | Sales team maintains contacts |
| Customer account info (industry, size, website) | CRM | Sales team maintains accounts |
| Order details (specs, quantities, materials) | PMLORD | Manufacturing system of record |
| Order status/stage | PMLORD | Workflow engine manages stages |
| Pricing and costs | PMLORD | Quote engine is authoritative |
| Manufacturing milestones | PMLORD | China-track is authoritative |
| Quality data (NCRs, inspections) | PMLORD | Quality system of record |
| Partner performance | PMLORD | Scorecard engine is authoritative |
| Sales pipeline metadata | CRM | Sales process managed in CRM |
| Communication history | Both (merge) | Keep records from both systems |

---

## Conflict Resolution Matrix

### Same Field Updated in Both Systems

> **Action:** Flag for PM review. Show both values with timestamps.

```
CONFLICT DETECTED

Field: {{FIELD_NAME}}
PMLORD value: "{{PMLORD_VALUE}}" (updated {{PMLORD_TIMESTAMP}})
CRM value: "{{CRM_VALUE}}" (updated {{CRM_TIMESTAMP}})

System of record for this field: {{SOR}}
Recommendation: Keep {{RECOMMENDED}} value

A) Keep PMLORD value
B) Accept CRM value
C) Enter a different value
D) Skip (resolve later)
```

### CRM Has Newer Data — Customer Contact Fields

> **Action:** Auto-accept CRM value (CRM is system of record for contacts).

Exception: If the PMLORD value was set by PM in the last 24 hours, flag for review instead.

### PMLORD Has Newer Data — Order/Workflow Fields

> **Action:** Auto-keep PMLORD value and push to CRM.

The external system should not override PMLORD order data. If someone changed a deal stage in CRM manually, PMLORD corrects it.

### Price / Financial Data Conflict

> **Action:** ALWAYS flag for PM review. Never auto-resolve.

```
FINANCIAL CONFLICT — PM REVIEW REQUIRED

Order: {{ORDER_ID}}
Field: {{FIELD_NAME}}
PMLORD value: ${{PMLORD_VALUE}}
CRM value: ${{CRM_VALUE}}
Difference: ${{DELTA}} ({{PERCENT_DELTA}}%)

This conflict involves financial data and cannot be auto-resolved.

A) Keep PMLORD value (${{PMLORD_VALUE}})
B) Accept CRM value (${{CRM_VALUE}})
C) Enter the correct value
```

### Entity Exists in One System But Not the Other

> **Action:** Offer to create the entity in the missing system.

```
ENTITY MISMATCH

{{ENTITY_TYPE}} "{{ENTITY_NAME}}" exists in {{SOURCE_SYSTEM}} but not in {{MISSING_SYSTEM}}.

A) Create in {{MISSING_SYSTEM}}
B) Link to existing {{MISSING_SYSTEM}} record (search)
C) Skip (no sync needed for this entity)
```

### Communication / Activity Records

> **Action:** Merge. Keep records from both systems. Never delete.

Activities and communications are append-only. If the same event is logged in both systems with slightly different details, keep both and tag the source.

---

## Conflict Severity Levels

| Severity | Definition | PM Action Required |
|----------|-----------|-------------------|
| **Critical** | Financial data conflict, or order stage regression | Immediate review |
| **Warning** | Contact data conflict, date discrepancy | Review within 24 hours |
| **Info** | Duplicate activity entry, minor metadata | Review when convenient |

---

## Conflict Log Format

```json
{
  "ts": "2026-03-30T14:30:00Z",
  "severity": "critical",
  "field": "deal_amount",
  "pmlord_value": "15000",
  "pmlord_updated": "2026-03-30T12:00:00Z",
  "external_system": "hubspot",
  "external_value": "12500",
  "external_updated": "2026-03-30T13:45:00Z",
  "sor": "pmlord",
  "resolution": "pending",
  "resolved_by": null,
  "resolved_at": null
}
```

---

## Edge Cases

### CRM Deal Manually Moved to "Closed Lost" But PMLORD Order Is Active

> **Action:** Flag immediately. Do not cancel the PMLORD order. Ask PM: "CRM shows this deal as Closed Lost, but PMLORD has an active order. Which is correct?"

### Email From Unknown Sender Matches a PO Number

> **Action:** Flag for PM. Show the email and the matched order. PM decides if it's legitimate.

### Partner Email Updates a Milestone That's Already Past

> **Action:** Flag for PM. "Partner reports 'tooling complete' but PMLORD shows production is already started. Is this a duplicate notification or a data error?"

### Multiple CRM Contacts Match One PMLORD Customer

> **Action:** Present all matches and let PM choose the primary contact. Log the selection.
