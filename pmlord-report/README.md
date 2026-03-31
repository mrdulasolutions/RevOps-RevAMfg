# pmlord-report

Periodic reporting skill for the PMLORD engine.

## What It Does

Generates standardized reports for Rev A Manufacturing:

1. **Weekly PM Summary** — Friday cadence, covers the week's orders, RFQs, deliveries, and issues
2. **Monthly Performance** — Monthly KPI review with trends and partner performance
3. **Quarterly Business Review** — Strategic review with financial summary and forecasting
4. **Customer Report** — Customer-specific order history, quality metrics, and relationship summary

## Usage

```
/pmlord-report
```

Or ask PMLORD to generate a specific report type.

## Files

| File | Purpose |
|------|---------|
| `SKILL.md` | Skill instructions and flow |
| `skill.yaml` | Skill manifest |
| `prompts/reporting-system.md` | System prompt for reporting |
| `prompts/reporting-user-template.md` | User interaction template |
| `references/report-types.md` | Report definitions and data requirements |
| `templates/Weekly PM Summary.md` | Weekly summary template |
| `templates/Monthly Performance.md` | Monthly performance template |
| `templates/Quarterly Review.md` | Quarterly review template |
| `templates/Customer Report.md` | Customer report template |

## Output

Reports are saved to `~/.pmlord/reports/{YEAR}/` and can be converted to .docx using pmlord-docx.
