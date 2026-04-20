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

## Invocation Model — IMPORTANT

**This skill is invoked 4 separate times across the order lifecycle.** Each invocation is a distinct call with a `gate` argument (G1, G2, G3, or G4). The gates do NOT run together in a single session — they are triggered by different upstream skills at different lifecycle points.

| Gate | Lifecycle Trigger | Triggered By | When |
|------|------------------|-------------|------|
| **G1** | After incoming inspection ACCEPT | `reva-turbo-inspect` ACCEPT disposition | Parts arrive at Rev A, pass incoming inspection |
| **G2** | Manufacturing in-process checkpoint | `reva-turbo-china-track` milestone M6 (production 50%) | Mid-production quality checkpoint |
| **G3** | Final QC before packaging | `reva-turbo-china-track` milestone M8 (QC passed) | Final quality verification before customer prep |
| **G4** | Pre-shipment sign-off | `reva-turbo-china-track` milestone M9 (packed and ready) | Last check before parts leave Rev A dock |

**Invocation syntax:** `/reva-turbo:reva-turbo-quality-gate gate=G1` (or G2, G3, G4)

If no `gate` argument is provided, proceed to Step 1 (Gate Selection) to ask the PM.

## Four Quality Gates

| Gate | Stage | Description |
|------|-------|-------------|
| **G1** | Incoming | Parts received from China partner. Verify inspection results, documentation, quantities. |
| **G2** | In-Process | During manufacturing at China partner. Verify mid-production quality checkpoint. |
| **G3** | Final | After partner QC passes. Final quality verification before packaging. |
| **G4** | Pre-Ship | Before parts leave Rev A dock. Packaging, labeling, documentation check. |

Reference: `references/gate-definitions.md`

## HITL Gate Policy

| Gate | HITL Requirement | Auto-Pass Allowed? |
|------|-----------------|-------------------|
| G1 | PM review of checklist | Yes, if all criteria met AND trust level ≥ 2 |
| G2 | PM review of checkpoint | Yes, if all criteria met AND trust level ≥ 2 |
| G3 | PM must confirm PASS/FAIL/CONDITIONAL | **Hard gate — NO auto-pass** |
| G4 | PM must confirm PASS/FAIL/CONDITIONAL | **Hard gate — NO auto-pass** |

G3 and G4 are hard gates. PM must explicitly confirm the decision before parts can advance, regardless of trust level.

## Flow

### Step 1 — Gate Selection

**If invoked with `gate=G1/G2/G3/G4`:** Skip the selection prompt and route directly to the appropriate gate flow in Step 3.

**If no gate argument provided,** ask the PM which gate to run:

> Which quality gate are you running?
> A) G1 — Incoming (triggered after reva-turbo-inspect ACCEPT)
> B) G2 — In-Process (triggered by china-track milestone M6)
> C) G3 — Final (triggered by china-track milestone M8)
> D) G4 — Pre-Ship (triggered by china-track milestone M9)

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

**Lifecycle context:** Triggered after `reva-turbo-inspect` returns an ACCEPT disposition. Validates that incoming material meets spec and all documentation is in order before parts are cleared for processing. Auto-pass allowed at Trust Level ≥ 2 if all criteria met.

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

**Lifecycle context:** Triggered by `reva-turbo-china-track` at milestone M6 (production 50% complete). Conducted remotely via partner-provided photos/video and dimensional reports from the factory. This is a manufacturing checkpoint — G2 does not require physical inspection at Rev A.

| # | Check | Pass | Fail | N/A | Notes |
|---|-------|------|------|-----|-------|
| 1 | G1 gate passed (if parts previously received at Rev A) | | | | N/A if first production run checkpoint |
| 2 | Partner production schedule on track (no critical delays) | | | | |
| 3 | First article / first piece approved | | | | |
| 4 | In-process photos or video received from partner | | | | |
| 5 | In-process dimensional report received (if required) | | | | |
| 6 | No visible defects, damage, or contamination in photos | | | | |
| 7 | Traceability maintained (lot/batch tracking confirmed) | | | | |
| 8 | Any rework documented and re-inspected | | | | |

**G2 Pass Criteria:** All checks must PASS or N/A. If rework was performed (check 8), must have re-inspection results. Auto-pass allowed at Trust Level ≥ 2 if all criteria met.

---

#### G3 — Final Gate

**Lifecycle context:** Triggered by `reva-turbo-china-track` at milestone M8 (QC passed by partner). PM must confirm PASS/FAIL/CONDITIONAL — this is a hard gate with no auto-pass.

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

**Lifecycle context:** Triggered by `reva-turbo-china-track` at milestone M9 (packed and ready to ship). PM must confirm PASS/FAIL/CONDITIONAL — this is a hard gate with no auto-pass. G4 PASS is the final sign-off before logistics coordination begins.

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

### Step 4a — Validate Placeholders

Before generating the gate decision record, scan all data fields for any unfilled `{{PLACEHOLDER}}` patterns:

```bash
# Collect all fields to be written into output
_OUTPUT_PREVIEW="{{ALL_FIELDS_CONCATENATED}}"
_MISSING=$(echo "$_OUTPUT_PREVIEW" | grep -oE '\{\{[A-Z_]+\}\}' | sort -u 2>/dev/null)
if [ -n "$_MISSING" ]; then
  echo "UNFILLED FIELDS DETECTED:"
  echo "$_MISSING"
fi
```

If any `{{PLACEHOLDER}}` patterns are found in the data:

> **Unfilled Fields Detected**
>
> The following fields have not been filled in:
>
> {{LIST_OF_MISSING_FIELDS}}
>
> A) Fill in the missing fields now — I'll provide the values
> B) Proceed anyway — I acknowledge these fields are incomplete
> C) Cancel — do not generate this document
>
> Do NOT proceed to output unless PM selects B, or after fields are filled via option A.

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
