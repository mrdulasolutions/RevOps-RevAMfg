# Lead Time Matrix

## Standard Lead Times by Process

### CNC Machining

| Volume | Manufacturing | Notes |
|--------|--------------|-------|
| 1-10 pcs (prototype) | 2-3 weeks | Fastest turnaround |
| 11-100 pcs | 3-5 weeks | Standard production |
| 101-500 pcs | 4-6 weeks | May require fixture optimization |
| 501-2,000 pcs | 5-8 weeks | Multi-run production |
| 2,001+ pcs | 6-10 weeks | Phased delivery possible |

### Injection Molding

| Phase | Duration | Notes |
|-------|----------|-------|
| Mold design review | 3-5 days | DFM feedback to customer |
| Tooling fabrication | 4-6 weeks (simple), 6-8 weeks (complex) | From design approval |
| T1 samples | 1-2 weeks after tooling | First trial shots |
| T1 review and approval | 3-5 days (customer) | Customer reviews samples |
| T2 (if needed) | 1 week | Mold modifications + re-trial |
| Production (per run) | 2-4 weeks | Depends on quantity |

### Sheet Metal

| Volume | Manufacturing | Notes |
|--------|--------------|-------|
| 1-25 pcs | 2-3 weeks | Prototype/short run |
| 26-250 pcs | 3-5 weeks | Low volume production |
| 251-1,000 pcs | 4-6 weeks | Production |
| 1,001+ pcs | 5-8 weeks | May require progressive tooling |

### Finishing (Added to Manufacturing)

| Process | Duration |
|---------|----------|
| Anodizing (Type II) | 3-5 days |
| Hard anodize (Type III) | 5-7 days |
| Plating (zinc, nickel) | 3-5 days |
| Powder coating | 3-5 days |
| Painting (custom color) | 5-7 days |
| Bead blasting | 1-2 days |
| Passivation | 1-2 days |

### Assembly (Added to Manufacturing)

| Complexity | Duration |
|-----------|----------|
| Simple (2-5 components) | 2-3 days |
| Medium (5-10 components) | 3-5 days |
| Complex (10+ components) | 5-10 days |

## Logistics Lead Times

| Stage | Ocean Freight | Air Freight |
|-------|--------------|-------------|
| China manufacturing to port | 1-3 days | 1-2 days |
| International transit | 18-30 days | 3-7 days |
| US customs clearance | 3-5 business days | 2-3 business days |
| Delivery to Rev A facility | 2-3 days | 1-2 days |

## Rev A Processing

| Stage | Duration |
|-------|----------|
| Incoming inspection (standard) | 1-2 business days |
| Incoming inspection (detailed/FAIR) | 2-4 business days |
| Repackaging (standard) | 1 business day |
| Repackaging (custom/kitting) | 1-3 business days |
| Domestic shipping (ground) | 3-5 business days |
| Domestic shipping (2-day) | 2 business days |
| Domestic shipping (overnight) | 1 business day |

## Total Lead Time Calculator

### Formula:
```
Total = Manufacturing + Finishing + Assembly + International Shipping + Customs + Inspection + Repackaging + Domestic Shipping
```

### Quick Reference Totals

| Scenario | Ocean | Air |
|----------|-------|-----|
| Simple machined parts (prototype) | 7-10 weeks | 4-6 weeks |
| Production machined parts | 10-15 weeks | 7-10 weeks |
| New mold + first production run | 14-20 weeks | 10-14 weeks |
| Production molded parts (existing tool) | 7-11 weeks | 4-7 weeks |
| Sheet metal production | 9-13 weeks | 6-9 weeks |
| Complex assembly | 13-20 weeks | 9-14 weeks |

## Rush Order Adjustments

Rush orders can compress manufacturing lead time by 30-50% with:
- Premium charges (15-30% surcharge)
- Air freight (standard)
- Expedited customs brokerage
- Priority inspection at Rev A

Minimum achievable lead times (air freight):
- Simple machined prototype: 2-3 weeks
- Production parts (existing process): 4-6 weeks
- New tooling + production: 8-10 weeks
