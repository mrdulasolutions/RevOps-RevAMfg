# reva-turbo-rfq-quote

Quote generation skill for the REVA-TURBO engine.

## What It Does

Generates complete, customer-facing quote packages for Rev A Manufacturing:

1. Gathers cost inputs (material, manufacturing, finishing, assembly, quality)
2. Calculates cost buildup and COGS
3. Applies margin based on part type, volume, and customer relationship
4. Estimates total lead time from order to delivery
5. Calculates shipping costs (ocean vs air)
6. Presents quote summary for PM approval
7. Generates a professional quote document

## Usage

```
/reva-turbo-rfq-quote
```

Typically runs after `reva-turbo-rfq-qualify` produces a PROCEED or CONDITIONAL decision.

## Inputs

- Qualified RFQ data (from `reva-turbo-rfq-qualify`)
- China partner pricing (PM input)
- Tooling quotes (PM input, if applicable)
- Shipping preference (ocean/air)

## Outputs

- Quote package saved to `~/.reva-turbo/rfqs/{RFQ_ID}/quote-package.md`
- Workflow state logged to `~/.reva-turbo/state/workflow-state.jsonl`

## Files

| File | Purpose |
|------|---------|
| `SKILL.md` | Skill instructions and flow |
| `skill.yaml` | Skill manifest |
| `prompts/quoting-system.md` | System prompt for quoting logic |
| `prompts/quoting-user-template.md` | Quoting input variables |
| `references/cost-estimation.md` | Cost estimation framework |
| `references/margin-guidelines.md` | Margin targets and rules |
| `references/tooling-costs.md` | Tooling cost reference |
| `references/lead-time-matrix.md` | Lead time estimates |
| `references/shipping-estimates.md` | Shipping cost and time estimates |
| `templates/Quote Package.md` | Customer-facing quote template |

## Next Step

After the quote is generated, the skill suggests running `reva-turbo-customer-comms` to draft a quote submission email.
