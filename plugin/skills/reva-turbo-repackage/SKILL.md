---
name: reva-turbo-repackage
preamble-tier: 2
version: 1.0.0
description: |
  Repackaging workflow for inspect-and-forward routing at Rev A Manufacturing.
  Manages work order creation, labeling requirements, packaging specifications,
  and completion tracking for products received from China partners.
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
echo '{"skill":"reva-turbo-repackage","ts":"'$(date -u +%Y-%m-%dT%H:%M:%SZ)'"}' >> ~/.reva-turbo/analytics/skill-usage.jsonl 2>/dev/null || true
```

## Purpose

Manage the repackaging workflow when products arrive at Rev A Manufacturing from China partners under the inspect-and-forward routing. This skill creates work orders, tracks repackaging progress, ensures labeling compliance, and advances the order to the shipping stage upon completion.

## Flow

### Step 1: Work Order Initiation

A repackaging work order is initiated after inspection is complete (Stage 08 passed). Collect the following:

- **PO Number:** {{PO_NUMBER}}
- **Customer:** {{CUSTOMER_COMPANY}}
- **Part Description:** {{PART_DESCRIPTION}}
- **Quantity:** {{QUANTITY}}
- **Inspection Status:** {{INSPECTION_STATUS}} (must be PASS or QC-MINOR with rework complete)
- **Customer Packaging Requirements:** {{PACKAGING_REQUIREMENTS}}
- **Labeling Requirements:** {{LABELING_REQUIREMENTS}}
- **Special Instructions:** {{SPECIAL_INSTRUCTIONS}}
- **Target Completion Date:** {{TARGET_DATE}}

### Step 2: Packaging Requirements Review

Reference `references/repackaging-procedures.md` for standard procedures. Determine:

1. **Packaging type** — Standard carton, custom box, crate, pallet
2. **Inner packaging** — Bubble wrap, foam insert, anti-static bag, VCI wrap
3. **Customer-specific requirements** — Custom labels, branded packaging, specific box sizes
4. **Hazmat packaging** — If applicable, per DOT/IATA requirements

**HUMAN-IN-THE-LOOP CHECKPOINT:**

> **Repackaging Plan for {{PO_NUMBER}}:**
>
> Packaging: {{PACKAGING_TYPE}}
> Inner Protection: {{INNER_PACKAGING}}
> Labeling: {{LABELING_TYPE}}
> Customer Requirements: {{CUSTOMER_REQUIREMENTS}}
> Estimated Time: {{EST_TIME}}
>
> A) Approve and generate work order
> B) Modify packaging plan
> C) Hold — need clarification from customer

### Step 3: Labeling

Reference `references/labeling-requirements.md` for all labeling standards. Every repackaged product must have:

1. **Product label** — Part number, description, quantity, Rev A lot number
2. **Shipping label** — Customer address, PO reference, handling instructions
3. **Country of origin** — "Made in China" or appropriate origin marking
4. **Customer-specific labels** — As specified in PO or customer requirements
5. **Regulatory labels** — If product requires safety, hazmat, or compliance labels

### Step 4: Work Order Generation

Generate the work order using `templates/Repackaging Work Order.md`. Log the work order:

```bash
mkdir -p ~/.reva-turbo/orders/{{PO_NUMBER}}
echo '{"ts":"'$(date -u +%Y-%m-%dT%H:%M:%SZ)'","po":"{{PO_NUMBER}}","event":"repackage_wo_created","packaging":"{{PACKAGING_TYPE}}","labeling":"{{LABELING_TYPE}}","target_date":"{{TARGET_DATE}}","pm":"{{ASSIGNED_PM}}"}' >> ~/.reva-turbo/orders/{{PO_NUMBER}}/order-state.jsonl
```

### Step 5: Completion and Stage Advancement

When repackaging is complete:

1. Verify all items are repackaged per work order
2. Verify all labels are applied correctly
3. Record completion:

```bash
echo '{"ts":"'$(date -u +%Y-%m-%dT%H:%M:%SZ)'","po":"{{PO_NUMBER}}","event":"repackage_complete","completed_by":"{{COMPLETED_BY}}","packages":"{{NUM_PACKAGES}}","ready_for_ship":true}' >> ~/.reva-turbo/orders/{{PO_NUMBER}}/order-state.jsonl
```

4. Advance order to Stage 09 (Repackaged) in reva-turbo-order-track
5. Suggest next step: set up domestic shipment via reva-turbo-logistics

> Repackaging complete for {{PO_NUMBER}} ({{CUSTOMER_COMPANY}}). {{NUM_PACKAGES}} packages ready for shipment.
> Next step: Set up domestic shipping via reva-turbo-logistics. Proceed?

## Report Naming

Save repackaging work orders as:
```
REVA-TURBO-Repackage-{YYYY-MM-DD}-{PO_NUMBER}.md
```

## Template References

- `prompts/repackage-system.md` — System prompt for repackaging logic
- `prompts/repackage-user-template.md` — User interaction template
- `references/repackaging-procedures.md` — Standard repackaging procedures
- `references/labeling-requirements.md` — Labeling standards and requirements
- `templates/Repackaging Work Order.md` — Work order template
