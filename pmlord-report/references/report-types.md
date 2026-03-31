# Report Types Reference

## 1. Weekly PM Summary

**Cadence:** Every Friday
**Audience:** PMs, Senior PM
**Period:** Monday through Friday of the current week

### Data Requirements

| Section | Data Source | Metrics |
|---------|-----------|---------|
| Orders Activity | workflow-state.jsonl | New POs received, stages advanced, orders closed |
| RFQ Activity | workflow-state.jsonl | New RFQs received, quotes sent, quotes won/lost |
| Deliveries | shipment-log.jsonl | Deliveries completed, on-time vs late |
| Quality | ncr-log.jsonl | NCRs opened, NCRs closed, inspections completed |
| Escalations | escalation-log.jsonl | New escalations, resolved escalations |
| Partner Updates | partner-scores.jsonl | Score changes, notable partner events |
| Next Week Preview | Various | Expected deliveries, milestones, follow-ups due |

### Template: `templates/Weekly PM Summary.md`

## 2. Monthly Performance Report

**Cadence:** 1st business day of each month
**Audience:** PMs, Leadership (Donovan Weber)
**Period:** Full prior calendar month

### Data Requirements

| Section | Data Source | Metrics |
|---------|-----------|---------|
| Financial Summary | financial-log.jsonl | Revenue booked, revenue in pipeline, avg order value |
| KPI Dashboard | All state files | All 10 KPIs with month-over-month trend |
| Order Volume | workflow-state.jsonl | Orders opened, closed, cancelled; by customer and partner |
| Quality Analysis | ncr-log.jsonl | NCR count, root causes, corrective actions |
| Partner Scorecard | partner-scores.jsonl | Full scorecard for each active partner |
| Customer Analysis | Various | Top customers by volume and revenue |
| Operational Issues | escalation-log.jsonl | Escalation summary, resolution time |
| Recommendations | N/A | PM-driven recommendations for next month |

### Template: `templates/Monthly Performance.md`

## 3. Quarterly Business Review

**Cadence:** 1st week of each quarter (Jan, Apr, Jul, Oct)
**Audience:** Leadership, Board, Key Partners
**Period:** Full prior quarter (3 months)

### Data Requirements

| Section | Data Source | Metrics |
|---------|-----------|---------|
| Executive Summary | All | Quarter highlights, challenges, outlook |
| Financial Performance | financial-log.jsonl | Revenue, margins, quarter-over-quarter growth |
| KPI Trends | All state files | All KPIs with 4-quarter trend |
| Market Analysis | CRM data | New customers, lost customers, market segments |
| Partner Review | partner-scores.jsonl | Partner performance summary, changes |
| Quality Trend | ncr-log.jsonl | Quality rate trend, systemic issues |
| Capacity Analysis | ERP/operational data | Utilization, bottlenecks, growth capacity |
| Strategic Initiatives | N/A | Progress on strategic goals |
| Next Quarter Plan | N/A | Goals, targets, planned initiatives |

### Template: `templates/Quarterly Review.md`

## 4. Customer-Specific Report

**Cadence:** On demand
**Audience:** Customer, PM, Leadership
**Period:** As specified (typically last 12 months)

### Data Requirements

| Section | Data Source | Metrics |
|---------|-----------|---------|
| Customer Profile | CRM data | Company info, contacts, relationship history |
| Order History | workflow-state.jsonl | All orders with status, dates, values |
| Quality Record | ncr-log.jsonl | NCRs related to this customer's orders |
| Delivery Performance | shipment-log.jsonl | On-time delivery rate for this customer |
| Communication Log | audit-trail.jsonl | Key interactions and decisions |
| Account Summary | financial-log.jsonl | Total revenue, outstanding invoices |
| Recommendations | N/A | Relationship strengthening recommendations |

### Template: `templates/Customer Report.md`
