---
name: reva-turbo-partner-scorecard
description: |
  Evaluate manufacturing partner performance across quality, delivery, cost,
  and communication. Generate weighted scores and A-F letter grades.
  Supports partner comparison and trend analysis.
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
echo '{"skill":"reva-turbo-partner-scorecard","ts":"'$(date -u +%Y-%m-%dT%H:%M:%SZ)'"}' >> ~/.reva-turbo/analytics/skill-usage.jsonl 2>/dev/null || true
```

## Purpose

Generate a weighted performance scorecard for manufacturing partners. Score across four categories (quality, delivery, cost, communication), assign an A-F letter grade, identify strengths and weaknesses, and recommend actions.

## Scoring Weights

| Category | Weight | Description |
|----------|--------|-------------|
| Quality | 35% | Defect rate, NCRs, first article pass rate, returns |
| Delivery | 30% | On-time delivery, lead time accuracy, milestone adherence |
| Cost | 20% | Price competitiveness, cost stability, hidden costs |
| Communication | 15% | Responsiveness, proactive updates, issue resolution speed |

Reference: `references/scoring-criteria.md`

## Flow

### Step 1 — Identify Partner

Ask the PM:

1. **Partner name:** Manufacturing partner being evaluated
2. **Evaluation period:** Date range (e.g., Q1 2026, or last 12 months)
3. **Number of orders in period:** Total POs placed
4. **Orders completed in period:** POs fully delivered

### Step 2 — Collect Quality Data

Ask the PM for quality metrics:

| Metric | Value |
|--------|-------|
| Total parts received | |
| Parts rejected (incoming inspection) | |
| NCRs issued | |
| First article pass rate (%) | |
| Customer returns attributable to partner | |
| Rework required (Y/N, frequency) | |

Calculate:
- **Defect rate** = (parts rejected / total parts received) x 100
- **NCR rate** = NCRs / orders completed
- **First pass yield** = first article pass rate

### Step 3 — Collect Delivery Data

Ask the PM for delivery metrics:

| Metric | Value |
|--------|-------|
| Orders delivered on time | |
| Orders delivered late | |
| Average days late (when late) | |
| Lead time quoted vs. actual (average) | |
| Milestone updates provided on time? | |

Calculate:
- **On-time delivery rate** = (on-time orders / total completed orders) x 100
- **Lead time accuracy** = (quoted lead time / actual lead time) x 100

### Step 4 — Collect Cost Data

Ask the PM for cost metrics:

| Metric | Value |
|--------|-------|
| Price competitiveness vs. market (estimate) | Above / At / Below |
| Price increases in period | Count and % |
| Unexpected charges (tooling, rework, expedite) | $ amount |
| Tooling costs vs. quoted | Over / At / Under |

### Step 5 — Collect Communication Data

Ask the PM for communication metrics:

| Metric | Value |
|--------|-------|
| Average response time to emails/messages | Hours |
| Proactive updates provided? | Always / Sometimes / Rarely |
| Language barrier issues? | None / Occasional / Frequent |
| Issue resolution speed | Fast / Average / Slow |
| Dedicated contact person? | Yes / No |

### Step 6 — Calculate Scores

Score each category 0-100 using the criteria in `references/scoring-criteria.md`, then apply weights:

```
Weighted Score = (Quality Score x 0.35) + (Delivery Score x 0.30) + (Cost Score x 0.20) + (Communication Score x 0.15)
```

### Step 7 — Assign Letter Grade

| Score Range | Grade | Description |
|------------|-------|-------------|
| 90-100 | A | Excellent — preferred partner |
| 80-89 | B | Good — reliable partner |
| 70-79 | C | Acceptable — monitor closely |
| 60-69 | D | Below expectations — corrective action needed |
| Below 60 | F | Unacceptable — consider replacing |

### Step 8 — Generate Scorecard

Build the scorecard using `templates/Partner Scorecard.md`:

1. Fill all `{{PLACEHOLDER}}` variables.
2. Include category scores, weighted total, and letter grade.
3. Include strengths, weaknesses, and recommended actions.
4. Name the file: `REVA-TURBO-SCORE-{{DATE}}-{{PARTNER_NAME}}.md`

> **HUMAN-IN-THE-LOOP:** "Here is the partner scorecard. Review the scores and recommendations. Approve or adjust before filing."

### Step 9 — Suggest Actions

Based on the grade:

| Grade | Suggested Action |
|-------|-----------------|
| A | Maintain relationship. Consider increasing order volume. |
| B | Continue partnership. Address minor issues. |
| C | Schedule improvement meeting with partner. Set 90-day review. |
| D | Issue formal corrective action request. Set 60-day review. Identify backup partner. |
| F | Escalate to Donovan Weber. Begin partner replacement process. |

## Report Naming

`REVA-TURBO-SCORE-{YYYY-MM-DD}-{PartnerName}.docx`

## State Tracking

Log scorecard results to `~/.reva-turbo/state/partner-scores.jsonl`:

```bash
echo '{"ts":"'$(date -u +%Y-%m-%dT%H:%M:%SZ)'","partner":"PARTNER","period":"PERIOD","quality":Q,"delivery":D,"cost":C,"communication":COM,"total":TOTAL,"grade":"GRADE"}' >> ~/.reva-turbo/state/partner-scores.jsonl
```

## References

- `references/scoring-criteria.md` — Detailed scoring criteria by category
- `references/benchmark-targets.md` — Target metrics and benchmarks
