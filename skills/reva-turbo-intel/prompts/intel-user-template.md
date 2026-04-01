# Intel Analysis Request Template

Use these variables to capture the PM's analysis request. Fill from the PM's natural language input or from the structured menu selection.

## Request Variables

```
{{ANALYSIS_TYPE}}     — predict | recommend | optimize | alert | benchmark | full_report
{{SCOPE}}             — order | rfq | customer | partner | process | company_wide
{{ENTITY_ID}}         — Specific entity ID (e.g., ORD-2026-0087, RFQ-2026-0042, "Acme Corp", "Shenzhen Precision")
{{TIME_PERIOD}}       — last_30d | last_90d | last_6mo | last_year | ytd | custom (specify dates)
{{TIME_START}}        — Start date for custom period (ISO 8601)
{{TIME_END}}          — End date for custom period (ISO 8601)
{{COMPARISON}}        — vs_prior_period | vs_target | vs_benchmark | vs_entity (specify)
{{COMPARISON_ENTITY}} — Entity to compare against (e.g., "Partner A vs Partner B")
{{METRIC_FOCUS}}      — otd | quality | margin | conversion | lead_time | copq | clv | all
{{OUTPUT_FORMAT}}     — quick | detailed | report | docx
{{PM_NAME}}           — Requesting PM
```

## Example Requests Mapped to Variables

**"Will Order 87 ship on time?"**
```
ANALYSIS_TYPE: predict
SCOPE: order
ENTITY_ID: ORD-2026-0087
METRIC_FOCUS: otd
OUTPUT_FORMAT: quick
```

**"Which partner should I use for this CNC job?"**
```
ANALYSIS_TYPE: recommend
SCOPE: partner
METRIC_FOCUS: all
OUTPUT_FORMAT: detailed
```

**"How are we doing vs. last quarter?"**
```
ANALYSIS_TYPE: benchmark
SCOPE: company_wide
TIME_PERIOD: last_90d
COMPARISON: vs_prior_period
METRIC_FOCUS: all
OUTPUT_FORMAT: detailed
```

**"Why do we keep getting NCRs from Partner X?"**
```
ANALYSIS_TYPE: alert
SCOPE: partner
ENTITY_ID: Partner X
METRIC_FOCUS: quality
OUTPUT_FORMAT: detailed
```

**"What's our best price for this quote?"**
```
ANALYSIS_TYPE: recommend
SCOPE: rfq
ENTITY_ID: RFQ-2026-0042
METRIC_FOCUS: conversion
OUTPUT_FORMAT: detailed
```

**"Full quarterly intelligence report"**
```
ANALYSIS_TYPE: full_report
SCOPE: company_wide
TIME_PERIOD: last_90d
COMPARISON: vs_prior_period
METRIC_FOCUS: all
OUTPUT_FORMAT: report
```
