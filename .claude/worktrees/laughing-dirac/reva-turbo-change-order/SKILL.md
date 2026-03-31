---
name: reva-turbo-change-order
preamble-tier: 1
version: 1.0.0
description: |
  Mid-stream change management for Rev A Manufacturing. When a customer requests
  a change to an in-progress order, this skill calculates full impact (cost,
  time, tooling, quality, partner, logistics), gets PM approval, cascades the
  change through all downstream skills, and notifies all affected parties.
  Replaces email chains and spreadsheet tracking for change orders.
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
echo '{"skill":"reva-turbo-change-order","ts":"'$(date -u +%Y-%m-%dT%H:%M:%SZ)'"}' >> ~/.reva-turbo/analytics/skill-usage.jsonl 2>/dev/null || true
```

## Purpose

Manage mid-stream changes to in-progress orders. Calculate full impact across cost, lead time, tooling, quality, partner operations, and logistics. Get PM approval with complete visibility. Cascade approved changes through all downstream REVA-TURBO skills. Maintain full audit trail with revision control.

## Flow

### Step 1 — Change Request Intake

Collect the change request details. Load the existing order first:

```bash
cat ~/.reva-turbo/state/orders/{{ORDER_ID}}.yaml 2>/dev/null || echo "Order not found."
```

**Change Order Number Format:** `CO-{{ORDER_ID}}-{{SEQ}}` (e.g., CO-ORD-2026-0142-01)

| Field | Required | Source |
|-------|----------|--------|
| Order ID | Yes | PM input |
| Change type | Yes | PM input (see change types below) |
| Original value | Auto | Loaded from order record |
| New value | Yes | PM input |
| Reason for change | Yes | PM input |
| Urgency | Yes | PM input (standard / urgent / critical) |
| Customer approved price change? | If applicable | PM input (yes / no / pending) |
| Requested by | Yes | PM input (customer / internal / partner) |

**Change types:**
- Quantity increase / decrease
- Material change
- Tolerance tightened / loosened
- Finish change
- Design revision (new drawing)
- Delivery date moved earlier / later
- Add operation
- Remove operation
- Packaging change
- Shipping method change

Reference `prompts/change-order-user-template.md` for input variables.

### Step 2 — Impact Analysis

Reference `references/impact-matrix.md` for what each change type affects. Reference `references/change-policies.md` for business rules.

Calculate impact across all six dimensions:

#### 2a. Cost Impact

Recalculate the quote with new parameters:

| Line Item | Original | Revised | Delta |
|-----------|----------|---------|-------|
| Material cost | {{ORIG_MATERIAL}} | {{NEW_MATERIAL}} | {{DELTA_MATERIAL}} |
| Tooling cost | {{ORIG_TOOLING}} | {{NEW_TOOLING}} | {{DELTA_TOOLING}} |
| Manufacturing cost | {{ORIG_MFG}} | {{NEW_MFG}} | {{DELTA_MFG}} |
| Finishing cost | {{ORIG_FINISH}} | {{NEW_FINISH}} | {{DELTA_FINISH}} |
| Inspection cost | {{ORIG_INSPECT}} | {{NEW_INSPECT}} | {{DELTA_INSPECT}} |
| Shipping cost | {{ORIG_SHIP}} | {{NEW_SHIP}} | {{DELTA_SHIP}} |
| Change fee | $0 | {{CHANGE_FEE}} | {{CHANGE_FEE}} |
| Scrap cost | $0 | {{SCRAP_COST}} | {{SCRAP_COST}} |
| **Total** | **{{ORIG_TOTAL}}** | **{{NEW_TOTAL}}** | **{{DELTA_TOTAL}}** |

Change fee rules (from `references/change-policies.md`):
- Before manufacturing starts: **no change fee**
- During tooling: change fee = cost of tooling modification
- During production: change fee + potential scrap cost for completed units
- After QC passed: full restart cost

#### 2b. Lead Time Impact

| Milestone | Original Date | Revised Date | Delta |
|-----------|--------------|-------------|-------|
| Tooling complete | {{ORIG_TOOL_DATE}} | {{NEW_TOOL_DATE}} | {{DELTA_TOOL}} |
| First article | {{ORIG_FA_DATE}} | {{NEW_FA_DATE}} | {{DELTA_FA}} |
| Production complete | {{ORIG_PROD_DATE}} | {{NEW_PROD_DATE}} | {{DELTA_PROD}} |
| QC/Inspection | {{ORIG_QC_DATE}} | {{NEW_QC_DATE}} | {{DELTA_QC}} |
| Ship date | {{ORIG_SHIP_DATE}} | {{NEW_SHIP_DATE}} | {{DELTA_SHIP_DATE}} |
| Delivery date | {{ORIG_DELIVERY}} | {{NEW_DELIVERY}} | {{DELTA_DELIVERY}} |

#### 2c. Tooling Impact

> **Tooling Assessment:**
>
> Current tooling status: {{TOOLING_STATUS}}
> Tooling modification required: {{TOOLING_MOD_REQUIRED}} (Yes/No)
> New tooling required: {{NEW_TOOLING_REQUIRED}} (Yes/No)
> Tooling cost: {{TOOLING_COST}}
> Tooling lead time: {{TOOLING_LEAD_TIME}}
>
> Details: {{TOOLING_DETAILS}}

#### 2d. Quality Impact

> **Quality Assessment:**
>
> Inspection criteria change: {{INSPECTION_CHANGE}} (Yes/No)
> New measurements required: {{NEW_MEASUREMENTS}}
> CMM program update needed: {{CMM_UPDATE}} (Yes/No)
> Updated inspection checklist items: {{UPDATED_CHECKLIST}}

#### 2e. Partner Impact

> **Partner Assessment:**
>
> Current production stage: {{PARTNER_STAGE}}
> Partner notification required: {{PARTNER_NOTIFY}} (Yes/No)
> Work already completed: {{WORK_COMPLETED}}
> Work that must be redone: {{WORK_REDO}}
> Partner cost impact: {{PARTNER_COST_IMPACT}}

#### 2f. Logistics Impact

> **Logistics Assessment:**
>
> Weight change: {{WEIGHT_CHANGE}}
> Dimensions change: {{DIMS_CHANGE}}
> Customs classification change: {{CUSTOMS_CHANGE}} (Yes/No)
> Shipping method change required: {{SHIPPING_CHANGE}} (Yes/No)
> Shipping cost delta: {{SHIPPING_DELTA}}

### Step 3 — PM Decision Gate

Present the complete impact summary for PM decision. Use `templates/Change Impact Summary.md`.

> **CHANGE ORDER IMPACT SUMMARY**
>
> Change Order: {{CO_NUMBER}}
> Order: {{ORDER_ID}} — {{CUSTOMER}} — {{PART_NAME}}
> Change: {{CHANGE_TYPE}} ({{ORIGINAL_VALUE}} -> {{NEW_VALUE}})
> Requested by: {{REQUESTED_BY}}
> Reason: {{REASON}}
>
> | Impact | Summary |
> |--------|---------|
> | Cost | {{COST_SUMMARY}} ({{DELTA_TOTAL}}) |
> | Lead Time | {{TIME_SUMMARY}} ({{DELTA_DELIVERY}}) |
> | Tooling | {{TOOLING_SUMMARY}} |
> | Quality | {{QUALITY_SUMMARY}} |
> | Partner | {{PARTNER_SUMMARY}} |
> | Logistics | {{LOGISTICS_SUMMARY}} |
>
> **Recommendation:** {{RECOMMENDATION}}
>
> **A) Approve change order**
> **B) Reject change order**
> **C) Approve with modifications**
> **D) Request more analysis**

**HUMAN-IN-THE-LOOP:** PM must explicitly approve or reject. No changes are cascaded without PM approval.

### Step 4 — Customer Communication

If approved and cost/timeline changed, draft communication to customer:

**Price increase scenario:**
> Subject: Change Order {{CO_NUMBER}} — Revised Pricing for {{ORDER_ID}}
>
> Dear {{CUSTOMER_CONTACT}},
>
> Per your requested change to [change description], we have completed our
> impact analysis. The revised pricing and timeline are as follows:
>
> [Impact table]
>
> Please confirm your approval to proceed with the revised terms.

**Price decrease scenario:**
> Subject: Change Order {{CO_NUMBER}} — Updated Pricing for {{ORDER_ID}}
>
> Dear {{CUSTOMER_CONTACT}},
>
> Good news — the change you requested results in a cost reduction.
>
> [Impact table]
>
> We will proceed with the updated specifications.

**No cost change scenario:**
> Subject: Change Order {{CO_NUMBER}} — Confirmed for {{ORDER_ID}}
>
> Dear {{CUSTOMER_CONTACT}},
>
> We have incorporated your requested change at no additional cost.
>
> [Updated specs]

Reference `prompts/change-order-system.md` for communication tone guidelines.

Route through `/reva-turbo-customer-comms` for sending.

### Step 5 — Partner Notification

If manufacturing is in progress and partner is affected:

> Subject: Engineering Change Notice — {{ORDER_ID}} / {{CO_NUMBER}}
>
> [Partner name],
>
> Please note the following change to order {{ORDER_ID}}:
>
> Change: {{CHANGE_DESCRIPTION}}
> Updated spec/drawing: [attached]
> Impact on your work: {{PARTNER_IMPACT}}
> Revised delivery date: {{NEW_DELIVERY}}
>
> Please confirm receipt and your updated production schedule.

Route through `/reva-turbo-customer-comms` (partner mode).

### Step 6 — Cascade Updates

Automatically update all affected REVA-TURBO records:

| Record | Update Action | Skill |
|--------|-------------|-------|
| Quote | Revise with new pricing, mark as "Revised" | `/reva-turbo-rfq-quote` |
| Order | Update specs, timeline, revision level | `/reva-turbo-order-track` |
| China-track | Adjust milestones per new timeline | `/reva-turbo-china-track` |
| Inspection | Update checklist with new criteria | `/reva-turbo-inspect` |
| Logistics | Update shipping plan (weight, dims, dates) | `/reva-turbo-logistics` |
| Customer profile | Log change order in activity history | `/reva-turbo-customer-profile` |
| Partner scorecard | Log change event (partner-initiated only) | `/reva-turbo-partner-scorecard` |
| Audit trail | Full change order record | `/reva-turbo-audit-trail` |

Each cascade update is logged:

```bash
echo '{"ts":"'$(date -u +%Y-%m-%dT%H:%M:%SZ)'","co_number":"{{CO_NUMBER}}","cascade":"{{TARGET_SKILL}}","entity":"{{ENTITY_ID}}","action":"{{UPDATE_ACTION}}","status":"success"}' >> ~/.reva-turbo/state/change-order-log.jsonl
```

### Step 7 — Audit Trail

Log the complete change order:

```bash
mkdir -p ~/.reva-turbo/state
echo '{"ts":"'$(date -u +%Y-%m-%dT%H:%M:%SZ)'","co_number":"{{CO_NUMBER}}","order_id":"{{ORDER_ID}}","customer":"{{CUSTOMER}}","change_type":"{{CHANGE_TYPE}}","original_value":"{{ORIGINAL_VALUE}}","new_value":"{{NEW_VALUE}}","reason":"{{REASON}}","requested_by":"{{REQUESTED_BY}}","cost_delta":"{{DELTA_TOTAL}}","time_delta":"{{DELTA_DELIVERY}}","tooling_impact":"{{TOOLING_SUMMARY}}","decision":"{{DECISION}}","decided_by":"{{PM_NAME}}","revision":"{{REVISION}}"}' >> ~/.reva-turbo/state/change-order-log.jsonl
```

Also log in the main audit trail:

```bash
echo '{"ts":"'$(date -u +%Y-%m-%dT%H:%M:%SZ)'","type":"change_order","ref":"{{ORDER_ID}}","customer":"{{CUSTOMER}}","action":"Change order {{CO_NUMBER}}: {{CHANGE_TYPE}} — {{DECISION}}","justification":"{{REASON}}","pm":"{{PM_NAME}}","skill":"reva-turbo-change-order"}' >> ~/.reva-turbo/state/audit-trail.jsonl
```

### Step 8 — Change Order Numbering

Format: `CO-{ORDER_ID}-{SEQ}`

Examples:
- `CO-ORD-2026-0142-01` — first change to order ORD-2026-0142
- `CO-ORD-2026-0142-02` — second change to same order
- `CO-ORD-2026-0142-03` — third change (triggers re-quote warning)

Sequence is auto-incremented:

```bash
LAST_SEQ=$(grep '"order_id":"{{ORDER_ID}}"' ~/.reva-turbo/state/change-order-log.jsonl 2>/dev/null | wc -l | tr -d ' ')
NEXT_SEQ=$(printf "%02d" $((LAST_SEQ + 1)))
CO_NUMBER="CO-{{ORDER_ID}}-${NEXT_SEQ}"
```

**Policy check:** If `NEXT_SEQ > 3`, warn PM:

> **Warning:** This is change order #{{NEXT_SEQ}} for {{ORDER_ID}}.
> Per Rev A policy, orders with more than 3 change orders require a full re-quote.
>
> A) Proceed with change order anyway
> B) Initiate full re-quote via `/reva-turbo-rfq-quote`

### Step 9 — Revision Control

Track the order version history:

| Revision | Date | Change | CO Number |
|----------|------|--------|-----------|
| Rev A | {{ORIG_DATE}} | Original order | — |
| Rev B | {{REV_B_DATE}} | {{REV_B_CHANGE}} | {{REV_B_CO}} |
| Rev C | {{REV_C_DATE}} | {{REV_C_CHANGE}} | {{REV_C_CO}} |

Current revision is stored in the order record and displayed on all documents.

### Step 10 — Generate Change Order Document

Build the formal change order document using `templates/Change Order.md`:

1. Fill all `{{PLACEHOLDER}}` variables
2. Include complete impact analysis
3. Include revision history
4. Name the file: `REVA-TURBO-CO-{{CO_NUMBER}}.md`

## Report Naming

```
REVA-TURBO-CO-{CO-NUMBER}.md
```

Example: `REVA-TURBO-CO-CO-ORD-2026-0142-01.md`

## State Tracking

Change order log: `~/.reva-turbo/state/change-order-log.jsonl`
Audit trail: `~/.reva-turbo/state/audit-trail.jsonl`

## References

- `prompts/change-order-system.md` — Impact analysis methodology, cost rules, communication tone
- `prompts/change-order-user-template.md` — Change request input variables
- `references/impact-matrix.md` — Change type to impact dimension mapping
- `references/change-policies.md` — Business rules for change fees and limits
- `templates/Change Order.md` — Full change order document template
- `templates/Change Impact Summary.md` — Quick PM decision summary
