# Reporting User Template

Use this template when interacting with the PM about report generation.

## Report Selection

```
PMLORD REPORT GENERATOR

Which report do you need?

A) Weekly PM Summary (for week ending {{SUGGESTED_FRIDAY}})
B) Monthly Performance (for {{CURRENT_MONTH}})
C) Quarterly Business Review (for {{CURRENT_QUARTER}})
D) Customer-Specific Report
E) Ad-hoc / custom report

Select: [A/B/C/D/E]
```

## Report Parameters

```
REPORT PARAMETERS

Report Type: {{REPORT_TYPE}}
Period: {{REPORT_PERIOD}}
PM Filter: {{PM_FILTER}} [All / Ray Yeh / Harley Scott]
Output Format: {{OUTPUT_FORMAT}} [Markdown / Markdown + DOCX]

Confirm and generate? [Y/N]
```

## Report Preview

```
REPORT PREVIEW: {{REPORT_TYPE}} - {{REPORT_PERIOD}}

Executive Summary:
- {{SUMMARY_1}}
- {{SUMMARY_2}}
- {{SUMMARY_3}}

[Full report follows...]

A) Approve and save
B) Review/edit before saving
C) Regenerate with changes
D) Convert to .docx
```
