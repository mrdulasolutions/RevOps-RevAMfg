---
name: pmlord-ncr
description: |
  Non-Conformance Report workflow. Document defects, perform root cause
  analysis (5-Why, fishbone, 8D), define corrective action (CAPA), and
  assign disposition (rework, scrap, use-as-is, RTV).
compatibility: Claude Code, Claude desktop, Claude CoWork
allowed-tools:
  - Bash
  - Read
  - Write
  - Edit
  - Glob
  - Grep
---

## Preamble (run first)

```bash
mkdir -p ~/.pmlord/analytics
echo '{"skill":"pmlord-ncr","ts":"'$(date -u +%Y-%m-%dT%H:%M:%SZ)'"}' >> ~/.pmlord/analytics/skill-usage.jsonl 2>/dev/null || true
```

## Purpose

Create and manage Non-Conformance Reports (NCRs) when parts or processes fail to meet specifications. Guide PMs through defect documentation, root cause analysis, corrective and preventive actions (CAPA), and disposition decisions.

## Flow

### Step 1 — NCR Identification

Assign a unique NCR number and collect basic information:

**NCR Number Format:** `NCR-{YYYY}-{###}` (e.g., NCR-2026-001)

Ask the PM:

| Field | Required |
|-------|----------|
| Part number (Rev A) | Yes |
| Part name | Yes |
| PO number | Yes |
| Manufacturing partner | Yes |
| Quantity affected | Yes |
| Total order quantity | Yes |
| Date defect discovered | Yes |
| Discovered by | Yes |
| Discovered during (stage) | Yes — Incoming inspection / In-process / Final / Customer return |

### Step 2 — Defect Description

Document the non-conformance in detail:

1. **What is wrong?** — Clear, specific description of the defect.
2. **What was expected?** — The specification requirement (with drawing reference).
3. **What was found?** — The actual condition (with measurements if dimensional).
4. **Severity:** Critical / Major / Minor
5. **Defect type:** Dimensional / Material / Surface / Functional / Cosmetic / Documentation
6. **Photos/evidence:** Reference any photos or measurement data.

### Step 3 — Containment Action

Immediate actions to prevent the non-conforming parts from reaching the customer:

1. **Quarantine affected parts** — Physically separate and label.
2. **Check other orders** — Are other POs from this partner affected?
3. **Check in-transit shipments** — Are more parts on the way?
4. **Notify stakeholders:**
   - PM assigned to the order
   - Senior PM (Ray Yeh or Harley Scott) if severity is Critical or Major
   - Donovan Weber if customer impact is likely

> **HUMAN-IN-THE-LOOP:** "Containment actions proposed. Confirm these actions before proceeding to root cause analysis."

### Step 4 — Root Cause Analysis

Reference `references/root-cause-methods.md` and guide the PM through root cause analysis. Select the method based on severity:

| Severity | Recommended Method |
|----------|-------------------|
| Minor | 5-Why analysis |
| Major | 5-Why + Fishbone (Ishikawa) diagram |
| Critical | Full 8D report |

#### 5-Why Analysis

Walk the PM through 5 levels of "Why":

1. **Why did the defect occur?** {{WHY_1}}
2. **Why did that happen?** {{WHY_2}}
3. **Why did that happen?** {{WHY_3}}
4. **Why did that happen?** {{WHY_4}}
5. **Why did that happen (root cause)?** {{WHY_5}}

#### Fishbone Categories (if applicable)

- **Man** — Operator error, training, skill
- **Machine** — Equipment, tooling, calibration
- **Material** — Raw material, supplier, specification
- **Method** — Process, procedure, technique
- **Measurement** — Inspection, gauging, standards
- **Environment** — Temperature, humidity, cleanliness

### Step 5 — Disposition

Reference `references/disposition-options.md` and determine what to do with the non-conforming parts:

| Disposition | Definition | Authority |
|------------|-----------|-----------|
| **Rework** | Parts can be corrected to meet spec | PM |
| **Scrap** | Parts cannot be salvaged; destroy | PM + Senior PM |
| **Use-As-Is** | Accept with documented deviation | Senior PM + customer approval |
| **RTV (Return to Vendor)** | Return parts to manufacturing partner | PM |

> **HUMAN-IN-THE-LOOP:** "Recommended disposition is [DISPOSITION]. Do you confirm? For Use-As-Is, customer approval is required."

### Step 6 — Corrective and Preventive Action (CAPA)

Reference `references/corrective-action.md` and define:

1. **Containment** (immediate) — Already done in Step 3.
2. **Root cause** — Identified in Step 4.
3. **Corrective action** — What will be done to fix this specific issue?
   - Action description
   - Owner (name)
   - Due date
4. **Preventive action** — What will be done to prevent recurrence?
   - Process change, spec update, partner training, inspection change
   - Owner (name)
   - Due date
5. **Verification** — How will Rev A verify the corrective action is effective?
   - Verification method
   - Verification date
   - Verified by

### Step 7 — Cost Impact

Calculate the cost impact of the non-conformance:

| Cost Item | Amount |
|-----------|--------|
| Part cost (affected qty x unit cost) | |
| Rework cost (if applicable) | |
| Shipping cost (if RTV) | |
| Expedite cost (if replacement needed) | |
| Administrative cost (PM time) | |
| **Total NCR cost** | |

### Step 8 — Generate NCR Report

Build the report using `templates/Non-Conformance Report.md`:

1. Fill all `{{PLACEHOLDER}}` variables.
2. Include defect description, root cause, disposition, CAPA, and cost impact.
3. Name the file: `PMLORD-NCR-{{DATE}}-{{PART_NAME}}.md`

### Step 9 — Post-NCR Actions

| Action | Trigger |
|--------|---------|
| Update partner scorecard | Always — run `/pmlord-partner-scorecard` |
| Communicate with partner | If rework or RTV — send NCR details via `/pmlord-customer-comms` (partner mode) |
| Escalate | If critical or repeat NCR — run `/pmlord-escalate` |
| Update tracking | Update china-track milestone status |
| Schedule follow-up | Set CAPA verification date reminder |

## Report Naming

`PMLORD-NCR-{YYYY-MM-DD}-{PartName}.docx`

## State Tracking

Log NCR to `~/.pmlord/state/ncr-log.jsonl`:

```bash
echo '{"ts":"'$(date -u +%Y-%m-%dT%H:%M:%SZ)'","ncr_id":"NCR_ID","part":"PART_NUM","partner":"PARTNER","severity":"SEVERITY","disposition":"DISPOSITION","cost":COST,"status":"open"}' >> ~/.pmlord/state/ncr-log.jsonl
```

## References

- `references/root-cause-methods.md` — 5-Why, Fishbone, 8D methods
- `references/disposition-options.md` — Rework, scrap, use-as-is, RTV
- `references/corrective-action.md` — CAPA framework
