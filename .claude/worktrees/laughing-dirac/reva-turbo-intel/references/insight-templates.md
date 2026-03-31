# Intel Insight Templates

Pre-built insight patterns for common findings. Use these as templates when generating intelligence output. Fill the variables from actual data analysis.

## Partner Insights

### Performance Comparison
```
Partner {{PARTNER_NAME}} delivers {{PERCENT_DIFF}}% {{faster/slower}} than the partner average for {{PROCESS_TYPE}} orders.
Based on {{DATA_POINTS}} orders over the last {{TIME_PERIOD}}.
Confidence: {{CONFIDENCE_LEVEL}}
```

### Capacity Signal
```
Partner {{PARTNER_NAME}} currently has {{CONCURRENT_ORDERS}} active orders (their average is {{AVG_CONCURRENT}}).
Their on-time delivery rate drops from {{NORMAL_OTD}}% to {{LOADED_OTD}}% when concurrent orders exceed {{THRESHOLD}}.
Recommendation: {{RECOMMENDATION}}
```

### Quality Trend
```
Partner {{PARTNER_NAME}}'s first pass yield has {{increased/decreased}} from {{OLD_FPY}}% to {{NEW_FPY}}% over the last {{TIME_PERIOD}}.
This represents a {{DIRECTION}} trend of {{RATE}} percentage points per month.
{{IF_DECLINING}} Recommend: Review partner scorecard and discuss quality improvement plan.
```

### Score Prediction
```
Based on the current trend, Partner {{PARTNER_NAME}}'s scorecard grade is projected to {{rise to/drop to}} {{PROJECTED_GRADE}} within {{TIME_HORIZON}}.
Current grade: {{CURRENT_GRADE}} | 3-month projected: {{PROJECTED_GRADE}}
Key driver: {{KEY_DRIVER}} (contributing {{CONTRIBUTION}}% of the change)
```

## Customer Insights

### Conversion Pattern
```
Customer {{CUSTOMER_NAME}} has a {{CONVERSION_RATE}}% quote-to-PO conversion rate, which is {{ABOVE/BELOW}} the {{AVERAGE_RATE}}% company average.
Based on {{QUOTES_SENT}} quotes sent over {{TIME_PERIOD}}.
{{IF_ABOVE}} This customer is a reliable converter. Consider priority service.
{{IF_BELOW}} Investigate: is it pricing, lead time, or competition?
```

### Lifetime Value
```
Customer {{CUSTOMER_NAME}} has generated {{TOTAL_REVENUE}} in revenue across {{TOTAL_ORDERS}} orders since {{FIRST_ORDER_DATE}}.
CLV: {{CLV_AMOUNT}} (revenue minus all associated costs)
Average order value: {{AOV}}
Order frequency: every {{AVG_FREQUENCY}} days
Projected next 12 months: {{PROJECTED_REVENUE}} ({{CONFIDENCE_LEVEL}} confidence)
```

### Churn Warning
```
Customer {{CUSTOMER_NAME}} has not placed an order in {{DAYS_SINCE_LAST}} days.
Their historical order frequency is every {{AVG_FREQUENCY}} days.
This gap is {{MULTIPLE}}x their normal frequency.
Churn risk: {{RISK_LEVEL}}
Contributing factors: {{FACTORS}}
Recommendation: {{RECOMMENDATION}}
```

### Upsell Opportunity
```
Customer {{CUSTOMER_NAME}} currently orders {{CURRENT_PROCESSES}} from Rev A.
Similar customers ({{SIMILAR_CUSTOMER_COUNT}} companies in {{INDUSTRY}}) also order {{ADDITIONAL_PROCESSES}}.
Estimated upsell opportunity: {{ESTIMATED_REVENUE}} per year
Recommendation: Discuss {{SPECIFIC_CAPABILITY}} capability during next order interaction.
```

## Delivery Insights

### Lead Time Shift
```
Lead time for {{PROCESS_TYPE}} has {{increased/decreased}} by {{DAYS_CHANGE}} days over the last {{TIME_PERIOD}}.
Previous average: {{OLD_AVG}} days | Current average: {{NEW_AVG}} days
This affects {{AFFECTED_ORDERS}} currently active orders.
{{IF_INCREASED}} Recommendation: Adjust quoted lead times for new RFQs. Notify customers on active orders if commitments are at risk.
```

### At-Risk Orders
```
{{AT_RISK_COUNT}} orders are at risk of late delivery based on current milestone velocity:

| Order | Customer | Partner | Expected | Projected | Risk |
|-------|----------|---------|----------|-----------|------|
| {{ORDER_ID}} | {{CUSTOMER}} | {{PARTNER}} | {{EXPECTED_DATE}} | {{PROJECTED_DATE}} | {{RISK_LEVEL}} |

Recommendation: Prioritize partner communication on the highest-risk orders.
```

### Bottleneck Detection
```
Stage {{STAGE_NAME}} is the current bottleneck in the Rev A lifecycle.
Average time in this stage: {{AVG_TIME}} days (vs. {{EXPECTED_TIME}} days planned)
Variance: {{VARIANCE}} days ({{HIGH/LOW}} predictability)
{{PERCENT_ORDERS}}% of orders are currently in this stage.
Recommendation: {{RECOMMENDATION}}
```

