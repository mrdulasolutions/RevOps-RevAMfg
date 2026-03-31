# CAPA Framework — Corrective and Preventive Action

## Overview

Every NCR with Major or Critical severity requires a formal CAPA. Minor NCRs require at minimum a corrective action. The CAPA framework has five phases.

---

## Phase 1 — Containment (Immediate)

**Timeline:** Within 24 hours of discovery (Critical), 48 hours (Major), 5 days (Minor).

### Actions

1. **Quarantine** affected parts — physically separate, label with NCR number.
2. **Stop the line** — if defect discovered during production, halt until root cause is understood.
3. **Check inventory** — verify no other affected parts are in stock or staged for shipment.
4. **Check in-transit** — determine if affected parts are in transit from partner.
5. **Customer protection** — verify no affected parts have been shipped to customers.
6. **Notify** — inform PM, Senior PM (for Major/Critical), and partner.

### Containment Verification

| Question | Answer |
|----------|--------|
| Are all affected parts identified and quarantined? | |
| Are customers protected from receiving affected parts? | |
| Is the source of the non-conformance stopped? | |
| Are all stakeholders notified? | |

---

## Phase 2 — Root Cause Identification

**Timeline:** Within 5 business days (Critical), 10 days (Major), 20 days (Minor).

### Requirements

1. Use appropriate root cause method (5-Why, Fishbone, 8D) per severity.
2. Identify BOTH:
   - **Occurrence cause:** Why did the defect happen?
   - **Escape cause:** Why was the defect not detected before reaching Rev A?
3. Support root cause with evidence (measurements, photos, process records).
4. Root cause must be a systemic issue (not "operator error" alone).

### Root Cause Documentation

```
OCCURRENCE ROOT CAUSE:
[Description of why the defect occurred]
Evidence: [What data/evidence supports this conclusion]

ESCAPE ROOT CAUSE:
[Description of why the defect was not detected]
Evidence: [What data/evidence supports this conclusion]
```

---

## Phase 3 — Corrective Action (Fix the Problem)

**Timeline:** Implementation within 15 business days (Critical), 30 days (Major), 60 days (Minor).

### Requirements

Each corrective action must address the identified root cause and include:

| Field | Description |
|-------|-------------|
| Action ID | CA-{NCR Number}-{##} (e.g., CA-NCR-2026-001-01) |
| Description | Specific action to eliminate the root cause |
| Type | Process change / Spec update / Training / Equipment / Inspection |
| Owner | Name of person responsible |
| Due date | Target completion date |
| Status | Open / In Progress / Complete / Verified |

### Examples of Corrective Actions

| Root Cause | Corrective Action |
|-----------|-------------------|
| Setup sheet not updated after tool change | Create mandatory tool change checklist requiring setup sheet verification |
| Wrong material purchased | Update purchasing procedure to require material cert verification at PO stage |
| Inspection missed the defect | Add critical dimension to first-piece inspection checklist |
| Drawing unclear | Revise drawing with additional detail views and explicit callouts |
| Partner process unstable | Require partner to provide Cpk data for critical dimensions |

---

## Phase 4 — Preventive Action (Prevent Recurrence)

**Timeline:** Implementation within 30 business days (Critical), 60 days (Major), 90 days (Minor).

### Requirements

Preventive actions go beyond the specific NCR to prevent similar issues across all parts and partners:

| Field | Description |
|-------|-------------|
| Action ID | PA-{NCR Number}-{##} (e.g., PA-NCR-2026-001-01) |
| Description | Systemic change to prevent recurrence |
| Scope | Which parts, partners, or processes are affected |
| Owner | Name of person responsible |
| Due date | Target completion date |
| Status | Open / In Progress / Complete / Verified |

### Examples of Preventive Actions

| Corrective Action | Preventive Action |
|-------------------|-------------------|
| Tool change checklist for this machine | Implement tool change checklist across ALL machines |
| Material cert verification for this PO | Require material cert at receiving for ALL POs |
| Add dim to this part's inspection plan | Review and update inspection plans for all similar parts |
| Revise this drawing | Audit all drawings for similar clarity issues |
| Require Cpk from this partner | Require Cpk from all partners on critical dims |

---

## Phase 5 — Verification (Confirm Effectiveness)

**Timeline:** 30-90 days after corrective action implementation.

### Requirements

1. **Verify implementation** — Confirm the corrective action was actually implemented.
2. **Verify effectiveness** — Confirm the corrective action prevents the recurrence.
3. **Monitor period** — Track for a defined period (typically 3 production runs or 90 days).
4. **Close or reopen** — If effective, close the CAPA. If not, reopen and revise.

### Verification Methods

| Method | When to Use |
|--------|------------|
| Inspect next production run | Standard — verify parts from next order meet spec |
| Audit partner process | When corrective action is a process change at partner |
| Review updated documentation | When corrective action is a procedure/spec update |
| Statistical analysis | When process capability is the issue (compare Cpk before/after) |
| Customer feedback | When customer returns were the original issue |

### Verification Record

| Field | Value |
|-------|-------|
| Verification date | |
| Verified by | |
| Verification method | |
| Result | Effective / Not effective |
| Evidence | |
| CAPA status | Closed / Reopened |

---

## CAPA Tracking

All open CAPAs should be reviewed:
- **Critical:** Weekly until closed
- **Major:** Biweekly until closed
- **Minor:** Monthly until closed

Overdue CAPAs are escalated to Senior PM. CAPAs open longer than 90 days (Critical) or 180 days (Major/Minor) are escalated to Donovan Weber.
