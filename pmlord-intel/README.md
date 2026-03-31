# pmlord-intel

Predictive analytics and business intelligence for the PMLORD engine.

## What It Does

Reads all PMLORD historical data (JSONL logs, scorecards, audit trails, inspection records, NCRs) and generates forward-looking intelligence. Five analysis modes turn raw data into actionable advice.

1. **Predict** — Delivery probability, quote win probability, risk scoring
2. **Recommend** — Partner selection, optimal pricing, resource allocation
3. **Optimize** — Margin analysis, process bottleneck identification, cost reduction
4. **Alert** — Anomaly detection, pattern recognition, early warning signals
5. **Benchmark** — KPI trends, period-over-period comparison, team performance

Plus deep intelligence modules for customers (CLV, churn risk, upsell), partners (predictive scoring, comparative benchmarks), quotes (win/loss analysis, discount modeling), and quality (defect Pareto, root cause patterns, COPQ).

## Usage

```
/pmlord-intel
```

Or ask any analytical question and the PMLORD engine routes to Intel.

## Inputs

- Analysis type and scope
- Time period for comparison
- Entity filter (specific customer, partner, or order)

## Outputs

- Analysis results presented inline with confidence levels
- Intel reports saved to `~/.pmlord/analytics/intel-outputs.jsonl`
- Full Intel Report as markdown (convertible to DOCX)

## Files

| File | Purpose |
|------|---------|
| `SKILL.md` | Skill instructions and flow |
| `skill.yaml` | Skill manifest |
| `prompts/intel-system.md` | Analytics methodology and reasoning rules |
| `prompts/intel-user-template.md` | Analysis request variables |
| `references/analysis-methods.md` | Statistical methods available |
| `references/kpi-formulas.md` | Complete KPI calculation formulas |
| `references/insight-templates.md` | Pre-built insight patterns |
| `templates/Intel Report.md` | Full intelligence report template |

## Data Requirements

Intel works with whatever data is available. More historical data yields higher-confidence predictions. The skill explicitly notes when data is sparse and adjusts confidence levels accordingly.