## Quality Insights

### Defect Pareto
```
Top {{TOP_N}} defect types account for {{PARETO_PERCENT}}% of all NCRs:

| Rank | Defect Type | Count | % of Total | Top Partner | COPQ |
|------|-------------|-------|-----------|-------------|------|
| {{RANK}} | {{DEFECT_TYPE}} | {{COUNT}} | {{PERCENT}} | {{TOP_PARTNER}} | {{COPQ}} |

Recommendation: Focus corrective action on the top {{TOP_N}} defect types for maximum impact.
```

### Root Cause Pattern
```
Analysis of {{NCR_COUNT}} NCRs reveals a correlation between {{FACTOR}} and {{DEFECT_TYPE}}:
- When {{CONDITION}}: defect rate = {{HIGH_RATE}}%
- When not {{CONDITION}}: defect rate = {{LOW_RATE}}%
- Correlation: r = {{CORRELATION}} ({{STRENGTH}})

Hypothesis: {{HYPOTHESIS}}
Recommendation: {{RECOMMENDATION}}
```

### COPQ Trend
```
Cost of Poor Quality over the last {{TIME_PERIOD}}:
Total COPQ: {{TOTAL_COPQ}}
COPQ as % of revenue: {{COPQ_PERCENT}}%
Trend: {{DIRECTION}} ({{RATE}} per month)
Largest contributor: {{TOP_CONTRIBUTOR}} ({{CONTRIBUTOR_PERCENT}}%)
Recommendation: {{RECOMMENDATION}}
```

## Quoting Insights

### Optimal Price Signal
```
For {{PROCESS_TYPE}} parts in the {{QUANTITY_RANGE}} quantity range:
- Sweet spot price: {{OPTIMAL_PRICE}} ({{OPTIMAL_WIN_RATE}}% win rate, {{OPTIMAL_MARGIN}}% margin)
- Below {{FLOOR_PRICE}}: win rate plateaus at {{MAX_WIN_RATE}}% (diminishing returns on discounting)
- Above {{CEILING_PRICE}}: win rate drops below {{MIN_VIABLE_WIN_RATE}}%
Based on {{DATA_POINTS}} historical quotes.
```

### Win/Loss Pattern
```
Analysis of {{TOTAL_QUOTES}} quotes in the last {{TIME_PERIOD}}:
- Won: {{WON_COUNT}} ({{WON_PERCENT}}%)
- Lost: {{LOST_COUNT}} ({{LOST_PERCENT}}%)
- Expired: {{EXPIRED_COUNT}} ({{EXPIRED_PERCENT}}%)

Top reasons for loss:
1. {{LOSS_REASON_1}} ({{LOSS_1_PERCENT}}%)
2. {{LOSS_REASON_2}} ({{LOSS_2_PERCENT}}%)
3. {{LOSS_REASON_3}} ({{LOSS_3_PERCENT}}%)

Recommendation: {{RECOMMENDATION}}
```

### Discount Impact
```
Discount analysis over {{TIME_PERIOD}}:
- No discount: {{NO_DISC_WIN_RATE}}% win rate, {{NO_DISC_MARGIN}}% margin
- 1-5% discount: {{LOW_DISC_WIN_RATE}}% win rate, {{LOW_DISC_MARGIN}}% margin
- 6-10% discount: {{MID_DISC_WIN_RATE}}% win rate, {{MID_DISC_MARGIN}}% margin
- >10% discount: {{HIGH_DISC_WIN_RATE}}% win rate, {{HIGH_DISC_MARGIN}}% margin

Inflection point: {{INFLECTION}}% discount (win rate improvement flattens beyond this)
Revenue-maximizing discount: {{OPTIMAL_DISCOUNT}}%
```

## Operational Insights

### PM Workload
```
PM workload distribution:

| PM | Active Orders | Pipeline Value | Utilization | Alert Rate |
|----|--------------|---------------|-------------|------------|
| {{PM_NAME}} | {{ACTIVE}} | {{VALUE}} | {{UTIL}}% | {{ALERTS}}/wk |

{{IF_IMBALANCED}} Workload is imbalanced. Consider redistributing {{EXCESS_ORDERS}} orders from {{OVERLOADED_PM}} to {{UNDERLOADED_PM}}.
```

### Autopilot ROI
```
Autopilot performance over {{TIME_PERIOD}}:
Auto-transitions executed: {{AUTO_COUNT}}
Estimated time saved: {{TIME_SAVED}} hours ({{PER_ORDER}} minutes per order)
Pause points hit: {{PAUSE_COUNT}} (all required human review)
Auto-transition success rate: {{SUCCESS_RATE}}%
PM cancellation rate: {{CANCEL_RATE}}%

{{IF_LOW_ADOPTION}} Autopilot adoption is at {{ADOPTION}}%. Consider SEMI AUTO mode for routine reorders to capture efficiency gains.
```
