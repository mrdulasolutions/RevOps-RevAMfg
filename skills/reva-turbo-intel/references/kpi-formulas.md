# Intel KPI Formulas

Complete calculation definitions for all REVA-TURBO key performance indicators.

## Sales and Quoting KPIs

### Quote-to-Win Rate
```
Quote-to-Win Rate = (Won Quotes / Total Quotes Sent) * 100

Segments: by customer, by part type, by process, by PM, by quarter
Target: >35% (industry benchmark for custom manufacturing)
```

### Quote Response Time
```
Quote Response Time = Mean(quote_sent_date - rfq_received_date) in business days

Segments: by complexity tier, by PM
Target: <3 business days for standard, <5 for complex
```

### Average Quote Value
```
Average Quote Value = Sum(quote_amounts) / Count(quotes)

Segments: by customer, by process type, by quarter
Track: trend over time to detect shifts in order mix
```

### RFQ-to-PO Conversion Time
```
Conversion Time = Mean(po_received_date - quote_sent_date) in business days

Segments: by customer, by quote value tier
Track: lengthening conversion times may indicate pricing or competitive issues
```

## Delivery KPIs

### On-Time Delivery Rate (OTD)
```
OTD Rate = (Orders Delivered On or Before Committed Date / Total Orders Delivered) * 100

"On time" = actual_delivery_date <= committed_delivery_date
Segments: by partner, by process type, by customer, by order size
Target: >95%
```

### Average Lead Time
```
Average Lead Time = Mean(delivery_date - po_date) in calendar days

Segments: by process type, by partner, by part complexity
Track: moving average to detect drift
```

### Lead Time Variance
```
Lead Time Variance = StdDev(delivery_date - po_date) by process type

Lower variance = more predictable delivery
High variance = unreliable lead time estimates given to customers
```

### Partner Velocity
```
Partner Velocity = Mean(actual_milestone_days / planned_milestone_days)

Velocity = 1.0: partner delivers exactly on schedule
Velocity < 1.0: partner delivers ahead of schedule
Velocity > 1.0: partner delivers behind schedule

Segments: by partner, by process type
```

## Quality KPIs

### First Pass Yield (FPY)
```
First Pass Yield = (Orders Passing Inspection First Time / Total Orders Inspected) * 100

"First time" = no NCR issued during initial inspection
Segments: by partner, by process type, by inspector
Target: >95%
```

### NCR Rate
```
NCR Rate = (NCRs Issued / Total Orders Received) * 100

Segments: by partner, by process type, by defect type
Target: <5%
```

### Cost of Poor Quality (COPQ)
```
COPQ = Sum(Scrap Cost + Rework Cost + Return Shipping + Customer Credits + Warranty Claims + Inspection Rework Time * Hourly Rate + NCR Resolution Administrative Cost)

COPQ % = (COPQ / Total Revenue) * 100

Segments: by partner, by defect type, by process type
Target: <2% of revenue
```

### Defect Density
```
Defect Density = Number of Defects Found / Number of Units Inspected

Use for volumetric comparison across different lot sizes
```

### Recurring Defect Rate
```
Recurring Defect Rate = (NCRs with Same Root Cause as a Previous NCR / Total NCRs) * 100

High rate indicates corrective actions are not effective
Target: <10%
```

## Financial KPIs

### Customer Lifetime Value (CLV)
```
CLV = Sum(All Revenue from Customer) - Sum(All Costs for Customer's Orders)

Projected CLV = Historical CLV + (Avg Order Value * Predicted Future Orders)
Predicted Future Orders = Historical Order Frequency * Estimated Remaining Relationship Years

Segments: by customer, by customer tier
```

### Gross Margin by Order
```
Gross Margin = ((Revenue - COGS) / Revenue) * 100

COGS = Partner Cost + Shipping In + Inspection Cost + Repackaging Cost + Shipping Out

Segments: by customer, by partner, by process type
Target: >25%
```

### Revenue per PM
```
Revenue per PM = Total Revenue / Number of Active PMs

Track: monthly trend to assess team productivity
```

### Days Sales Outstanding (DSO)
```
DSO = (Accounts Receivable / Total Credit Sales) * Number of Days in Period

Or simplified: Mean(payment_received_date - invoice_date)

Target: <30 days (per Rev A payment terms)
```

## Operational KPIs

### PM Utilization
```
PM Utilization = Active Orders per PM / Max Capacity per PM

Max Capacity: configurable, default 15 orders per PM
Warning threshold: >80% utilization
Critical threshold: >100% utilization
```

### Cycle Time by Stage
```
Stage Cycle Time = Mean(stage_exit_date - stage_entry_date) per lifecycle stage

Stages: intake, qualify, quote, customer-response, manufacturing, transit, inspection, quality-gate, repackage, logistics, delivery
Track: identify bottleneck stages (highest absolute time or highest variance)
```

### Autopilot Adoption Rate
```
Autopilot Adoption = (Entities with Autopilot Enabled / Total Active Entities) * 100

Track: by mode (full auto, semi auto, manual)
Track: auto-transition success rate
```

### Time Saved by Autopilot
```
Autopilot Time Saved = Count(Auto-Transitions) * Estimated Manual Transition Time

Estimated Manual Transition Time: 5 minutes per routine transition (configurable)
```

## Customer KPIs

### Customer Retention Rate
```
Retention Rate = ((Customers at End of Period - New Customers During Period) / Customers at Start of Period) * 100

Period: typically quarterly or annually
Target: >85%
```

### Customer Churn Risk Score
```
Churn Risk = weighted score of:
  - Days since last order vs. historical frequency (40%)
  - Recent complaints or NCRs (25%)
  - Declining order values (20%)
  - Quote rejections (15%)

Score: LOW (0-30), MEDIUM (31-60), HIGH (61-100)
```

### Net Promoter Score (Proxy)
```
NPS Proxy = (Customers who reordered within 6 months / Total customers with completed orders) * 100

Not a true NPS but a behavioral proxy for customer satisfaction
```

## Partner KPIs

### Partner Quality Index
```
PQI = Weighted average of:
  - First pass yield (40%)
  - NCR severity distribution (30%)
  - Corrective action effectiveness (20%)
  - Documentation completeness (10%)

Scale: 0-100
Grade: A (90-100), B (80-89), C (70-79), D (60-69), F (<60)
```

### Partner Delivery Index
```
PDI = Weighted average of:
  - On-time delivery rate (50%)
  - Lead time consistency (30%)
  - Milestone reporting timeliness (20%)

Scale: 0-100
```

### Partner Cost Index
```
PCI = Weighted average of:
  - Price competitiveness vs. alternatives (50%)
  - Hidden cost frequency (rework, returns) (30%)
  - Payment term compliance (20%)

Scale: 0-100
```

## Calculation Notes

1. All rate calculations exclude cancelled or withdrawn orders/quotes unless specifically analyzing cancellation rates.
2. Time calculations use calendar days unless specified as "business days" (which exclude Saturdays and Sundays).
3. Financial calculations use the order currency. Multi-currency conversions use the exchange rate at the time of the transaction.
4. Moving averages use a 90-day window by default.
5. Year-over-year comparisons align by calendar month (not by day count).
