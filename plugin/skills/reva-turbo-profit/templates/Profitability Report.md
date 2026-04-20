# Profitability Report

**Rev A Manufacturing -- Order Profitability Analysis**

---

**Report Date:** {{REPORT_DATE}}
**Prepared By:** REVA-TURBO Profit Analysis Engine
**Reviewed By:** {{ASSIGNED_PM}}

---

## 1. Order Summary

| Field | Value |
|-------|-------|
| Order ID | {{ORDER_ID}} |
| Quote Number | {{QUOTE_NUMBER}} |
| Customer | {{CUSTOMER_COMPANY}} |
| Customer Contact | {{CUSTOMER_CONTACT}} |
| Part Description | {{PART_DESCRIPTION}} |
| Part Number | {{PART_NUMBER}} |
| Process Type | {{PROCESS_TYPE}} |
| Manufacturing Partner | {{MFG_PARTNER}} |
| Quantity Ordered | {{QUANTITY_ORDERED}} |
| Quantity Delivered | {{QUANTITY_DELIVERED}} |
| Order Date | {{ORDER_DATE}} |
| Delivery Date | {{DELIVERY_DATE}} |
| Customer Tier | {{CUSTOMER_TIER}} |
| Complexity Rating | {{COMPLEXITY}} / 5 |

---

## 2. Cost Breakdown: Estimated vs Actual

| Cost Category | Estimated | Actual | Variance ($) | Variance (%) | Flag |
|--------------|-----------|--------|-------------|-------------|------|
| Material | ${{EST_MATERIAL_EXT}} | ${{ACT_MATERIAL_EXT}} | ${{VAR_MATERIAL}} | {{VAR_MATERIAL_PCT}}% | {{FLAG_MATERIAL}} |
| Manufacturing | ${{EST_MFG_EXT}} | ${{ACT_MFG_EXT}} | ${{VAR_MFG}} | {{VAR_MFG_PCT}}% | {{FLAG_MFG}} |
| Tooling (NRE) | ${{EST_TOOLING}} | ${{ACT_TOOLING}} | ${{VAR_TOOLING}} | {{VAR_TOOLING_PCT}}% | {{FLAG_TOOLING}} |
| Finishing | ${{EST_FINISH_EXT}} | ${{ACT_FINISH_EXT}} | ${{VAR_FINISH}} | {{VAR_FINISH_PCT}}% | {{FLAG_FINISH}} |
| Assembly | ${{EST_ASSEMBLY_EXT}} | ${{ACT_ASSEMBLY_EXT}} | ${{VAR_ASSEMBLY}} | {{VAR_ASSEMBLY_PCT}}% | {{FLAG_ASSEMBLY}} |
| Quality/Inspection | ${{EST_QUALITY_EXT}} | ${{ACT_QUALITY_TOTAL}} | ${{VAR_QUALITY}} | {{VAR_QUALITY_PCT}}% | {{FLAG_QUALITY}} |
| Overhead | ${{EST_OVERHEAD_EXT}} | ${{ACT_OVERHEAD}} | ${{VAR_OVERHEAD}} | {{VAR_OVERHEAD_PCT}}% | {{FLAG_OVERHEAD}} |
| Shipping (International) | ${{EST_SHIP_INTL}} | ${{ACT_SHIP_INTL}} | ${{VAR_SHIP_INTL}} | {{VAR_SHIP_INTL_PCT}}% | {{FLAG_SHIP_INTL}} |
| Shipping (Domestic) | ${{EST_SHIP_DOMESTIC}} | ${{ACT_SHIP_DOMESTIC}} | ${{VAR_SHIP_DOM}} | {{VAR_SHIP_DOM_PCT}}% | {{FLAG_SHIP_DOM}} |
| Scrap/Rework | $0 | ${{ACT_SCRAP}} | ${{ACT_SCRAP}} | N/A | {{FLAG_SCRAP}} |
| Warranty/Returns | $0 | ${{ACT_WARRANTY}} | ${{ACT_WARRANTY}} | N/A | {{FLAG_WARRANTY}} |
| Repackaging | ${{EST_REPACK}} | ${{ACT_REPACK}} | ${{VAR_REPACK}} | {{VAR_REPACK_PCT}}% | {{FLAG_REPACK}} |
| Other | ${{EST_OTHER}} | ${{ACT_OTHER}} | ${{VAR_OTHER}} | {{VAR_OTHER_PCT}}% | {{FLAG_OTHER}} |
| **TOTAL COST** | **${{EST_TOTAL_COST}}** | **${{ACT_TOTAL_COST}}** | **${{VAR_TOTAL}}** | **{{VAR_TOTAL_PCT}}%** | **{{FLAG_TOTAL}}** |

**Flag Key:** OK (<5%) | NOTE (5-15%) | REVIEW (15-25%) | ESCALATE (>25%)

---

## 3. Variance Analysis

### Categories Requiring Attention

