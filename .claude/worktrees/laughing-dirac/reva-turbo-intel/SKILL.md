---
name: reva-turbo-intel
preamble-tier: 1
version: 1.0.0
description: |
  Predictive analytics and business intelligence. Learns from historical
  JSONL data to make predictions, recommendations, and surface insights.
  Transforms REVA-TURBO from a logger into an advisor — predicting delays,
  recommending partners, optimizing quotes, and detecting anomalies.
compatibility: Claude Code, Claude desktop, Claude CoWork
allowed-tools:
  - Bash
  - Read
  - Write
  - Edit
  - Glob
  - Grep
  - AskUserQuestion
---

## Preamble (run first)

```bash
mkdir -p ~/.reva-turbo/analytics
echo '{"skill":"reva-turbo-intel","ts":"'$(date -u +%Y-%m-%dT%H:%M:%SZ)'"}' >> ~/.reva-turbo/analytics/skill-usage.jsonl 2>/dev/null || true
```

## Purpose

Intel transforms REVA-TURBO's historical data into forward-looking intelligence. Every JSONL log, every scorecard entry, every audit trail record is a data point. Intel reads the patterns, calculates the probabilities, and gives the PM advice they can act on — not just data they have to interpret.

This is the skill that turns "we processed 200 orders last quarter" into "Partner ABC delivers 4 days faster than Partner XYZ for CNC parts, and your quote-to-win rate drops 23% when lead time exceeds 6 weeks."

## Flow

### Step 1 — Analysis Request

Ask the PM what kind of intelligence they need:

> **REVA-TURBO Intel — What do you want to know?**
>
> A) **Predict** — "Will this order ship on time?" / "What's the risk on this RFQ?"
> B) **Recommend** — "Which partner for this job?" / "What price should we quote?"
> C) **Optimize** — "How should we price this?" / "Where are we losing margin?"
> D) **Alert** — "What patterns look like trouble?" / "Any anomalies?"
> E) **Benchmark** — "How are we doing vs. last quarter?" / "KPI trends?"
> F) **Full Intel Report** — Comprehensive analysis across all modes
>
> Or just describe what you want to know in plain language.

Capture the analysis parameters using `prompts/intel-user-template.md`:

```bash
echo '{"ts":"'$(date -u +%Y-%m-%dT%H:%M:%SZ)'","pm":"{{PM_NAME}}","analysis_type":"{{ANALYSIS_TYPE}}","scope":"{{SCOPE}}","time_period":"{{TIME_PERIOD}}","entity":"{{ENTITY_FILTER}}","comparison":"{{COMPARISON_TYPE}}"}' >> ~/.reva-turbo/analytics/intel-requests.jsonl 2>/dev/null || true
```

### Step 2 — Data Collection

Read all relevant JSONL data sources:

| Data Source | File Path | Intelligence Value |
|-------------|-----------|-------------------|
| Skill usage | `~/.reva-turbo/analytics/skill-usage.jsonl` | PM activity patterns, skill frequency |
| Workflow state | `~/.reva-turbo/state/workflow-state.jsonl` | Stage durations, transition patterns, bottlenecks |
| Active orders | `~/.reva-turbo/state/active-orders.jsonl` | Current pipeline, stage distribution |
| Active RFQs | `~/.reva-turbo/state/active-rfqs.jsonl` | Quote pipeline, conversion tracking |
| NCR log | `~/.reva-turbo/state/ncr-log.jsonl` | Defect types, partner quality, cost of poor quality |
| Partner scores | `~/.reva-turbo/state/partner-scores.jsonl` | Partner trends, comparative performance |
| Inspection records | `~/.reva-turbo/state/inspection-log.jsonl` | First pass yield, defect Pareto |
| Invoice tracker | `~/.reva-turbo/state/invoices.jsonl` | Revenue, payment patterns, DSO |
| Escalation log | `~/.reva-turbo/state/escalations.jsonl` | Issue frequency, resolution patterns |
| Customer profiles | `~/.reva-turbo/state/customer-profiles.jsonl` | CLV, order history, churn signals |
| Pulse alerts | `~/.reva-turbo/state/pulse-alerts.jsonl` | Alert frequency, resolution times |
| Autopilot log | `~/.reva-turbo/state/autopilot-config.jsonl` | Automation adoption, time savings |
| Carryover log | `~/.reva-turbo/state/carryover-log.jsonl` | Workflow velocity |
| Audit trail | `~/.reva-turbo/state/audit-trail.jsonl` | Decision history, compliance |

For each source, load the data and parse into structured records. If a file does not exist, note it as unavailable and work with what is available. Never refuse to analyze because some data is missing — provide the best analysis possible with the data at hand, and note data gaps.

### Step 3 — Analysis Execution

Execute the requested analysis type. Reference `references/analysis-methods.md` for methodology and `references/kpi-formulas.md` for calculations.

#### Mode A: Predict

**On-time delivery prediction:**
1. Load the order's current stage, milestone history, and partner assignment.
2. Pull historical data for the same partner, same process type, same part complexity tier.
3. Calculate the partner's historical on-time rate for similar orders.
4. Adjust for current factors: number of concurrent orders at partner, current delay status, season.
5. Output a probability with confidence interval:

