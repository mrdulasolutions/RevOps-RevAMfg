# reva-turbo-profit

Profitability analysis skill for the REVA-TURBO engine.

## What It Does

Tracks real profitability for Rev A Manufacturing orders by comparing actual costs against original estimates:

1. Pulls estimated cost breakdown from original quote
2. Collects actual costs from invoices, NCRs, and internal records
3. Calculates variance for every cost category with flag thresholds
4. Computes per-order gross profit and margin
5. Builds customer lifetime profitability metrics and trends
6. Identifies systematic estimation errors across orders
7. Generates actionable recommendations for margin improvement
8. Feeds back into quoting guidelines when patterns emerge

## Usage

```
/reva-turbo-profit
```

Runs after an order is delivered and all invoices are received. Can also run mid-order for preliminary analysis.

## Inputs

- Delivered order ID, customer name, or quote number
- Actual costs from supplier invoices, partner invoices, and internal records
- Historical order data (for lifetime and trend analysis)

## Outputs

- Profitability Report saved to `~/.reva-turbo/profit-analysis/{Customer}/`
- Margin Alert (when margin drops below threshold)
- Profit analysis logged to `~/.reva-turbo/state/workflow-state.jsonl`
- Recommended updates to quoting guidelines (when systematic issues detected)

## Files

| File | Purpose |
|------|---------|
| `SKILL.md` | Skill instructions and flow |
| `skill.yaml` | Skill manifest |
| `prompts/profit-system.md` | Cost accounting methodology and analysis rules |
| `prompts/profit-user-template.md` | Variables for cost entry |
| `references/cost-categories.md` | Complete cost category definitions |
| `references/variance-thresholds.md` | Variance flag thresholds and actions |
| `references/profitability-benchmarks.md` | Target benchmarks by process, tier, partner |
| `templates/Profitability Report.md` | Full profitability report template |
| `templates/Margin Alert.md` | Quick margin alert template |

## Next Step

After analysis, the skill may suggest updating `reva-turbo-rfq-quote` margin guidelines if systematic quoting errors are detected.
