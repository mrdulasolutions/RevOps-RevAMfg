---
name: reva-turbo-quality-gate
description: |
  Quality gate checks at each manufacturing stage. Four gates: G1 (incoming),
  G2 (in-process), G3 (final), G4 (pre-ship). Decision: PASS, CONDITIONAL
  PASS, or FAIL.
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
mkdir -p ~/.reva-turbo/analytics
echo '{"skill":"reva-turbo-quality-gate","ts":"'$(date -u +%Y-%m-%dT%H:%M:%SZ)'"}' >> ~/.reva-turbo/analytics/skill-usage.jsonl 2>/dev/null || true
```

## Purpose

Execute quality gate checks at defined stages of the Rev A workflow. Each gate has specific criteria that must be met before parts can advance to the next stage. Gate decisions are PASS, CONDITIONAL PASS, or FAIL.

## Four Quality Gates

| Gate | Stage | Description |
|------|-------|-------------|
| **G1** | Incoming | Parts received from China partner. Verify inspection results, documentation, quantities. |
| **G2** | In-Process | During any Rev A processing (rework, secondary ops, sub-assembly). Verify process quality. |
| **G3** | Final | Before customer shipment preparation. Final quality verification. |
| **G4** | Pre-Ship | Before parts leave Rev A dock. Packaging, labeling, documentation check. |

Reference: `references/gate-definitions.md`

## Flow

### Step 1 — Select Gate

Ask the PM which gate to run:

> Which quality gate are you running?
> A) G1 — Incoming (parts just received from partner)
> B) G2 — In-Process (during Rev A processing)
> C) G3 — Final (before customer shipment prep)
> D) G4 — Pre-Ship (ready to ship to customer)

### Step 2 — Identify Order

| Field | Required |
|-------|----------|
| Part number (Rev A) | Yes |
| Part name | Yes |
| PO number | Yes |
| Customer | Yes |
| Quantity | Yes |
| Gate number | Yes (from Step 1) |

### Step 3 — Run Gate Checklist

Execute the gate-specific checklist from `references/gate-definitions.md`.

---

#### G1 — Incoming Gate

| # | Check | Pass | Fail | N/A | Notes |
|---|-------|------|------|-----|-------|
| 1 | Incoming inspection report completed (`/reva-turbo:reva-turbo-inspect`) | | | | |
| 2 | Inspection disposition is ACCEPT | | | | |
| 3 | All critical dimensions verified in tolerance | | | | |
| 4 | Material certification (CoC) received and matches spec | | | | |
| 5 | Quantity received matches PO (within acceptable variance) | | | | |
| 6 | No open NCRs against this shipment | | | | |
| 7 | Partner QC report reviewed | | | | |
| 8 | Packing list matches received goods | | | | |
| 9 | Parts properly stored/quarantined pending gate | | | | |
| 10 | Drawing revision matches what was sent to partner | | | | |

**G1 Pass Criteria:** All checks 1-6 must PASS. Checks 7-10 must PASS or N/A.

---

#### G2 — In-Process Gate

| # | Check | Pass | Fail | N/A | Notes |
|---|-------|------|------|-----|-------|
| 1 | G1 gate passed | | | | |
| 2 | Work order / routing documented | | | | |
| 3 | First piece approved (if applicable) | | | | |
| 4 | In-process dimensions checked per routing | | | | |
| 5 | Process parameters within control limits | | | | |
| 6 | No damage from handling or processing | | | | |
| 7 | Traceability maintained (lot/batch tracking) | | | | |
| 8 | Any rework documented and re-inspected | | | | |

**G2 Pass Criteria:** All checks must PASS or N/A. If rework was performed (check 8), must have re-inspection results.

---

#### G3 — Final Gate

| # | Check | Pass | Fail | N/A | Notes |
|---|-------|------|------|-----|-------|
| 1 | All prior gates passed (G1, G2 if applicable) | | | | |
| 2 | Final dimensional inspection complete | | | | |
| 3 | Visual inspection — no cosmetic defects | | | | |
| 4 | Functional check passed (if applicable) | | | | |
| 5 | All customer-specific requirements verified | | | | |
| 6 | Certificate of Conformance prepared | | | | |
| 7 | All NCRs resolved (closed or dispositioned) | | | | |
| 8 | Test reports / certifications complete | | | | |
| 9 | Parts match customer-approved sample (if applicable) | | | | |
| 10 | Customer-specific labeling requirements met | | | | |

**G3 Pass Criteria:** Checks 1-7 must PASS. Checks 8-10 must PASS or N/A.

---

#### G4 — Pre-Ship Gate

| # | Check | Pass | Fail | N/A | Notes |
|---|-------|------|------|-----|-------|
| 1 | G3 gate passed | | | | |
| 2 | Correct quantity packed | | | | |
| 3 | Packaging protects parts during transit | | | | |
| 4 | Customer-specific packaging requirements met | | | | |
| 5 | Labels correct (part number, qty, PO, Rev A info) | | | | |
| 6 | Packing list included and accurate | | | | |
| 7 | CoC / test reports included in shipment | | | | |
| 8 | Shipping documents prepared (BOL, customs if intl) | | | | |
| 9 | Carrier and shipping method confirmed | | | | |
| 10 | Customer notified of pending shipment | | | | |

**G4 Pass Criteria:** Checks 1-7 must PASS. Checks 8-10 must PASS or N/A.

---

### Step 4 — Gate Decision

Reference `references/hold-release-criteria.md` and determine the gate decision:

| Decision | Criteria |
|----------|---------|
| **PASS** | All required checks pass. No open issues. Parts advance to next stage. |
| **CONDITIONAL PASS** | Minor issues identified but parts can advance with documented conditions. Requires Senior PM approval. |
| **FAIL** | One or more critical checks fail. Parts do NOT advance. Corrective action required. |

> **HUMAN-IN-THE-LOOP:** "Gate {{GATE}} result: [PASS/CONDITIONAL PASS/FAIL]. Do you confirm this decision?"

For CONDITIONAL PASS, document:
1. What condition must be met.
2. Who is responsible.
3. Deadline for condition to be met.
4. What happens if condition is not met (revert to FAIL).

### Step 5 — Generate Gate Checklist

Build the report using `templates/Quality Gate Checklist.md`:

1. Fill all `{{PLACEHOLDER}}` variables.
2. Include all checklist items with results.
3. Include gate decision and any conditions.
4. Name the file: `REVA-TURBO-GATE-{{GATE_NUM}}-{{DATE}}-{{PART_NAME}}.md`

### Step 6 — Post-Gate Actions

| Decision | Next Action |
|----------|-------------|
| **G1 PASS** | "G1 passed. Parts cleared for processing. Need G2 (in-process) or skip to G3 (final)?" |
| **G2 PASS** | "G2 passed. Run G3 (final gate) when processing is complete?" |
| **G3 PASS** | "G3 passed. Run G4 (pre-ship gate) when ready to ship? Or `/reva-turbo:reva-turbo-repackage` first?" |
| **G4 PASS** | "G4 passed. Parts cleared for shipment. Run `/reva-turbo:reva-turbo-logistics` to arrange shipping?" |
| **CONDITIONAL PASS** | "Conditional pass. Set reminder for condition deadline via `/reva-turbo:reva-turbo-reminder`?" |
| **FAIL** | "Gate failed. Run `/reva-turbo:reva-turbo-ncr` for non-conformance report? Or `/reva-turbo:reva-turbo-escalate` if urgent?" |

## Report Naming

`REVA-TURBO-GATE-{G#}-{YYYY-MM-DD}-{PartName}.docx`

## State Tracking

Log gate results to `~/.reva-turbo/state/quality-gates.jsonl`:

```bash
echo '{"ts":"'$(date -u +%Y-%m-%dT%H:%M:%SZ)'","gate":"G#","part":"PART_NUM","po":"PO_NUM","customer":"CUSTOMER","decision":"DECISION","conditions":"CONDITIONS","pm":"PM_NAME"}' >> ~/.reva-turbo/state/quality-gates.jsonl
```

## References

- `references/gate-definitions.md` — Criteria for each gate stage
- `references/hold-release-criteria.md` — When to hold vs. release
