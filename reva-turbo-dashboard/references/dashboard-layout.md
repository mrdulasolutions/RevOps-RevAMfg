# Dashboard Layout Reference

## Full PM Dashboard Layout

The full dashboard is organized into these sections, presented in this order:

### Section 1: Header & Alerts

- Dashboard title with date/time stamp
- PM name (or "All PMs" for leadership view)
- Data freshness indicator
- Red flags (critical items requiring immediate action)
- Yellow flags (items requiring attention soon)

### Section 2: Orders Pipeline

A visual pipeline showing order counts at each stage:

```
01-PO Recv | 02-PO Ack | 03-Specs | 04-Mfg | 05-Done | 06-Ship CN | 07-Rev A | 08-Insp | 09-Rpkg | 10-Ship | 11-Dlvr | 12-Close
    X     |     X     |    X     |   X    |    X    |     X      |    X     |    X    |    X    |    X    |    X    |    X
```

Plus total active orders and total value.

### Section 3: RFQ Pipeline

| Column | Description |
|--------|-------------|
| RFQ ID | Unique identifier |
| Customer | Company name |
| Received | Date received |
| Age (days) | Business days since receipt |
| Stage | Intake / Qualify / Quote / Sent |
| Est. Value | Estimated order value |
| PM | Assigned PM |
| Status | Active / Waiting / Expired |

Summary: Total open RFQs, Total pipeline value, Average age, Conversion rate (90-day)

### Section 4: Upcoming Deliveries

| Column | Description |
|--------|-------------|
| PO Number | Order reference |
| Customer | Company name |
| Delivery Date | Promised date |
| Days Until | Calendar days remaining |
| Current Stage | Where the order is now |
| On Track | Yes / At Risk / Delayed |

Show next 30 days, sorted by delivery date.

### Section 5: Quality Summary

| Metric | Value |
|--------|-------|
| Quality Rate (90-day) | XX% |
| Open NCRs | X |
| NCRs This Month | X |
| Inspections Pending | X |

List any open NCRs with PO, customer, issue summary, and days open.

### Section 6: Partner Performance

| Column | Description |
|--------|-------------|
| Partner | Company name |
| Score | Letter grade |
| Quality | Quality sub-score |
| On-Time | Delivery sub-score |
| Active Orders | Current order count |
| Trend | Up / Stable / Down |

### Section 7: PM Workload

| PM | Active Orders | Open RFQs | Open NCRs | Open Escalations |
|----|--------------|-----------|-----------|-----------------|
| Ray Yeh | X | X | X | X |
| Harley Scott | X | X | X | X |

### Section 8: KPI Summary

Display all KPIs from kpi-definitions.md with current value, target, and status indicator.

### Section 9: Action Items

List all items requiring PM action today:
- Follow-ups due
- Reminders triggered
- Approvals pending
- Escalations needing response

## Compact Dashboard (Quick View)

For quick status checks, show only:
- Active orders count
- Open RFQs count
- Red/yellow flag counts with one-line summaries
- Deliveries this week
- Top action item

## Leadership Dashboard (Donovan Weber View)

Same as Full PM Dashboard but:
- Shows both PMs combined
- Emphasizes financial metrics (revenue pipeline, conversion rate)
- Includes partner performance trends
- Shows month-over-month KPI comparison
