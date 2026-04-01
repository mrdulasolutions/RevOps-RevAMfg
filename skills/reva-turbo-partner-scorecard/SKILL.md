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

## Score Calculation Formula

The partner score is a weighted composite of 5 dimensions, each scored 0–100:

| Dimension | Weight | Key Metrics |
|-----------|--------|------------|
| **Quality** | 40% | NCR rate (per order), defect PPM (parts per million), incoming inspection pass rate, first article pass rate |
| **Delivery** | 25% | On-time delivery % (orders delivered on committed date), average delay days (when late), lead time accuracy |
| **Responsiveness** | 15% | Average response time to communications (hours), communication quality and clarity, proactive update rate |
| **Capability** | 10% | Certification coverage (ISO 9001, IATF, AS9100, etc.), process breadth (machining, molding, finishing, etc.) |
| **Commercial** | 10% | Pricing stability (% of unexpected cost increases), payment compliance, tooling cost accuracy |

**Weighted score formula:**

```
Score = (Quality × 0.40) + (Delivery × 0.25) + (Responsiveness × 0.15) + (Capability × 0.10) + (Commercial × 0.10)
```

**Note:** The previous 4-category model (Quality 35%, Delivery 30%, Cost 20%, Communication 15%) is deprecated. The 5-dimension model above is canonical. Existing scorecards using the 4-category model should be recalculated on next refresh.

Reference: `references/scoring-criteria.md`

## Letter Grade Bands

| Score Range | Grade | Description |
|------------|-------|-------------|
| 85–100 | **A** | Excellent — preferred partner; eligible for Direct routing qualification |
| 70–84 | **B** | Good — reliable partner; eligible for Direct routing qualification |
| 55–69 | **C** | Acceptable — monitor closely; Inspect & Forward routing required |
| 40–54 | **D** | Below expectations — corrective action required; 60-day review |
| <40 | **F** | Unacceptable — escalate to Donovan Weber; begin replacement process |

**Routing dependency:** `reva-turbo-logistics` Direct routing qualification requires partner score **A or B**. Partners with score C or below are routed through Inspect & Forward until score improves.

## Refresh Cadence

| Trigger | Action |
|---------|--------|
| After every completed order | Score recalculated for the partner on that order |
| Weekly (automated) | Full scorecard regenerated for all active partners via `reva-turbo-cron` task `weekly-partner-scorecard` |
| Manual refresh | `/reva-turbo:reva-turbo-partner-scorecard refresh <partner>` — recalculates immediately |

## Score Persistence

Scores are written to two locations:
1. **`~/.reva-turbo/state/partner-scores.jsonl`** — append-only event log; one entry per scorecard calculation
2. **`~/.reva-turbo/config/partners.yaml`** — current score and grade written to each partner's record for quick lookup by reva-turbo-logistics and reva-turbo-rfq-qualify

## Routing Dependency Note

- **reva-turbo-logistics:** Reads partner score from `partners.yaml` to determine Direct vs Inspect & Forward routing. Score A or B required for Direct.
- **reva-turbo-rfq-qualify:** Uses partner score as one qualification factor when evaluating whether Rev A can commit to an order with the proposed partner. Score D or F may trigger a CONDITIONAL or REJECT qualification recommendation.

## Scoring Weights (Legacy Reference — Deprecated)

> The following 4-category weighting is deprecated as of 2026-04-01. The 5-dimension model above is the new canonical standard.
>
> | Category | Old Weight |
> |----------|-----------|
> | Quality | 35% |
> | Delivery | 30% |
> | Cost | 20% |
> | Communication | 15% |

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

### Step 5b — Collect Capability and Commercial Data

Ask PM for capability and commercial metrics:

**Capability:**

| Metric | Value |
|--------|-------|
| ISO 9001 certified? | Yes / No / Expired |
| Other certifications (IATF, AS9100, etc.) | List |
| Process types available | Machining, molding, sheet metal, casting, etc. |
| Rev A process coverage (% of Rev A part types this partner can make) | % |

**Commercial:**

| Metric | Value |
|--------|-------|
| Price increases in period (count and %) | |
| Unexpected charges (tooling, rework, expedite) | $ amount |
| Invoice accuracy (% of invoices matching quoted amounts) | % |
| Payment compliance (disputes, short pays, etc.) | None / Occasional / Frequent |

### Step 6 — Calculate Scores (5-Dimension Model)

Score each dimension 0–100 using the criteria in `references/scoring-criteria.md`, then apply the canonical weighted formula:

```
Score = (Quality × 0.40) + (Delivery × 0.25) + (Responsiveness × 0.15) + (Capability × 0.10) + (Commercial × 0.10)
```

| Dimension | Raw Score (0–100) | Weight | Weighted |
|-----------|------------------|--------|---------|
| Quality | {{QUALITY_RAW}} | 40% | {{QUALITY_WEIGHTED}} |
| Delivery | {{DELIVERY_RAW}} | 25% | {{DELIVERY_WEIGHTED}} |
| Responsiveness | {{RESP_RAW}} | 15% | {{RESP_WEIGHTED}} |
| Capability | {{CAP_RAW}} | 10% | {{CAP_WEIGHTED}} |
| Commercial | {{COMM_RAW}} | 10% | {{COMM_WEIGHTED}} |
| **TOTAL** | — | 100% | **{{TOTAL_SCORE}}** |

### Step 7 — Assign Letter Grade

| Score Range | Grade | Description |
|------------|-------|-------------|
| 85–100 | **A** | Excellent — preferred partner; Direct routing eligible |
| 70–84 | **B** | Good — reliable partner; Direct routing eligible |
| 55–69 | **C** | Acceptable — monitor closely; I&F routing required |
| 40–54 | **D** | Below expectations — corrective action needed |
| <40 | **F** | Unacceptable — escalate to Donovan Weber |

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

Scores are written to two locations:

**1. Append-only event log** — `~/.reva-turbo/state/partner-scores.jsonl`:

```bash
echo '{"ts":"'$(date -u +%Y-%m-%dT%H:%M:%SZ)'","partner":"PARTNER","period":"PERIOD","quality":Q,"delivery":D,"responsiveness":R,"capability":CAP,"commercial":COM,"total":TOTAL,"grade":"GRADE","direct_routing_eligible":true}' >> ~/.reva-turbo/state/partner-scores.jsonl
```

**2. Partner master record** — update `~/.reva-turbo/config/partners.yaml` to reflect current score and grade:

The `score` and `grade` fields in the partner's YAML record should be updated after each scorecard calculation so that reva-turbo-logistics and reva-turbo-rfq-qualify can read the current score without querying the full JSONL log.

## References

- `references/scoring-criteria.md` — Detailed scoring criteria by category
- `references/benchmark-targets.md` — Target metrics and benchmarks
