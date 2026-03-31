---
name: pmlord-dashboard
preamble-tier: 2
version: 1.0.0
description: |
  PM dashboard showing real-time workload overview: open RFQs, active orders,
  quality issues, upcoming deliveries, partner performance scores, and
  capacity utilization. Aggregates data from all PMLORD state files.
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
echo '{"skill":"pmlord-dashboard","ts":"'$(date -u +%Y-%m-%dT%H:%M:%SZ)'"}' >> ~/.pmlord/analytics/skill-usage.jsonl 2>/dev/null || true
```

## Purpose

Provide PMs (Ray Yeh, Harley Scott) and leadership (Donovan Weber) with a real-time workload dashboard. Aggregates data from all PMLORD state files to show a comprehensive view of open RFQs, active orders, quality issues, upcoming deliveries, partner performance, and capacity.

## Flow

### Step 1: Dashboard Request

Determine what the PM wants to see:

> What dashboard view do you need?
> A) Full PM Dashboard (all sections)
> B) Orders Summary (active orders + stages)
> C) RFQ Pipeline (open quotes + aging)
> D) Quality Overview (NCRs + inspection results)
> E) Delivery Calendar (upcoming 30 days)
> F) Partner Scorecard Summary
> G) Custom view (specify sections)

### Step 2: Data Aggregation

Gather data from PMLORD state files:

```bash
# Count active orders by stage
cat ~/.pmlord/state/workflow-state.jsonl 2>/dev/null | grep '"status":"active"' | tail -100

# Count open RFQs
cat ~/.pmlord/state/workflow-state.jsonl 2>/dev/null | grep '"stage":"pmlord-rfq' | grep -v '"status":"closed"' | tail -50

# Get quality issues
cat ~/.pmlord/state/ncr-log.jsonl 2>/dev/null | grep '"status":"open"' | tail -20

# Get upcoming deliveries
cat ~/.pmlord/shipments/shipment-log.jsonl 2>/dev/null | tail -30

# Get partner scores
cat ~/.pmlord/state/partner-scores.jsonl 2>/dev/null | tail -20

# Get escalations
cat ~/.pmlord/state/escalation-log.jsonl 2>/dev/null | grep '"status":"open"' | tail -10
```

### Step 3: KPI Calculation

Reference `references/kpi-definitions.md` for calculation methods. Compute:

1. **Orders by Stage** — Count of active orders at each of the 12 stages
2. **RFQ Pipeline Value** — Total quoted value of open RFQs
3. **RFQ Conversion Rate** — Won quotes / Total quotes (trailing 90 days)
4. **On-Time Delivery Rate** — Orders delivered on or before promised date (trailing 90 days)
5. **Quality Rate** — Orders with zero NCRs / Total orders (trailing 90 days)
6. **Average Lead Time** — PO received to customer delivery (trailing 90 days)
7. **Open Escalations** — Count of unresolved escalations
8. **Partner Performance** — Average scorecard rating across active partners
9. **PM Workload** — Active orders per PM
10. **Revenue in Pipeline** — Total value of active orders

### Step 4: Dashboard Generation

Reference `references/dashboard-layout.md` for the section layout. Use `templates/PM Dashboard.md` to generate the formatted dashboard.

### Step 5: Alerts and Flags

Highlight items requiring immediate attention:

- **Red flags:** Delays > 2 weeks, NCRs open > 5 days, partner score drop below C
- **Yellow flags:** Delays 1-2 weeks, RFQ aging > 5 days without response, delivery approaching within 3 days
- **Action items:** Reminders due today, follow-ups needed

### Step 6: Save Dashboard

```bash
mkdir -p ~/.pmlord/dashboards
echo '{"ts":"'$(date -u +%Y-%m-%dT%H:%M:%SZ)'","type":"pm-dashboard","pm":"{{ASSIGNED_PM}}","active_orders":{{ACTIVE_ORDERS}},"open_rfqs":{{OPEN_RFQS}},"open_ncrs":{{OPEN_NCRS}},"open_escalations":{{OPEN_ESCALATIONS}}}' >> ~/.pmlord/dashboards/dashboard-log.jsonl
```

## Report Naming

Save dashboard snapshots as:
```
PMLORD-Dashboard-{YYYY-MM-DD}-{PM_INITIALS}.md
```

## Template References

- `prompts/dashboard-system.md` — System prompt for dashboard generation
- `prompts/dashboard-user-template.md` — User interaction template
- `references/kpi-definitions.md` — KPI calculation methods
- `references/dashboard-layout.md` — Dashboard section layout
- `templates/PM Dashboard.md` — Dashboard output template
