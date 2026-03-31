# Dashboard User Template

Use this template when interacting with the PM about dashboard views.

## Dashboard Menu

```
PMLORD DASHBOARD - {{CURRENT_DATE}}

What would you like to see?

A) Full PM Dashboard (all sections)
B) Orders Summary (active orders by stage)
C) RFQ Pipeline (open quotes + aging)
D) Quality Overview (NCRs + inspection)
E) Delivery Calendar (next 30 days)
F) Partner Scorecard Summary
G) Custom view

Current PM: {{ASSIGNED_PM}}
Filter: [All PMs / My orders only]
```

## Quick Status Response

```
PMLORD STATUS SNAPSHOT - {{TIMESTAMP}}

Active Orders: {{ACTIVE_ORDERS}}
Open RFQs: {{OPEN_RFQS}}
Open NCRs: {{OPEN_NCRS}}
Open Escalations: {{OPEN_ESCALATIONS}}
Deliveries This Week: {{DELIVERIES_THIS_WEEK}}

Red Flags: {{RED_FLAG_COUNT}}
{{RED_FLAG_SUMMARY}}

Yellow Flags: {{YELLOW_FLAG_COUNT}}
{{YELLOW_FLAG_SUMMARY}}

Want the full dashboard? [Y/N]
```

## Drill-Down Request

```
DETAIL VIEW: {{SECTION_NAME}}

{{DETAIL_TABLE}}

Back to dashboard? [Y/N]
```
