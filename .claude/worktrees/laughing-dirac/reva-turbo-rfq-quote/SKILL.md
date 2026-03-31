---
name: reva-turbo-rfq-quote
preamble-tier: 2
version: 1.0.0
description: |
  Generate customer-facing quote packages for Rev A Manufacturing. Covers cost
  estimation, margin calculation, lead time, tooling costs, and shipping. Produces
  a professional quote document ready for customer delivery.
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
echo '{"skill":"reva-turbo-rfq-quote","ts":"'$(date -u +%Y-%m-%dT%H:%M:%SZ)'"}' >> ~/.reva-turbo/analytics/skill-usage.jsonl 2>/dev/null || true
```

## Purpose

Generate a complete, customer-facing quote package for Rev A Manufacturing. This skill calculates costs, applies margins, estimates lead times, and produces a professional quote document.

## Prerequisites

This skill expects a qualified RFQ from `reva-turbo-rfq-qualify`. The qualification decision should be PROCEED or CONDITIONAL (with conditions addressed). If no qualification record exists, warn the PM:

> This RFQ has not been through the qualification gate. Proceeding with quoting without qualification may result in capacity or capability issues downstream.
> A) Run qualification first
> B) Skip qualification and proceed with quoting

## Flow

### Step 1: Gather Cost Inputs

Collect or calculate the following cost components. Reference `references/cost-estimation.md` for estimation guidelines.

**Material cost:**
- Material type and grade
- Estimated weight per part
- Current material pricing (ask PM for supplier quotes if available)
- Material waste/scrap factor (typically 10-20% for machining, 2-5% for molding)

**Manufacturing cost:**
- Process type and estimated cycle time
- Machine/labor rate from China partner
- Setup charges
- Number of operations

**Tooling cost (if applicable):**
- Mold cost (injection molding)
- Fixture cost (machining)
- Custom tooling requirements
- Reference `references/tooling-costs.md`

**Finishing cost:**
- Finish type and process
- Cost per part or per batch

**Assembly cost (if applicable):**
- Number of components
- Assembly time per unit
- Hardware and consumables

**Quality/inspection cost:**
- Inspection requirements (FAIR, PPAP, dimensional report)
- Testing requirements
- Certification documentation

Ask the PM for any cost inputs not derivable from the RFQ data:

> I need the following cost inputs to generate the quote. Please provide what you have:
>
> 1. China partner pricing (per-part cost if available): ___
> 2. Tooling quote from partner (if applicable): ___
> 3. Material pricing source: ___
> 4. Shipping preference (ocean/air): ___
> 5. Any cost notes or adjustments: ___

### Step 2: Cost Estimation

Calculate the total cost per unit and per order. Use the estimation framework from `references/cost-estimation.md`.

**Cost buildup:**

| Cost Element | Per Unit | Extended (Qty: {{QUANTITY}}) |
|-------------|---------|------------------------------|
| Material | ${{MATERIAL_COST_UNIT}} | ${{MATERIAL_COST_EXT}} |
| Manufacturing | ${{MFG_COST_UNIT}} | ${{MFG_COST_EXT}} |
| Finishing | ${{FINISH_COST_UNIT}} | ${{FINISH_COST_EXT}} |
| Assembly | ${{ASSEMBLY_COST_UNIT}} | ${{ASSEMBLY_COST_EXT}} |
| Quality/Inspection | ${{QUALITY_COST_UNIT}} | ${{QUALITY_COST_EXT}} |
| **Subtotal (COGS)** | **${{COGS_UNIT}}** | **${{COGS_EXT}}** |
| Tooling (NRE) | — | ${{TOOLING_COST}} |
| Shipping | — | ${{SHIPPING_COST}} |
| **Total Cost** | — | **${{TOTAL_COST}}** |

### Step 3: Margin Calculation

Apply margins per `references/margin-guidelines.md`.

**Margin targets:**

| Factor | Margin Range |
|--------|-------------|
| Standard parts | 25-35% |
| Complex/precision parts | 30-40% |
| Prototype/low volume | 35-50% |
| Repeat/production orders | 20-30% |
| Strategic account (volume commitment) | 18-25% |

Calculate the quoted price:

| Element | Value |
|---------|-------|
| COGS per unit | ${{COGS_UNIT}} |
| Target margin | {{TARGET_MARGIN}}% |
| Quoted price per unit | ${{QUOTED_PRICE_UNIT}} |
| Extended price (Qty: {{QUANTITY}}) | ${{QUOTED_PRICE_EXT}} |
| Tooling (NRE) | ${{TOOLING_QUOTED}} |
| Shipping estimate | ${{SHIPPING_QUOTED}} |
| **Total quote** | **${{TOTAL_QUOTE}}** |

If the customer provided a target price, compare:

> **Target price comparison:**
> Customer target: ${{TARGET_PRICE}} per unit
> Our quoted price: ${{QUOTED_PRICE_UNIT}} per unit
> Delta: {{PRICE_DELTA}}% [above/below] target
>
> {{PRICE_COMMENTARY}}

### Step 4: Lead Time Calculation

Estimate the total lead time from order receipt to customer delivery. Reference `references/lead-time-matrix.md`.

| Phase | Duration |
|-------|----------|
| Order processing | {{ORDER_PROCESSING_TIME}} |
| Tooling (if new) | {{TOOLING_TIME}} |
| Manufacturing | {{MFG_TIME}} |
| Finishing | {{FINISH_TIME}} |
| Shipping (China to US) | {{SHIPPING_TIME}} |
| Customs clearance | {{CUSTOMS_TIME}} |
| Incoming inspection | {{INSPECTION_TIME}} |
| Repackaging | {{REPACK_TIME}} |
| Domestic shipping | {{DOMESTIC_SHIP_TIME}} |
| **Total lead time** | **{{TOTAL_LEAD_TIME}}** |

Compare to customer requested delivery:

> Customer requested: {{DELIVERY_TIMELINE}}
> Estimated delivery: {{ESTIMATED_DELIVERY_DATE}}
> {{LEAD_TIME_COMMENTARY}}

### Step 5: Shipping Estimate

Calculate shipping costs per `references/shipping-estimates.md`.

| Method | Estimated Cost | Transit Time |
|--------|---------------|-------------|
| Ocean freight | ${{OCEAN_COST}} | {{OCEAN_TIME}} |
| Air freight | ${{AIR_COST}} | {{AIR_TIME}} |
| Domestic (to customer) | ${{DOMESTIC_COST}} | {{DOMESTIC_TIME}} |

### Step 6: Quote Assembly

**HUMAN-IN-THE-LOOP CHECKPOINT:**

Present the complete quote summary for PM review:

> ## Quote Summary for {{CUSTOMER_COMPANY}}
>
> **Part:** {{PART_DESCRIPTION}}
> **Quantity:** {{QUANTITY}}
>
> | Line Item | Amount |
> |-----------|--------|
> | Unit price | ${{QUOTED_PRICE_UNIT}} |
> | Extended price | ${{QUOTED_PRICE_EXT}} |
> | Tooling (NRE) | ${{TOOLING_QUOTED}} |
> | Shipping | ${{SHIPPING_QUOTED}} |
> | **Total** | **${{TOTAL_QUOTE}}** |
>
> **Margin:** {{ACTUAL_MARGIN}}%
> **Lead time:** {{TOTAL_LEAD_TIME}}
> **Quote validity:** 30 days
>
> A) Approve — generate the quote document
> B) Adjust pricing (tell me what to change)
> C) Adjust lead time or terms
> D) Cancel — do not generate quote

If B, ask for specific adjustments and recalculate.

### Step 7: Generate Quote Document

Use `templates/Quote Package.md` to generate the customer-facing quote document. Fill all `{{PLACEHOLDER}}` variables.

Generate a quote number:

```bash
_QUOTE_NUM="QT-$(date +%Y%m%d)-$(printf '%03d' $((RANDOM % 999 + 1)))"
echo "$_QUOTE_NUM"
```

Save the quote package:

```bash
mkdir -p ~/.reva-turbo/rfqs/{{RFQ_ID}}
```

### Step 8: Save and Route

Log the workflow transition:

```bash
echo '{"ts":"'$(date -u +%Y-%m-%dT%H:%M:%SZ)'","rfq_id":"{{RFQ_ID}}","customer":"{{CUSTOMER_COMPANY}}","stage":"reva-turbo-rfq-quote","status":"complete","quote_number":"{{QUOTE_NUMBER}}","total":"{{TOTAL_QUOTE}}","pm":"{{ASSIGNED_PM}}","next_suggested":"reva-turbo-customer-comms"}' >> ~/.reva-turbo/state/workflow-state.jsonl 2>/dev/null || true
```

Suggest the next step:

> Quote {{QUOTE_NUMBER}} generated for {{CUSTOMER_COMPANY}} — total ${{TOTAL_QUOTE}}.
> Next step: **Send quote to customer** (reva-turbo-customer-comms). Want me to draft the quote submission email?

## Report Naming

```
REVA-TURBO-Quote-{YYYY-MM-DD}-{CustomerShortName}.md
```

## Template References

- `prompts/quoting-system.md` — System prompt for quoting logic
- `prompts/quoting-user-template.md` — Quoting input template
- `references/cost-estimation.md` — Cost estimation framework
- `references/margin-guidelines.md` — Margin targets and rules
- `references/tooling-costs.md` — Tooling cost reference
- `references/lead-time-matrix.md` — Lead time by process and volume
- `references/shipping-estimates.md` — Shipping cost and time estimates
- `templates/Quote Package.md` — Customer-facing quote template
