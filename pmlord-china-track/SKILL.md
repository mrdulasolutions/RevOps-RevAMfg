---
name: pmlord-china-track
description: |
  Track manufacturing progress with Chinese partners using a 10-milestone
  system. Detect delays, schedule quality checkpoints, and generate
  progress reports.
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
echo '{"skill":"pmlord-china-track","ts":"'$(date -u +%Y-%m-%dT%H:%M:%SZ)'"}' >> ~/.pmlord/analytics/skill-usage.jsonl 2>/dev/null || true
```

## Purpose

Track manufacturing progress through 10 defined milestones from spec confirmation to shipment. Detect delays early, assign standardized delay codes, schedule quality checkpoints, and generate progress reports for PM review.

## 10-Milestone System

| # | Milestone | Typical Duration |
|---|-----------|-----------------|
| M1 | Specs confirmed by partner | 1-3 days |
| M2 | Tooling started | 1-5 days after M1 |
| M3 | Tooling complete / First article produced | 2-6 weeks after M2 |
| M4 | First article approved | 3-7 days after M3 |
| M5 | Production started | 1-3 days after M4 |
| M6 | Production 50% complete | Varies by qty |
| M7 | Production complete | Varies by qty |
| M8 | QC passed | 2-5 days after M7 |
| M9 | Packed and ready to ship | 1-3 days after M8 |
| M10 | Shipped | 1-2 days after M9 |

Reference: `references/milestone-definitions.md`

## Flow

### Step 1 — Identify Order

Ask the PM:

1. **Part number:** Rev A part number (e.g., RA-12345)
2. **PO number:** Purchase order reference
3. **Partner name:** Manufacturing partner
4. **Order date:** When the order was placed
5. **Target delivery date:** Expected arrival at Rev A

### Step 2 — Set Milestone Baseline

Calculate expected dates for each milestone based on:
- Order date
- Part complexity (simple machined, complex machined, injection molded, sheet metal, assembly)
- Quantity
- Historical partner performance (if available)

Present the baseline schedule to the PM for confirmation:

> **HUMAN-IN-THE-LOOP:** "Here is the proposed milestone schedule. Approve these dates or adjust as needed."

### Step 3 — Record Current Status

Ask the PM for the current milestone status:

1. Which milestone has been reached?
2. Date achieved for each completed milestone.
3. Any delays or issues?

### Step 4 — Delay Detection

Compare actual dates against baseline. Flag delays using standardized delay codes from `references/delay-codes.md`:

| Delay Status | Criteria |
|-------------|----------|
| **On Track** | Within 2 business days of baseline |
| **At Risk** | 3-5 business days behind baseline |
| **Delayed** | More than 5 business days behind baseline |
| **Critical** | More than 10 business days behind, or delivery date at risk |

For any delay:
1. Assign a delay code (e.g., DLY-MTL for material delay).
2. Ask PM for root cause notes.
3. Calculate impact on final delivery date.
4. If status is **Critical**, suggest escalation: "This delay may impact the customer delivery date. Escalate to Senior PM? (`/pmlord-escalate`)"

### Step 5 — Quality Checkpoint Scheduling

Reference `references/quality-checkpoints.md` and schedule inspections:

| Checkpoint | Timing | Type |
|-----------|--------|------|
| First Article Inspection | At M3 (tooling complete) | Remote photo/video + dimensional report |
| In-Process Check | At M6 (production 50%) | Remote photo/video or onsite if high-value |
| Final QC | At M8 (QC passed) | Full inspection report from partner |
| Pre-Ship Verification | At M9 (packed) | Packing photos, quantity verification |

> **HUMAN-IN-THE-LOOP:** "These quality checkpoints are scheduled. Confirm or adjust the inspection plan."

### Step 6 — Generate Progress Report

Build the progress report using `templates/Manufacturing Progress Report.md`:

1. Fill all `{{PLACEHOLDER}}` variables.
2. Include a milestone timeline (completed, current, upcoming).
3. Include delay summary with codes and impact analysis.
4. Include quality checkpoint status.
5. Name the file: `PMLORD-TRACK-{{DATE}}-{{PART_NAME}}.md`

### Step 7 — Suggest Next Action

Based on current milestone:

| Current Milestone | Next Suggestion |
|------------------|-----------------|
| M3 (First article) | "First article is ready. Run `/pmlord-inspect` to set up the FAI checklist?" |
| M8 (QC passed) | "QC passed. Run `/pmlord-quality-gate` for G1 incoming gate?" |
| M10 (Shipped) | "Order shipped. Run `/pmlord-logistics` to track shipment?" |
| Any delay | "Delay detected. Run `/pmlord-escalate` to notify stakeholders?" |

## Report Naming

`PMLORD-TRACK-{YYYY-MM-DD}-{PartName}.docx`

## State Tracking

Log milestone updates to `~/.pmlord/state/china-track.jsonl`:

```bash
echo '{"ts":"'$(date -u +%Y-%m-%dT%H:%M:%SZ)'","part":"PART_NUM","po":"PO_NUM","partner":"PARTNER","milestone":"M#","status":"STATUS","delay_code":"CODE","notes":"NOTES"}' >> ~/.pmlord/state/china-track.jsonl
```

## References

- `references/milestone-definitions.md` — 10 milestones with durations
- `references/delay-codes.md` — Standardized delay reason codes
- `references/quality-checkpoints.md` — Inspection scheduling guidance