> **On-time delivery probability for {{ORDER_ID}}:**
> **{{PROBABILITY}}%** (confidence: {{CONFIDENCE_LEVEL}})
>
> Based on {{DATA_POINTS}} similar orders with {{PARTNER_NAME}}.
>
> Risk factors:
> - {{RISK_FACTOR_1}} (impact: {{IMPACT_1}})
> - {{RISK_FACTOR_2}} (impact: {{IMPACT_2}})
>
> Mitigations:
> - {{MITIGATION_1}}
> - {{MITIGATION_2}}

**Quote win prediction:**
1. Load the RFQ details: customer, part type, quantity, requested timeline.
2. Pull historical win/loss data for similar RFQs (same customer, similar part type, similar quantity range).
3. Calculate win probability based on price point, lead time, customer relationship history.
4. Output:

> **Quote win probability for {{RFQ_ID}}:**
> **{{WIN_PROBABILITY}}%** (confidence: {{CONFIDENCE_LEVEL}})
>
> Key factors:
> - Price competitiveness: {{PRICE_FACTOR}}
> - Lead time competitiveness: {{LEADTIME_FACTOR}}
> - Customer relationship: {{RELATIONSHIP_FACTOR}}
> - Historical conversion for this customer: {{CUSTOMER_CONVERSION_RATE}}%

#### Mode B: Recommend

**Partner recommendation:**
1. Load the order requirements: process type, material, quantity, timeline, quality requirements.
2. Pull all qualified partner scorecards.
3. Rank partners by weighted criteria: quality score (30%), delivery score (25%), cost score (25%), communication score (10%), capacity (10%).
4. Adjust for current load: penalize partners with high concurrent order counts.
5. Output top 3 recommendations:

> **Partner Recommendations for {{ORDER_ID}}:**
>
> | Rank | Partner | Score | Strengths | Risk |
> |------|---------|-------|-----------|------|
> | 1 | {{PARTNER_1}} | {{SCORE_1}} | {{STRENGTHS_1}} | {{RISK_1}} |
> | 2 | {{PARTNER_2}} | {{SCORE_2}} | {{STRENGTHS_2}} | {{RISK_2}} |
> | 3 | {{PARTNER_3}} | {{SCORE_3}} | {{STRENGTHS_3}} | {{RISK_3}} |
>
> Recommendation: {{TOP_RECOMMENDATION_RATIONALE}}

**Pricing recommendation:**
1. Load historical quote data for similar parts/quantities.
2. Analyze win/loss by price point.
3. Calculate the optimal price point that maximizes expected revenue (price * win probability).
4. Factor in target margin and floor price.
5. Output:

> **Pricing Recommendation for {{RFQ_ID}}:**
>
> | Price Point | Win Probability | Expected Revenue | Margin |
> |-------------|----------------|-----------------|--------|
> | {{PRICE_LOW}} | {{WIN_HIGH}}% | {{REV_LOW}} | {{MARGIN_LOW}}% |
> | {{PRICE_MID}} | {{WIN_MID}}% | {{REV_MID}} | {{MARGIN_MID}}% |
> | {{PRICE_HIGH}} | {{WIN_LOW}}% | {{REV_HIGH}} | {{MARGIN_HIGH}}% |
>
> Optimal price: **{{OPTIMAL_PRICE}}** ({{OPTIMAL_WIN}}% win probability, {{OPTIMAL_MARGIN}}% margin)

#### Mode C: Optimize

**Margin analysis:**
1. Calculate margin by customer, by partner, by process type, by part complexity.
2. Identify margin leakers: orders where actual cost exceeded quoted cost.
3. Identify margin stars: consistently high-margin customer/part combinations.
4. Output Pareto: top 20% of customers/parts driving 80% of profit.

**Process optimization:**
1. Calculate average cycle time by process type and partner.
2. Identify bottleneck stages (stages with highest variance in duration).
3. Compare partner performance on same process types.
4. Recommend process improvements.

#### Mode D: Alert (Anomaly Detection)

**Pattern anomaly detection:**
1. Calculate rolling averages for key metrics (lead time, defect rate, quote conversion).
2. Flag any current values >2 standard deviations from the rolling average.
3. Group related anomalies (e.g., rising defect rate + increasing lead time at same partner).
4. Output:

