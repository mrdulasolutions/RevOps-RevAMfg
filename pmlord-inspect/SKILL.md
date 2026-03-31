---
name: pmlord-inspect
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
mkdir -p ~/.pmlord/analytics
echo '{"skill":"pmlord-inspect","ts":"'$(date -u +%Y-%m-%dT%H:%M:%SZ)'"}' >> ~/.pmlord/analytics/skill-usage.jsonl 2>/dev/null || true
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

1. Check for a saved manufacturing package at `~/.pmlord/state/` matching the part number.
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

### Step 8 — Generate Inspection Report

Build the report using `templates/Inspection Report.md`:

1. Fill all `{{PLACEHOLDER}}` variables.
2. Include all inspection data (visual, dimensional, material, functional).
3. Include disposition and justification.
4. Name the file: `PMLORD-INSP-{{DATE}}-{{PART_NAME}}.md`

### Step 9 — Post-Disposition Actions

| Disposition | Next Action |
|------------|-------------|
| **ACCEPT** | "Parts accepted. Run `/pmlord-quality-gate` for G1 gate check? Or `/pmlord-repackage` to prepare for customer shipment?" |
| **REJECT** | "Parts rejected. Run `/pmlord-ncr` to create a Non-Conformance Report?" |
| **HOLD** | "Parts on hold. Escalate to Senior PM (Ray Yeh or Harley Scott) for engineering review." |

## Report Naming

`PMLORD-INSP-{YYYY-MM-DD}-{PartName}.docx`

## State Tracking

Log inspection results to `~/.pmlord/state/inspection-log.jsonl`:

```bash
echo '{"ts":"'$(date -u +%Y-%m-%dT%H:%M:%SZ)'","part":"PART_NUM","po":"PO_NUM","partner":"PARTNER","qty_received":QTY,"disposition":"DISPOSITION","inspector":"PM_NAME"}' >> ~/.pmlord/state/inspection-log.jsonl
```

## References

- `references/inspection-procedures.md` — Standard inspection procedures
- `references/measurement-standards.md` — Measurement methods and tools
- `references/accept-reject-criteria.md` — Disposition criteria by defect type