{{#VARIANCE_ALERTS}}

**{{ALERT_CATEGORY}} -- {{ALERT_FLAG}}**

| Detail | Value |
|--------|-------|
| Estimated | ${{ALERT_ESTIMATED}} |
| Actual | ${{ALERT_ACTUAL}} |
| Variance | ${{ALERT_VARIANCE}} ({{ALERT_VARIANCE_PCT}}%) |
| Root cause | {{ALERT_ROOT_CAUSE}} |
| One-time or systemic | {{ALERT_SYSTEMIC}} |
| Recommended action | {{ALERT_ACTION}} |

{{/VARIANCE_ALERTS}}

### Overall Variance Summary

- **Total cost variance:** ${{VAR_TOTAL}} ({{VAR_TOTAL_PCT}}%)
- **Number of categories at REVIEW or above:** {{REVIEW_COUNT}}
- **Number of categories at ESCALATE:** {{ESCALATE_COUNT}}
- **Primary variance driver:** {{PRIMARY_DRIVER}}

---

## 4. Profitability Metrics

| Metric | Quoted | Actual | Delta |
|--------|--------|--------|-------|
| Revenue | ${{EST_TOTAL_REVENUE}} | ${{ACTUAL_REVENUE}} | ${{REVENUE_DELTA}} |
| Total Cost | ${{EST_TOTAL_COST}} | ${{ACT_TOTAL_COST}} | ${{VAR_TOTAL}} |
| Gross Profit | ${{EST_GROSS_PROFIT}} | ${{GROSS_PROFIT}} | ${{PROFIT_DELTA}} |
| Gross Margin % | {{QUOTED_MARGIN}}% | {{GROSS_MARGIN_PCT}}% | {{MARGIN_DELTA}} pts |

### Margin Assessment

**Status:** {{MARGIN_STATUS}}

{{MARGIN_COMMENTARY}}

### Benchmark Comparison

| Benchmark | Target | Actual | Status |
|-----------|--------|--------|--------|
| Process margin ({{PROCESS_TYPE}}) | {{PROCESS_TARGET}}% | {{GROSS_MARGIN_PCT}}% | {{PROCESS_STATUS}} |
| Customer tier margin ({{CUSTOMER_TIER}}) | {{TIER_TARGET}}% | {{GROSS_MARGIN_PCT}}% | {{TIER_STATUS}} |
| Minimum acceptable margin | 15% | {{GROSS_MARGIN_PCT}}% | {{MIN_STATUS}} |

### Cost of Poor Quality (COPQ)

| Component | Amount |
|-----------|--------|
| Scrap cost | ${{ACT_SCRAP}} |
| Rework cost | ${{REWORK_COST}} |
| Re-inspection cost | ${{REINSPECTION_COST}} |
| Warranty cost | ${{ACT_WARRANTY}} |
| **Total COPQ** | **${{TOTAL_COPQ}}** |
| **COPQ as % of revenue** | **{{COPQ_PCT}}%** |
| COPQ target | <2% |
| COPQ status | {{COPQ_STATUS}} |

---

## 5. Customer Lifetime Value

| Metric | Value |
|--------|-------|
| Total orders analyzed | {{LIFETIME_ORDER_COUNT}} |
| Customer since | {{CUSTOMER_SINCE}} |
| Total lifetime revenue | ${{LIFETIME_REVENUE}} |
| Total lifetime cost | ${{LIFETIME_COST}} |
| Lifetime gross profit | ${{LIFETIME_GROSS_PROFIT}} |
| Lifetime gross margin % | {{LIFETIME_MARGIN_PCT}}% |
| Average order value | ${{AVG_ORDER_VALUE}} |
| Average order margin | {{AVG_ORDER_MARGIN}}% |
| Best order margin | {{BEST_MARGIN}}% |
| Worst order margin | {{WORST_MARGIN}}% |
| Margin trend | {{TREND_DIRECTION}} |

### Order History

| # | Order ID | Date | Revenue | Cost | Margin |
|---|----------|------|---------|------|--------|
{{#ORDER_HISTORY}}
| {{ORDER_NUM}} | {{HIST_ORDER_ID}} | {{HIST_DATE}} | ${{HIST_REVENUE}} | ${{HIST_COST}} | {{HIST_MARGIN}}% |
{{/ORDER_HISTORY}}

### Margin Trend Visualization

```
Margin %
  40 |
  35 |
  30 |  {{TREND_CHART}}
  25 |
  20 |  - - - - - - - - minimum (15%)
  15 |
  10 |
   5 |
   0 +--+--+--+--+--+--+--+--+--+--
     {{TREND_DATES}}
```

---

## 6. Insights and Recommendations

### Key Findings

1. {{FINDING_1}}
2. {{FINDING_2}}
3. {{FINDING_3}}

### Recommendations

| Priority | Recommendation | Expected Impact | Owner |
|----------|---------------|----------------|-------|
| 1 | {{REC_1}} | {{IMPACT_1}} | {{OWNER_1}} |
| 2 | {{REC_2}} | {{IMPACT_2}} | {{OWNER_2}} |
| 3 | {{REC_3}} | {{IMPACT_3}} | {{OWNER_3}} |

### Quoting Feedback

{{QUOTING_FEEDBACK}}

---

## 7. Action Items

- [ ] {{ACTION_1}}
- [ ] {{ACTION_2}}
- [ ] {{ACTION_3}}
- [ ] {{ACTION_4}}

---

*Generated by REVA-TURBO Profit Analysis Engine v1.0.0*
*Report: REVA-TURBO-Profit-{{REPORT_DATE}}-{{CUSTOMER_SHORT}}-{{ORDER_ID}}.md*
