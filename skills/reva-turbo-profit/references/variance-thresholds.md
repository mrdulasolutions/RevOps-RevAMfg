# Variance Thresholds Reference

Rules for flagging and acting on cost variances between estimated and actual costs.

## Threshold Levels

### OK: <5% Variance (absolute)

- **Action:** None required
- **Logging:** Record for trend tracking, no flag
- **Meaning:** Normal estimation tolerance. Costs are within expected range.
- **Display:** Green / no icon

### NOTE: 5-15% Variance (absolute)

- **Action:** Log for future quoting reference. No immediate action required.
- **Logging:** Record with NOTE flag. Include in running average calculations.
- **Meaning:** Estimation was off but within acceptable range. If this category consistently falls in this range, consider adjusting.
- **Display:** Yellow / caution icon
- **PM guidance:** "No action required, but keep an eye on this category. If you see NOTE flags on the same category across 3+ orders, consider adjusting your estimation."

### REVIEW: 15-25% Variance (absolute)

- **Action:** PM should review estimation methodology for this category. Adjust future estimates.
- **Logging:** Record with REVIEW flag. Add to PM review queue.
- **Meaning:** Estimation was significantly off. There is either a systematic error in how this category is estimated, or an unusual circumstance on this order.
- **Display:** Orange / warning icon
- **PM guidance:** "Review this variance. If it was a one-time event (expedited shipping, unexpected rework), note the cause. If it is a pattern, update your estimation approach for this category."

### ESCALATE: >25% Variance (absolute)

- **Action:** Investigate root cause. If systemic (appears on 2+ orders), escalate to Donovan Weber.
- **Logging:** Record with ESCALATE flag. Add to escalation queue.
- **Meaning:** Major estimation miss. This significantly impacts profitability and indicates either a fundamental error in cost assumptions or an operational issue.
- **Display:** Red / alert icon
- **PM guidance:** "This is a major variance that needs investigation. Determine the root cause: was the estimate wrong, did costs change, or did something go wrong during execution? If this is a pattern, escalate to Donovan."

## Direction Matters

Variance can be positive (cost overrun) or negative (cost underrun). Both directions require attention:

### Positive Variance (Actual > Estimated = Cost Overrun)
- Directly erodes margin
- More urgent to address
- Common causes: underestimated complexity, partner price increases, quality issues, expedited shipping

### Negative Variance (Actual < Estimated = Cost Underrun)
- Means you may be overpricing and losing deals
- Less urgent but still important for competitiveness
- Common causes: overestimated complexity, favorable shipping rates, efficient manufacturing

## Running Average Tracking

Track variance averages across multiple dimensions:

### By Cost Category
```
Running average = Sum of variances for category / Number of orders analyzed
```
Track separately for positive and negative variances.

Flag when running average exceeds NOTE threshold (5%) across 5+ orders.

### By Process Type

| Process | Expected Variance Range | Alert If Exceeds |
|---------|------------------------|------------------|
| CNC Machining | +/- 10% | 15% |
| Injection Molding | +/- 8% | 12% |
| Sheet Metal | +/- 12% | 18% |
| Die Casting | +/- 10% | 15% |
| Assembly | +/- 15% | 20% |
| Finishing | +/- 10% | 15% |

Process types with inherently higher variability get wider acceptable ranges.

### By Partner

Track each manufacturing partner's cost variance trend:

- New partner (first 3 orders): wider tolerance (+/- 20% before ESCALATE)
- Established partner (4-10 orders): standard thresholds apply
- Long-term partner (10+ orders): tighter tolerance -- if variance exceeds 10% consistently, something has changed

Flag when a partner's average variance shifts by more than 5 percentage points over a 6-month period.

### By Material Type

Track material cost variances by material category:

| Material | Typical Volatility | Adjust Threshold |
|----------|-------------------|-----------------|
| Aluminum (6061, 7075) | Medium | Standard |
| Steel (mild, stainless) | Medium-High | +5% to thresholds |
| Copper/Brass | High | +8% to thresholds |
| Engineering Plastics | Low-Medium | Standard |
| Commodity Plastics | Low | -3% from thresholds |
| Titanium | High | +10% to thresholds |
| Exotic Alloys | Very High | +15% to thresholds |

Materials with high price volatility get wider acceptable variance ranges.

### By Customer

Track variance patterns per customer:

- Some customers drive higher quality costs (tighter specs, more inspection)
- Some customers drive higher shipping costs (expedite requests, special delivery)
- Use per-customer variance history to adjust future quotes for that customer

## Compound Variance Alert

When multiple categories on the same order each show REVIEW or ESCALATE levels, even if no single category exceeds ESCALATE, trigger a compound alert:

- 2+ categories at REVIEW level: treat as ESCALATE
- 3+ categories at NOTE level: treat as REVIEW
- Any combination where total cost variance exceeds 20%: ESCALATE regardless of individual category flags

## Seasonal and Market Adjustments

Certain variances are expected and should be noted but not flagged as estimation errors:

- **Q4 shipping surcharges:** Ocean freight rates typically increase 10-20% in Sep-Nov. If your quote was prepared in Q2 for Q4 delivery, expect shipping variance.
- **Chinese New Year:** Orders manufactured Jan-Feb may have overtime/rush premiums. Expect 5-10% manufacturing variance.
- **Tariff changes:** If Section 301 tariff rates change between quote and delivery, shipping/customs variance is expected.
- **Material price swings:** Major commodity price moves (>10% in the underlying material market) should be noted as market-driven, not estimation error.

When seasonal/market factors explain the variance, log it as "market-driven" rather than "estimation error" so it does not pollute the running average for estimation accuracy.
