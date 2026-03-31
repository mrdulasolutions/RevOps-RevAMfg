# pmlord-dashboard

PM workload dashboard skill for the PMLORD engine.

## What It Does

Generates a comprehensive dashboard view for project managers and leadership at Rev A Manufacturing:

1. Aggregates data from all PMLORD state files
2. Calculates KPIs (on-time delivery, quality rate, conversion rate, etc.)
3. Displays orders by stage, RFQ pipeline, quality issues, and partner performance
4. Highlights red and yellow flags requiring attention
5. Saves dashboard snapshots for trend tracking

## Usage

```
/pmlord-dashboard
```

Or ask PMLORD for a status overview, workload summary, or specific dashboard section.

## Dashboard Sections

- Orders by Stage (12-stage pipeline view)
- RFQ Pipeline (open quotes, aging, value)
- Quality Overview (NCRs, inspection results)
- Delivery Calendar (upcoming 30 days)
- Partner Scorecard Summary
- PM Workload Distribution
- Open Escalations
- Revenue in Pipeline

## Files

| File | Purpose |
|------|---------|
| `SKILL.md` | Skill instructions and flow |
| `skill.yaml` | Skill manifest |
| `prompts/dashboard-system.md` | System prompt for dashboard logic |
| `prompts/dashboard-user-template.md` | User interaction template |
| `references/kpi-definitions.md` | KPI calculation methods |
| `references/dashboard-layout.md` | Dashboard section layout |
| `templates/PM Dashboard.md` | Dashboard output template |
