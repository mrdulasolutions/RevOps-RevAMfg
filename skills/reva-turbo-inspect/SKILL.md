---
name: reva-turbo-inspect
description: |
  Incoming inspection workflow for parts received from manufacturing partners.
  Check against original specs, document findings, and assign disposition:
  ACCEPT, REJECT, or HOLD.
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
echo '{"skill":"reva-turbo-inspect","ts":"'$(date -u +%Y-%m-%dT%H:%M:%SZ)'"}' >> ~/.reva-turbo/analytics/skill-usage.jsonl 2>/dev/null || true
```

## Purpose

Guide PMs through the incoming inspection process when parts arrive from manufacturing partners. Compare received parts against original specifications, document all findings, and assign a disposition of ACCEPT, REJECT, or HOLD.

## Flow

### Step 1 — Identify Shipment

Ask the PM for receiving information:

| Field | Required | Notes |
|-------|----------|-------|
| Part number (Rev A) | Yes | |
| PO number | Yes | |
| Manufacturing partner | Yes | |
| Quantity received | Yes | |
| Quantity ordered | Yes | |
| Date received | Yes | |
| Packing list present? | Yes | Y/N |
| Condition of packaging | Yes | Good / Damaged / Poor |

### Step 2 — Locate Original Specs

Search for the original manufacturing package:

1. Check for a saved manufacturing package at `~/.reva-turbo/state/` matching the part number.
2. Ask the PM to confirm the spec revision that was sent to the partner.
3. Load the spec to use as the inspection baseline.

If no saved spec is found, ask the PM to provide: material, finish, critical dimensions, tolerances, and drawing references.

### Step 3 — Visual Inspection

Reference `references/inspection-procedures.md` and guide the PM through visual checks:

| Check | Pass | Fail | Notes |
|-------|------|------|-------|
| Parts match drawing (shape, features) | | | |
| Surface finish acceptable | | | |
| No visible defects (cracks, scratches, dents) | | | |
| Correct color/finish | | | |
| Markings/labels correct | | | |
| No corrosion or contamination | | | |
| Parts properly protected/wrapped | | | |
| Quantity matches packing list | | | |

Ask the PM to fill in pass/fail for each check.

### Step 4 — Dimensional Inspection

Reference `references/measurement-standards.md` and guide dimensional checks:

1. **Sample size:** Determine sample size based on order quantity (use AQL Level II from quality-checkpoints reference, or 100% for critical dims on small orders).
2. **Critical dimensions:** Check all critical dimensions flagged in the original spec.
3. **General dimensions:** Spot-check a sample of non-critical dimensions.
4. **GD&T:** Verify any GD&T callouts (flatness, perpendicularity, true position, etc.).

Record results:

| Dim # | Feature | Nominal (mm) | Tolerance | Measured | Pass/Fail |
|-------|---------|-------------|-----------|----------|-----------|
| 1 | | | | | |
| 2 | | | | | |

### Step 5 — Material Verification

| Check | Result | Notes |
|-------|--------|-------|
| Material certificate (CoC) received? | | |
| Material matches specification? | | |
| Hardness check (if applicable) | | |
| Material test report matches? | | |

### Step 6 — Functional Check (if applicable)

| Check | Result | Notes |
|-------|--------|-------|
| Parts assemble correctly? | | |
| Thread engagement acceptable? | | |
| Fit with mating parts verified? | | |
| Function test passed? | | |

### Step 7 — Determine Disposition

Reference `references/accept-reject-criteria.md` and assign disposition:

| Disposition | Criteria |
|------------|---------|
| **ACCEPT** | All checks pass. Parts meet all specification requirements. |
| **REJECT** | One or more critical dimensions out of tolerance, material non-conformance, or functional failure. Parts cannot be used as-is. |
| **HOLD** | Minor deviations found. Need engineering review or customer approval to determine usability. Parts are quarantined pending decision. |

> **HUMAN-IN-THE-LOOP:** "Based on the inspection findings, the recommended disposition is [ACCEPT/REJECT/HOLD]. Do you confirm this disposition?"

### Step 7a — Validate Placeholders

Before generating the inspection report, scan all data fields for any unfilled `{{PLACEHOLDER}}` patterns:

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

### Step 8 — Generate Inspection Report

Build the report using `templates/Inspection Report.md`:

1. Fill all `{{PLACEHOLDER}}` variables.
2. Include all inspection data (visual, dimensional, material, functional).
3. Include disposition and justification.
4. Name the file: `REVA-TURBO-INSP-{{DATE}}-{{PART_NAME}}.md`

### Step 9 — Post-Disposition Actions

| Disposition | Next Action |
|------------|-------------|
| **ACCEPT** | "Parts accepted. Run `/reva-turbo:reva-turbo-quality-gate` for G1 gate check? Or `/reva-turbo:reva-turbo-repackage` to prepare for customer shipment?" |
| **REJECT** | "Parts rejected. Run `/reva-turbo:reva-turbo-ncr` to create a Non-Conformance Report?" — auto-suggest reva-turbo-ncr on REJECT |
| **HOLD** | "Parts on hold. Escalate to Senior PM (Ray Yeh or Harley Scott) for engineering review." — notify via reva-turbo-pulse on HOLD |

**Auto-triggers:**
- **REJECT** → automatically suggest `/reva-turbo:reva-turbo-ncr`. If autopilot is active at Trust Level 3, auto-invoke NCR creation.
- **HOLD** → invoke reva-turbo-pulse to fire a HOLD alert to PM and Senior PM. Do NOT advance the order until HOLD is resolved.

---

## AQL Sampling Plan

Use ANSI/ASQ Z1.4 standard for sampling-based inspection. Always present the sample size to the PM before beginning dimensional inspection.

**Standard:** ANSI/ASQ Z1.4 — Inspection Level II — AQL 1.0

| Lot Size (Qty Received) | Sample Size | Accept If ≤ | Reject If ≥ |
|------------------------|-------------|------------|------------|
| 2–8 | 100% inspect | 0 defects | 1 defect |
| 9–15 | 8 pcs | 0 defects | 1 defect |
| 16–25 | 13 pcs | 0 defects | 1 defect |
| 26–50 | 20 pcs | 0 defects | 1 defect |
| 51–90 | 32 pcs | 1 defect | 2 defects |
| 91–150 | 50 pcs | 1 defect | 2 defects |
| 151–280 | 80 pcs | 2 defects | 3 defects |
| 281–500 | 125 pcs | 3 defects | 4 defects |
| 501–1200 | 200 pcs | 5 defects | 6 defects |
| 1201+ | 315 pcs | 7 defects | 8 defects |

**Before starting dimensional inspection, present to PM:**

> For a lot of {{QUANTITY_RECEIVED}} pieces, inspect **{{SAMPLE_SIZE}} pieces** per AQL 1.0 (ANSI/ASQ Z1.4 Level II).
> Accept if ≤ {{ACCEPT_NUMBER}} defects. Reject if ≥ {{REJECT_NUMBER}} defects.
>
> A) Proceed with AQL sample inspection
> B) Inspect 100% of parts (higher cost, slower — appropriate for critical parts)
> C) Adjust AQL level (provide justification)

**Notes:**
- 100% inspection is always appropriate for: safety-critical parts, ITAR-controlled hardware, first article inspection (FAI), or when customer contract requires 100%.
- AQL sampling does not replace visual inspection of all parts — 100% visual, AQL-sampled dimensional.
- If a defect is found during AQL sampling, complete the full sample before making disposition. Do not stop at first defect.

## Report Naming

`REVA-TURBO-INSP-{YYYY-MM-DD}-{PartName}.docx`

## State Tracking

Log inspection results to `~/.reva-turbo/state/inspection-log.jsonl`:

```bash
echo '{"ts":"'$(date -u +%Y-%m-%dT%H:%M:%SZ)'","part":"PART_NUM","po":"PO_NUM","partner":"PARTNER","qty_received":QTY,"disposition":"DISPOSITION","inspector":"PM_NAME"}' >> ~/.reva-turbo/state/inspection-log.jsonl
```

## References

- `references/inspection-procedures.md` — Standard inspection procedures
- `references/measurement-standards.md` — Measurement methods and tools
- `references/accept-reject-criteria.md` — Disposition criteria by defect type
