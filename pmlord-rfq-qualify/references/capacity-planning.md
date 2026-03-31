# Capacity Planning Reference

## PM Workload Guidelines

| Metric | Target | Warning | Overloaded |
|--------|--------|---------|------------|
| Active orders per PM | 8-12 | 13-16 | 17+ |
| Active RFQs in progress | 5-8 | 9-12 | 13+ |
| Orders in China production | 6-10 | 11-14 | 15+ |
| Incoming inspections this week | 2-4 | 5-6 | 7+ |

## PM Team

| PM | Role | Specialty |
|----|------|-----------|
| Ray Yeh | Senior Project Manager | Complex assemblies, injection molding, high-volume production |
| Harley Scott | Senior Project Manager | CNC machining, prototyping, sheet metal, quick-turn |

## Lead Time Estimates

### Manufacturing (China Partner)

| Process | Prototype | Low Volume (<500) | Production (500+) |
|---------|-----------|--------------------|--------------------|
| CNC Machining | 2-3 weeks | 3-5 weeks | 5-8 weeks |
| Injection Molding (tooling) | N/A | 4-6 weeks | 6-8 weeks |
| Injection Molding (production) | N/A | 2-3 weeks | 3-5 weeks |
| 3D Printing / Rapid Proto | 1-2 weeks | N/A | N/A |
| Sheet Metal | 2-3 weeks | 3-5 weeks | 5-7 weeks |
| Finishing (added to mfg) | +1 week | +1-2 weeks | +2 weeks |
| Assembly (added to mfg) | +1 week | +1-2 weeks | +1-2 weeks |

### Logistics

| Stage | Duration |
|-------|----------|
| China to US shipping (ocean) | 3-5 weeks |
| China to US shipping (air) | 1-2 weeks |
| US customs clearance | 3-5 business days |
| Incoming inspection at Rev A | 2-3 business days |
| Repackaging | 1-2 business days |
| Domestic shipping to customer | 2-5 business days |

### Total Lead Time Estimates

| Scenario | Air Shipping | Ocean Shipping |
|----------|-------------|----------------|
| Simple prototype | 4-6 weeks | 7-10 weeks |
| Low-volume machined parts | 6-9 weeks | 9-13 weeks |
| Production machined parts | 8-12 weeks | 11-16 weeks |
| Injection molding (new tool + parts) | 8-12 weeks | 11-16 weeks |
| Injection molding (existing tool) | 4-7 weeks | 7-11 weeks |
| Sheet metal production | 7-11 weeks | 10-14 weeks |
| Complex assembly | 10-16 weeks | 13-20 weeks |

## Capacity Check Process

1. **Query PM workload** — Count active orders for the assigned PM
2. **Estimate manufacturing time** — Based on process type, quantity, and complexity
3. **Add logistics buffer** — Shipping method (ocean default, air for rush)
4. **Compare to requested delivery** — Is the total lead time within the customer's timeline?
5. **Identify conflicts** — Flag if delivery timeline is shorter than minimum lead time
6. **Suggest alternatives** — If capacity is tight, suggest timeline adjustment, air shipping, or PM load balancing

## Rush Order Policy

Rush orders (delivery < minimum lead time) are possible with:
- Air freight instead of ocean shipping (added cost: $2-10/kg depending on volume)
- Expedited manufacturing (added cost: 15-30% premium)
- PM and Donovan Weber approval required for rush commitments
- Customer must acknowledge rush pricing before proceeding
