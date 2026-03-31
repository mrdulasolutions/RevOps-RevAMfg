# PM Workload Model

How to measure, balance, and manage PM workload at Rev A Manufacturing.

## Weighting System

Not all items require equal PM effort. This model assigns weights based on the actual effort each item type demands.

### Item Weights

| Item Type | Weight | Rationale |
|-----------|--------|-----------|
| Simple order (complexity 1-3) | 1.0 | Standard workflow, minimal PM intervention |
| Complex order (complexity 4-5) | 2.0 | Multiple operations, tight tolerances, more coordination |
| New customer order | 1.5 | Extra onboarding work: setup, credit check, relationship building |
| Order with active NCR | 1.5 | Active quality resolution requires significant PM time |
| Order with active change order | 1.3 | Change management adds coordination overhead |
| Order in shipping/customs | 0.5 | Mostly waiting; PM monitors but limited active work |
| Order in final inspection | 0.8 | Some PM involvement for disposition and customer communication |
| RFQ in progress (not yet quoted) | 0.5 | Gathering information, coordinating partner quotes |
| RFQ quoted, awaiting customer response | 0.3 | Waiting mode; occasional follow-up |
| Repeat order from existing customer | 0.7 | Less effort than new; established processes and relationships |

### Complexity Multiplier

When an order has multiple simultaneous modifiers, use the highest applicable weight, not cumulative. Exception: NCR weight is always additive (an NCR on a complex order = 2.0 + 0.5 = 2.5, not max of 2.0).

### Customer Relationship Overhead

Some customers require more PM attention regardless of order complexity:

| Customer Type | Additional Weight |
|--------------|------------------|
| High-maintenance (frequent calls, detailed reporting requirements) | +0.5 per order |
| Strategic account (CEO involvement, special handling) | +0.3 per order |
| New customer (first 3 orders) | +0.5 per order (included in "new customer" weight) |

## Capacity Thresholds

### Recommended Operating Range

| Load Level | Weighted Units | Status | Action |
|-----------|---------------|--------|--------|
| Light | 0-8 | Available for new work | Can take on transfers, complex new orders |
| Normal | 8-15 | Optimal operating range | Standard workload, can absorb some new work |
| Heavy | 15-20 | Approaching overload | Avoid adding new work; consider redistributing |
| Overload | 20+ | Unsustainable | Redistribute immediately; risk of balls being dropped |

### Maximum Recommended Load: 15 Weighted Units

This is the target ceiling for sustained operations. PMs can temporarily exceed 15 (up to 20) during peak periods, but sustained loads above 15 lead to:
- Delayed customer responses
- Missed follow-ups
- Reduced quality of attention per order
- PM burnout

### Overload Threshold: 20 Weighted Units

At 20+ weighted units, redistribution is mandatory. The PM cannot effectively manage this many concurrent items. Trigger the workload rebalancing flow.

## Imbalance Detection

### Ratio Check

Calculate the ratio between the highest-loaded and lowest-loaded PM:

```
Imbalance Ratio = Highest PM Load / Lowest PM Load
```

| Ratio | Status | Action |
|-------|--------|--------|
| <1.5 | Balanced | No action needed |
| 1.5-2.0 | Slightly imbalanced | Note; consider in next assignment |
| 2.0-3.0 | Imbalanced | Suggest redistribution |
| >3.0 | Severely imbalanced | Mandate redistribution |

### Spike Detection

If a PM's load increases by more than 5 weighted units in a single week (from new orders, transfers, or NCRs), generate a spike alert. Sudden load increases are harder to manage than gradual ones.

## Redistribution Guidelines

When rebalancing is needed, follow these rules for selecting which items to move:

### Prefer to Move (good candidates)

1. Orders in early stages (RFQ, quoting, early manufacturing) -- less context to transfer
2. Orders for customers the receiving PM already handles -- existing relationship
3. Simple orders (complexity 1-2) -- easier to pick up with minimal briefing
4. Orders not expected to require decisions during the redistribution period
5. Repeat orders -- established processes, less learning curve

### Avoid Moving (poor candidates)

1. Orders with active NCRs -- too much context and sensitivity to transfer
2. Orders in final stages (inspection, delivery) -- near completion, disruption not worth it
3. Orders with active customer escalations -- changing PM mid-escalation undermines confidence
4. Orders in the middle of complex negotiations -- PM relationship and context are critical
5. First orders from new customers -- the relationship is being established

### Transfer Effort Estimate

Each transfer itself consumes PM time:

| Transfer Type | Effort Cost (equivalent weighted units, one-time) |
|--------------|--------------------------------------------------|
| Simple order transfer | 0.3 |
| Complex order transfer | 0.8 |
| Full customer transfer (all orders) | 1.5 |
| Vacation handoff (full portfolio) | 2.0 |

Factor this transfer effort into the receiving PM's load for the first week after transfer.

## Seasonal Patterns

Be aware of predictable workload spikes:

| Period | Expected Impact | Planning Action |
|--------|----------------|----------------|
| January-February | Moderate -- post-holiday catch-up, Chinese New Year disruptions | Front-load work before CNY; expect partner communication gaps |
| March-April | High -- Q1 catch-up, new fiscal year orders | Ensure balanced loads entering Q1 |
| July-August | Variable -- vacation season for customers and PMs | Plan handoffs early; stagger PM vacations |
| September-November | High -- Q4 push, holiday season ordering | Maximize PM availability; minimize PTO |
| December | Low-moderate -- holiday slowdown | Good time for profit analysis and process improvement |

## Reporting

Generate a workload report showing:

1. Current weighted load per PM
2. Load trend over last 4 weeks (increasing/stable/decreasing)
3. Imbalance ratio
4. Upcoming changes (orders expected to complete, new RFQs expected)
5. PM availability (planned PTO, partial availability)
