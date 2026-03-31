---
name: pmlord-report
preamble-tier: 2
version: 1.0.0
description: |
  Generate periodic PM reports: Weekly PM Summary, Monthly Performance,
  Quarterly Review, and Customer-specific reports. Aggregates data from
  PMLORD state files and formats using standardized templates.
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
mkdir -p ~/.pmlord/analytics
echo '{"skill":"pmlord-report","ts":"'$(date -u +%Y-%m-%dT%H:%M:%SZ)'"}' >> ~/.pmlord/analytics/skill-usage.jsonl 2>/dev/null || true
```

## Purpose

Generate standardized periodic reports for Rev A Manufacturing. Each report type has a defined cadence, audience, content structure, and template. Reports aggregate data from all PMLORD state files and present actionable insights.

## Flow

### Step 1: Report Selection

> What report do you need?
> A) Weekly PM Summary (Friday cadence)
> B) Monthly Performance Report
> C) Quarterly Business Review
> D) Customer-Specific Report
> E) Ad-hoc custom report

### Step 2: Report Parameters

Collect parameters based on report type:

**Weekly PM Summary:**
- Week ending date: {{WEEK_ENDING}}
- PM: {{PM_NAME}} (or "All")

**Monthly Performance:**
- Month: {{REPORT_MONTH}}
- Year: {{REPORT_YEAR}}

**Quarterly Review:**
- Quarter: {{QUARTER}} (Q1/Q2/Q3/Q4)
- Year: {{REPORT_YEAR}}

**Customer Report:**
- Customer: {{CUSTOMER_COMPANY}}
- Period: {{REPORT_PERIOD}}

### Step 3: Data Collection

Reference `references/report-types.md` for data requirements per report type. Aggregate from state files:

```bash
# Collect order data for the reporting period
cat ~/.pmlord/state/workflow-state.jsonl 2>/dev/null | tail -500

# Collect quality data
cat ~/.pmlord/state/ncr-log.jsonl 2>/dev/null | tail -200

# Collect partner data
cat ~/.pmlord/state/partner-scores.jsonl 2>/dev/null | tail -100

# Collect shipping data
cat ~/.pmlord/shipments/shipment-log.jsonl 2>/dev/null | tail -200

# Collect escalation data
cat ~/.pmlord/state/escalation-log.jsonl 2>/dev/null | tail -100

# Collect financial data
cat ~/.pmlord/state/financial-log.jsonl 2>/dev/null | tail -200
```

### Step 4: Report Generation

Use the appropriate template from `templates/`:
- `templates/Weekly PM Summary.md`
- `templates/Monthly Performance.md`
- `templates/Quarterly Review.md`
- `templates/Customer Report.md`

Fill all `{{PLACEHOLDER}}` variables with calculated data.

### Step 5: Review and Finalize

**HUMAN-IN-THE-LOOP CHECKPOINT:**

> Report generated: **{{REPORT_TYPE}}** for {{REPORT_PERIOD}}
>
> Key highlights:
> - {{HIGHLIGHT_1}}
> - {{HIGHLIGHT_2}}
> - {{HIGHLIGHT_3}}
>
> A) Approve and save
> B) I want to review/edit before saving
> C) Regenerate with different parameters

### Step 6: Save and Distribute

Save the report:

```bash
mkdir -p ~/.pmlord/reports/{{REPORT_YEAR}}
```

Log report generation:

```bash
echo '{"ts":"'$(date -u +%Y-%m-%dT%H:%M:%SZ)'","type":"{{REPORT_TYPE}}","period":"{{REPORT_PERIOD}}","pm":"{{PM_NAME}}","file":"{{REPORT_FILENAME}}"}' >> ~/.pmlord/state/report-log.jsonl
```

Optionally convert to .docx using pmlord-docx.

## Report Naming

```
PMLORD-WeeklySummary-{YYYY-MM-DD}-{PM_INITIALS}.md
PMLORD-MonthlyPerf-{YYYY-MM}-RevA.md
PMLORD-QuarterlyReview-{YYYY}-Q{N}-RevA.md
PMLORD-CustomerReport-{YYYY-MM-DD}-{CustomerShortName}.md
```

## Template References

- `prompts/reporting-system.md` — System prompt for report generation
- `prompts/reporting-user-template.md` — User interaction template
- `references/report-types.md` — Report type definitions and data requirements
- `templates/Weekly PM Summary.md` — Weekly summary template
- `templates/Monthly Performance.md` — Monthly performance template
- `templates/Quarterly Review.md` — Quarterly review template
- `templates/Customer Report.md` — Customer-specific report template
