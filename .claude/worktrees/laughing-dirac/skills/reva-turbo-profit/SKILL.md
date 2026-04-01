---
name: reva-turbo-profit
preamble-tier: 2
version: 1.0.0
description: |
  Real cost vs estimated tracking for Rev A Manufacturing. Compare actual costs
  to quoted costs after delivery. Calculate per-order and per-customer lifetime
  profitability. Generate variance analysis and margin adjustment recommendations.
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
mkdir -p ~/.reva-turbo/analytics
echo '{"skill":"reva-turbo-profit","ts":"'$(date -u +%Y-%m-%dT%H:%M:%SZ)'"}' >> ~/.reva-turbo/analytics/skill-usage.jsonl 2>/dev/null || true
```

## Purpose

Track real profitability for Rev A Manufacturing orders. Compare actual costs against original estimates, surface systematic quoting errors, and provide actionable margin guidance. Answers the question every PM needs answered: "Am I making money on this order, and where am I leaving it on the table?"

## Prerequisites

This skill expects a delivered order with a completed quote (from `reva-turbo-rfq-quote`) and actual cost data available. If the order has not been delivered, warn the PM:

> This order has not been marked as delivered. Profit analysis is most accurate after all costs are finalized.
> A) Proceed with preliminary analysis (costs may change)
> B) Wait until order is delivered and all invoices are in

## Flow

### Step 1: Order Selection

Ask the PM to select the delivered order for profit analysis:

> Which delivered order do you want to analyze for profitability?
>
> Enter order ID, customer name, or quote number: ___

Search for the order data:

```bash
grep -l "{{ORDER_SEARCH}}" ~/.reva-turbo/state/workflow-state.jsonl 2>/dev/null || echo "No matching orders found"
```

If multiple matches, present a selection list. If no match, ask the PM to provide the order details manually.

Display the order summary:

> **Order found:**
> - Order ID: {{ORDER_ID}}
> - Customer: {{CUSTOMER_COMPANY}}
> - Part: {{PART_DESCRIPTION}}
> - Quantity: {{QUANTITY}}
> - Quote number: {{QUOTE_NUMBER}}
> - Delivery date: {{DELIVERY_DATE}}
>
> Is this the correct order? (Y/N)

### Step 2: Estimated Cost Pull

Retrieve the original quote cost breakdown from the quote record. Reference `references/cost-categories.md` for category definitions.

**Estimated cost breakdown (from original quote):**

| Cost Category | Estimated Per Unit | Estimated Extended |
|--------------|-------------------|-------------------|
| Material | ${{EST_MATERIAL_UNIT}} | ${{EST_MATERIAL_EXT}} |
| Manufacturing | ${{EST_MFG_UNIT}} | ${{EST_MFG_EXT}} |
| Tooling (NRE) | -- | ${{EST_TOOLING}} |
| Finishing | ${{EST_FINISH_UNIT}} | ${{EST_FINISH_EXT}} |
| Assembly | ${{EST_ASSEMBLY_UNIT}} | ${{EST_ASSEMBLY_EXT}} |
| Quality/Inspection | ${{EST_QUALITY_UNIT}} | ${{EST_QUALITY_EXT}} |
| Overhead allocation | ${{EST_OVERHEAD_UNIT}} | ${{EST_OVERHEAD_EXT}} |
| Shipping (intl) | -- | ${{EST_SHIP_INTL}} |
| Shipping (domestic) | -- | ${{EST_SHIP_DOMESTIC}} |
| **Total estimated cost** | -- | **${{EST_TOTAL_COST}}** |

**Estimated revenue:**

| Element | Amount |
|---------|--------|
| Quoted unit price | ${{QUOTED_PRICE_UNIT}} |
| Extended price | ${{QUOTED_PRICE_EXT}} |
| Tooling charged to customer | ${{TOOLING_CHARGED}} |
| Shipping charged to customer | ${{SHIPPING_CHARGED}} |
| **Total revenue (quoted)** | **${{EST_TOTAL_REVENUE}}** |
| **Quoted margin** | **{{QUOTED_MARGIN}}%** |

If the quote record is not found, ask the PM to enter estimated values manually.

### Step 3: Actual Cost Collection

Collect actual costs from the PM. If ERP data is available, pull automatically; otherwise, request manual entry.

> I need the actual costs for this order. Please provide values from supplier invoices, partner invoices, and internal records. Enter "same" if actual matches the estimate, or "N/A" if the category does not apply.
>
> **Material costs:**
> 1. Actual material cost (from supplier invoice): $___
> 2. Material notes (surcharges, waste, etc.): ___
>
> **Manufacturing costs:**
> 3. Actual manufacturing cost (from partner invoice): $___
> 4. Setup/changeover charges: $___
> 5. Manufacturing notes: ___
>
> **Tooling costs:**
> 6. Actual tooling cost: $___
> 7. Tooling notes (modifications, rework, etc.): ___
>
> **Finishing costs:**
> 8. Actual finishing cost: $___
> 9. Finishing notes: ___
>
> **Shipping costs:**
> 10. Actual international shipping cost: $___
> 11. Customs/duties/brokerage fees: $___
> 12. Actual domestic shipping cost: $___
> 13. Shipping notes (expedite charges, re-routes, etc.): ___
>
> **Quality costs:**
> 14. Inspection labor cost (Rev A internal): $___
> 15. Third-party testing/certification: $___
>
> **Scrap/rework costs:**
> 16. Scrap/rework cost (from NCRs if any): $___
> 17. Warranty/return cost: $___
> 18. Number of NCRs on this order: ___
>
> **Other costs:**
> 19. Repackaging cost: $___
> 20. Other costs not listed above: $___
> 21. Other cost description: ___

Build the actual cost table:

| Cost Category | Actual Per Unit | Actual Extended |
|--------------|----------------|----------------|
| Material | ${{ACT_MATERIAL_UNIT}} | ${{ACT_MATERIAL_EXT}} |
| Manufacturing | ${{ACT_MFG_UNIT}} | ${{ACT_MFG_EXT}} |
| Tooling (NRE) | -- | ${{ACT_TOOLING}} |
| Finishing | ${{ACT_FINISH_UNIT}} | ${{ACT_FINISH_EXT}} |
| Shipping (intl + customs) | -- | ${{ACT_SHIP_INTL}} |
| Shipping (domestic) | -- | ${{ACT_SHIP_DOMESTIC}} |
| Inspection labor | -- | ${{ACT_INSPECTION}} |
| Third-party testing | -- | ${{ACT_TESTING}} |
| Scrap/rework | -- | ${{ACT_SCRAP}} |
| Warranty/returns | -- | ${{ACT_WARRANTY}} |
| Repackaging | -- | ${{ACT_REPACK}} |
| Other | -- | ${{ACT_OTHER}} |
| **Total actual cost** | -- | **${{ACT_TOTAL_COST}}** |

### Step 4: Variance Analysis

Calculate variance for each cost category. Reference `references/variance-thresholds.md` for action thresholds.

| Cost Category | Estimated | Actual | Variance ($) | Variance (%) | Flag |
|--------------|-----------|--------|-------------|-------------|------|
| Material | ${{EST_MATERIAL_EXT}} | ${{ACT_MATERIAL_EXT}} | ${{VAR_MATERIAL}} | {{VAR_MATERIAL_PCT}}% | {{FLAG_MATERIAL}} |
| Manufacturing | ${{EST_MFG_EXT}} | ${{ACT_MFG_EXT}} | ${{VAR_MFG}} | {{VAR_MFG_PCT}}% | {{FLAG_MFG}} |
| Tooling | ${{EST_TOOLING}} | ${{ACT_TOOLING}} | ${{VAR_TOOLING}} | {{VAR_TOOLING_PCT}}% | {{FLAG_TOOLING}} |
| Finishing | ${{EST_FINISH_EXT}} | ${{ACT_FINISH_EXT}} | ${{VAR_FINISH}} | {{VAR_FINISH_PCT}}% | {{FLAG_FINISH}} |
| Shipping | ${{EST_SHIP_TOTAL}} | ${{ACT_SHIP_TOTAL}} | ${{VAR_SHIP}} | {{VAR_SHIP_PCT}}% | {{FLAG_SHIP}} |
| Quality/Inspection | ${{EST_QUALITY_EXT}} | ${{ACT_QUALITY_TOTAL}} | ${{VAR_QUALITY}} | {{VAR_QUALITY_PCT}}% | {{FLAG_QUALITY}} |
| Scrap/Rework | $0 | ${{ACT_SCRAP}} | ${{VAR_SCRAP}} | N/A | {{FLAG_SCRAP}} |
| Warranty/Returns | $0 | ${{ACT_WARRANTY}} | ${{VAR_WARRANTY}} | N/A | {{FLAG_WARRANTY}} |
| Repackaging | ${{EST_REPACK}} | ${{ACT_REPACK}} | ${{VAR_REPACK}} | {{VAR_REPACK_PCT}}% | {{FLAG_REPACK}} |
| **TOTAL** | **${{EST_TOTAL_COST}}** | **${{ACT_TOTAL_COST}}** | **${{VAR_TOTAL}}** | **{{VAR_TOTAL_PCT}}%** | **{{FLAG_TOTAL}}** |

Variance flag key (per `references/variance-thresholds.md`):
- OK = <5% variance
- NOTE = 5-15% variance (log for future reference)
- REVIEW = 15-25% variance (PM should adjust estimation)
- ESCALATE = >25% variance (investigate root cause)

For any REVIEW or ESCALATE flags, generate a brief analysis:

> **Variance alert: {{CATEGORY}}**
> Estimated: ${{ESTIMATED}} | Actual: ${{ACTUAL}} | Variance: {{VARIANCE_PCT}}%
> Likely cause: {{ROOT_CAUSE_HYPOTHESIS}}
> Recommended action: {{RECOMMENDED_ACTION}}

### Step 5: Profitability Calculation

Calculate order profitability:

| Metric | Value |
|--------|-------|
| Revenue (customer paid) | ${{ACTUAL_REVENUE}} |
| Total actual cost | ${{ACT_TOTAL_COST}} |
| **Gross profit** | **${{GROSS_PROFIT}}** |
| **Gross margin %** | **{{GROSS_MARGIN_PCT}}%** |
| Quoted margin | {{QUOTED_MARGIN}}% |
| Margin delta | {{MARGIN_DELTA}} percentage points |

**Margin assessment:**

Reference `references/profitability-benchmarks.md` for target benchmarks.

- If gross margin >= quoted margin: "Margin met or exceeded. This order performed as expected or better."
- If gross margin is 0-5 points below quoted: "Margin slightly below quoted. Review the highest-variance cost categories."
- If gross margin is 5-10 points below quoted: "Significant margin erosion. {{TOP_VARIANCE_CATEGORY}} is the primary driver. Adjust future estimates."
- If gross margin is >10 points below quoted: "Major margin miss. Escalate to Donovan Weber. Review quoting methodology for {{ORDER_TYPE}} orders."
- If gross margin < 15%: "Below minimum acceptable margin (15%). This order requires immediate review."
- If gross margin < 0%: "This order lost money. Immediate escalation required."

### Step 6: Customer Lifetime Profitability

Search for all orders from this customer:

```bash
grep "{{CUSTOMER_COMPANY}}" ~/.reva-turbo/state/workflow-state.jsonl 2>/dev/null | grep '"stage":"reva-turbo-profit"' || echo "No previous profit records for this customer"
```

If previous records exist, calculate lifetime metrics:

| Metric | Value |
|--------|-------|
| Total orders | {{LIFETIME_ORDER_COUNT}} |
| Total revenue (all orders) | ${{LIFETIME_REVENUE}} |
| Total cost (all orders) | ${{LIFETIME_COST}} |
| **Lifetime gross profit** | **${{LIFETIME_GROSS_PROFIT}}** |
| **Lifetime gross margin %** | **{{LIFETIME_MARGIN_PCT}}%** |
| Average order value | ${{AVG_ORDER_VALUE}} |
| Average order margin | {{AVG_ORDER_MARGIN}}% |
| Best order margin | {{BEST_MARGIN}}% (Order {{BEST_ORDER_ID}}) |
| Worst order margin | {{WORST_MARGIN}}% (Order {{WORST_ORDER_ID}}) |

**Trend analysis:**

Compare last 3 orders (if available):

| Order | Date | Revenue | Margin |
|-------|------|---------|--------|
| {{ORDER_1_ID}} | {{ORDER_1_DATE}} | ${{ORDER_1_REV}} | {{ORDER_1_MARGIN}}% |
| {{ORDER_2_ID}} | {{ORDER_2_DATE}} | ${{ORDER_2_REV}} | {{ORDER_2_MARGIN}}% |
| {{ORDER_3_ID}} | {{ORDER_3_DATE}} | ${{ORDER_3_REV}} | {{ORDER_3_MARGIN}}% |

Trend: {{TREND_DIRECTION}} (improving / stable / declining)

If declining trend:

> Margin is declining for {{CUSTOMER_COMPANY}}. Review whether:
> - Partner costs have increased without quote adjustments
> - Customer has negotiated prices down without corresponding cost reduction
> - Quality issues are driving up scrap/rework costs
> - Shipping costs have increased

### Step 7: Insight Generation

Analyze all available profit data across orders and customers. Reference `references/profitability-benchmarks.md`.

**7a. Cost estimation accuracy by category:**

Look at running average of variances across all analyzed orders:

> **Systematic estimation issues detected:**
> - {{CATEGORY_1}}: Average variance of {{AVG_VAR_1}}% across {{COUNT_1}} orders. {{DIRECTION_1}} (over/under-estimating).
>   Recommendation: {{RECOMMENDATION_1}}
> - {{CATEGORY_2}}: Average variance of {{AVG_VAR_2}}% across {{COUNT_2}} orders. {{DIRECTION_2}}.
>   Recommendation: {{RECOMMENDATION_2}}

**7b. Customer profitability ranking:**

If data for multiple customers exists:

| Rank | Customer | Orders | Lifetime Revenue | Lifetime Margin |
|------|----------|--------|-----------------|----------------|
| 1 | {{CUST_1}} | {{COUNT_1}} | ${{REV_1}} | {{MARGIN_1}}% |
| 2 | {{CUST_2}} | {{COUNT_2}} | ${{REV_2}} | {{MARGIN_2}}% |
| ... | ... | ... | ... | ... |

**7c. Process profitability:**

| Process Type | Avg Margin | Target Margin | Delta |
|-------------|-----------|---------------|-------|
| CNC Machining | {{MACH_MARGIN}}% | 25-35% | {{MACH_DELTA}} |
| Injection Molding | {{MOLD_MARGIN}}% | 20-30% | {{MOLD_DELTA}} |
| Sheet Metal | {{SHEET_MARGIN}}% | 20-30% | {{SHEET_DELTA}} |
| Die Casting | {{CAST_MARGIN}}% | 25-35% | {{CAST_DELTA}} |

**7d. Partner profitability:**

| Partner | Orders | Avg Margin | Cost Variance Trend |
|---------|--------|-----------|-------------------|
| {{PARTNER_1}} | {{P1_COUNT}} | {{P1_MARGIN}}% | {{P1_TREND}} |
| {{PARTNER_2}} | {{P2_COUNT}} | {{P2_MARGIN}}% | {{P2_TREND}} |

**7e. Actionable recommendations:**

Generate top 3 recommendations based on the data:

> **Recommendations:**
> 1. {{RECOMMENDATION_1}}
> 2. {{RECOMMENDATION_2}}
> 3. {{RECOMMENDATION_3}}

### Step 8: Build Report

**HUMAN-IN-THE-LOOP CHECKPOINT:**

> ## Profitability Analysis Summary for {{ORDER_ID}}
>
> **Customer:** {{CUSTOMER_COMPANY}}
> **Gross Profit:** ${{GROSS_PROFIT}} ({{GROSS_MARGIN_PCT}}% margin)
> **Quoted Margin:** {{QUOTED_MARGIN}}% | **Actual Margin:** {{GROSS_MARGIN_PCT}}%
> **Biggest variance:** {{TOP_VARIANCE_CATEGORY}} at {{TOP_VARIANCE_PCT}}%
>
> **Top recommendation:** {{TOP_RECOMMENDATION}}
>
> A) Generate full Profitability Report
> B) Generate Margin Alert (for below-threshold margins)
> C) Both report and alert
> D) Adjust analysis and recalculate

If A or C, generate the full report using `templates/Profitability Report.md`. Fill all `{{PLACEHOLDER}}` variables.

If B or C, generate the margin alert using `templates/Margin Alert.md`.

Save the report:

```bash
mkdir -p ~/.reva-turbo/profit-analysis/{{CUSTOMER_COMPANY}}
```

Report naming:

```
REVA-TURBO-Profit-{YYYY-MM-DD}-{CustomerShortName}-{OrderID}.md
```

### Step 9: Feedback Loop

If systematic underquoting or overquoting is detected (average variance >10% in any category across 3+ orders):

> **Systematic quoting issue detected.**
>
> Category: {{CATEGORY}}
> Average variance: {{AVG_VARIANCE}}% ({{DIRECTION}})
> Affected orders: {{AFFECTED_COUNT}}
>
> This suggests the estimation guidelines in `reva-turbo-rfq-quote` need updating.
>
> A) Generate updated margin/cost guidelines (I will draft changes to `references/margin-guidelines.md` and `references/cost-estimation.md` in `reva-turbo-rfq-quote`)
> B) Log the finding but do not update guidelines yet
> C) Dismiss

Log the profit analysis:

```bash
echo '{"ts":"'$(date -u +%Y-%m-%dT%H:%M:%SZ)'","order_id":"{{ORDER_ID}}","customer":"{{CUSTOMER_COMPANY}}","stage":"reva-turbo-profit","status":"complete","revenue":"{{ACTUAL_REVENUE}}","total_cost":"{{ACT_TOTAL_COST}}","gross_profit":"{{GROSS_PROFIT}}","gross_margin_pct":"{{GROSS_MARGIN_PCT}}","quoted_margin_pct":"{{QUOTED_MARGIN}}","margin_delta":"{{MARGIN_DELTA}}","top_variance":"{{TOP_VARIANCE_CATEGORY}}","top_variance_pct":"{{TOP_VARIANCE_PCT}}","pm":"{{ASSIGNED_PM}}"}' >> ~/.reva-turbo/state/workflow-state.jsonl 2>/dev/null || true
```

> Profitability analysis complete for {{ORDER_ID}} ({{CUSTOMER_COMPANY}}).
> Gross margin: {{GROSS_MARGIN_PCT}}% (quoted: {{QUOTED_MARGIN}}%).
> Report saved to `~/.reva-turbo/profit-analysis/{{CUSTOMER_COMPANY}}/`.

## Template References

- `prompts/profit-system.md` -- System prompt for cost accounting and variance analysis
- `prompts/profit-user-template.md` -- Variables for estimated and actual cost entry
- `references/cost-categories.md` -- Complete cost category definitions
- `references/variance-thresholds.md` -- When to flag variances and take action
- `references/profitability-benchmarks.md` -- Target benchmarks by process, customer tier, and partner
- `templates/Profitability Report.md` -- Full profitability report template
- `templates/Margin Alert.md` -- Quick alert for below-threshold margins