> **Anomalies Detected:**
>
> {{#EACH_ANOMALY}}
> - **{{ANOMALY_TYPE}}:** {{ANOMALY_DESCRIPTION}}
>   - Current value: {{CURRENT_VALUE}} | Average: {{AVERAGE_VALUE}} | Deviation: {{DEVIATION}}x
>   - Potential cause: {{POTENTIAL_CAUSE}}
>   - Recommended action: {{RECOMMENDED_ACTION}}
> {{/EACH_ANOMALY}}

#### Mode E: Benchmark

**KPI dashboard:**
1. Calculate all KPIs from `references/kpi-formulas.md` for the requested period.
2. Compare to previous period (month-over-month or quarter-over-quarter).
3. Flag improving and declining metrics.
4. Output a complete KPI report.

#### Mode F: Full Intel Report

Run all five modes and compile into a comprehensive report using `templates/Intel Report.md`. Generate as markdown, and offer to convert to DOCX via reva-turbo-docx.

### Step 4 — Customer Intelligence

When analyzing customer data:

**Customer Lifetime Value (CLV):**
1. Sum all revenue from the customer across all orders.
2. Subtract all costs (including COPQ for that customer's orders).
3. Calculate average order frequency and average order value.
4. Project future CLV based on historical pattern.

**Churn Risk Scoring:**
1. Calculate days since last order.
2. Compare to the customer's historical order frequency.
3. If gap > 2x their average frequency, flag as "at risk."
4. If gap > 3x, flag as "high churn risk."
5. Check for recent complaints, NCRs, or escalations.
6. Output a churn risk score (low/medium/high) with contributing factors.

**Upsell Detection:**
1. Analyze the customer's order history for part types and processes.
2. Identify Rev A capabilities the customer has not yet used.
3. Cross-reference with similar customers who expanded their order scope.
4. Output upsell opportunities with estimated revenue potential.

### Step 5 — Partner Intelligence

When analyzing partner data:

**Predictive Scoring:**
1. Load the partner's scorecard history (monthly scores).
2. Calculate the trend line (linear regression on scores over time).
3. Project where the score will be in 1 month, 3 months.
4. If projected score drops below C, flag as "declining."

**Comparative Benchmarking:**
1. For a given process type, rank all qualified partners.
2. Show side-by-side comparison on: quality, delivery, cost, communication.
3. Highlight where each partner excels and where they fall short.

### Step 6 — Quote Intelligence

When analyzing quote data:

**Win/Loss Analysis:**
1. Categorize all quotes by outcome: won, lost, expired, withdrawn.
2. Calculate conversion rate overall and by segment (customer type, part type, size).
3. Analyze lost quotes: was it price, lead time, capability, or relationship?
4. Identify patterns in wins vs. losses.

**Discount Impact Modeling:**
1. Calculate the historical relationship between discount % and win rate.
2. Model the revenue impact of different discount tiers.
3. Identify the "discount threshold" where win rate stops improving.

### Step 7 — Quality Intelligence

When analyzing quality data:

**Defect Pareto Analysis:**
1. Categorize all NCRs by defect type, partner, part type, and process.
2. Rank by frequency and by cost impact.
3. Identify the top 3-5 defect types that account for 80% of issues.
4. Track defect trends over time (improving or worsening).

**Root Cause Pattern Detection:**
1. Cross-reference NCRs with partner, process, material, and timeline data.
2. Identify correlations (e.g., "rush orders from Partner X have 3x the defect rate").
3. Output actionable root cause hypotheses.

**Cost of Poor Quality (COPQ):**
1. Sum all costs associated with NCRs: scrap, rework, return shipping, customer credits, inspection time.
2. Calculate COPQ as a percentage of revenue.
3. Track COPQ trend over time.
4. Identify the biggest COPQ contributors (by partner, by defect type).

### Step 8 — Output and Reporting

Present analysis results in the appropriate format:

- **Quick answer:** For simple questions, provide a concise response with the key number and confidence level.
- **Detailed analysis:** For deep dives, provide a structured report with sections, tables, and recommendations.
- **Full Intel Report:** Generate a complete report using `templates/Intel Report.md` and offer DOCX conversion.

Always include:
- The number of data points the analysis is based on
- Confidence level (high/medium/low) based on data quantity and quality
- Caveats and limitations
- Actionable recommendations

Log the analysis output:

```bash
echo '{"ts":"'$(date -u +%Y-%m-%dT%H:%M:%SZ)'","pm":"{{PM_NAME}}","analysis_type":"{{ANALYSIS_TYPE}}","scope":"{{SCOPE}}","data_points":{{DATA_POINTS}},"confidence":"{{CONFIDENCE}}","key_finding":"{{KEY_FINDING_SUMMARY}}"}' >> ~/.reva-turbo/analytics/intel-outputs.jsonl 2>/dev/null || true
```

**HUMAN-IN-THE-LOOP CHECKPOINT:**

After presenting findings:

> **Intel analysis complete.** Based on {{DATA_POINTS}} data points.
>
> Key finding: {{KEY_FINDING}}
>
> A) Looks right — save this analysis
> B) Dig deeper into a specific finding
> C) Run a different analysis type
> D) Generate a full Intel Report (.md or .docx)
> E) Share findings via Pulse alert to the team

## Report Naming

Save intel reports as:
```
REVA-TURBO-Intel-{YYYY-MM-DD}-{AnalysisType}-{Scope}.md
```

## Template References

- `prompts/intel-system.md` — Analytics methodology and reasoning rules
- `prompts/intel-user-template.md` — Analysis request variables
- `references/analysis-methods.md` — Statistical methods available
- `references/kpi-formulas.md` — Complete KPI calculation formulas
- `references/insight-templates.md` — Pre-built insight patterns
- `templates/Intel Report.md` — Full intelligence report template
