---
name: reva-turbo-order-track
preamble-tier: 2
version: 1.0.0
description: |
  Full order lifecycle tracking through 12 stages from PO Received to Closed.
  Tracks manufacturing in China, international shipping, inspection at Rev A,
  repackaging, domestic shipping, and delivery. Manages delays, status updates,
  and stage transitions with full audit trail.
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
echo '{"skill":"reva-turbo-order-track","ts":"'$(date -u +%Y-%m-%dT%H:%M:%SZ)'"}' >> ~/.reva-turbo/analytics/skill-usage.jsonl 2>/dev/null || true
```

## Purpose

Track every order through its complete lifecycle at Rev A Manufacturing. Each order moves through 12 defined stages. The PM must be able to see current status, advance stages, flag delays, and generate status reports at any time.

## Flow

### Step 1: Identify Order

Determine which order the PM wants to track. Ask if not clear:

> Which order do you want to track?
> A) Look up by PO number
> B) Look up by customer name
> C) Show all active orders
> D) Create a new order tracking record

If creating new, proceed to Step 2. If looking up, search:

```bash
cat ~/.reva-turbo/orders/*/order-state.jsonl 2>/dev/null | grep -i "{{SEARCH_TERM}}" | tail -20
```

### Step 2: New Order Initialization

For a new order, collect required information:

- **PO Number:** {{PO_NUMBER}}
- **Customer:** {{CUSTOMER_COMPANY}}
- **Contact:** {{CONTACT_NAME}} / {{CONTACT_EMAIL}}
- **Part(s):** {{PART_DESCRIPTION}}
- **Quantity:** {{QUANTITY}}
- **Quoted Price:** {{QUOTED_PRICE}}
- **Manufacturing Partner:** {{MFG_PARTNER}} (China supplier)
- **Expected Ship Date (from China):** {{EXPECTED_SHIP_DATE}}
- **Customer Delivery Date:** {{CUSTOMER_DELIVERY_DATE}}
- **Routing:** {{ROUTING_TYPE}} (direct-to-customer or inspect-and-forward)
- **Assigned PM:** {{ASSIGNED_PM}}

Initialize order state:

```bash
mkdir -p ~/.reva-turbo/orders/{{PO_NUMBER}}
echo '{"ts":"'$(date -u +%Y-%m-%dT%H:%M:%SZ)'","po":"{{PO_NUMBER}}","customer":"{{CUSTOMER_COMPANY}}","stage":"01-po-received","status":"active","pm":"{{ASSIGNED_PM}}","routing":"{{ROUTING_TYPE}}"}' >> ~/.reva-turbo/orders/{{PO_NUMBER}}/order-state.jsonl
```

### Step 3: Stage Management

Reference `references/order-stages.md` for the complete 12-stage pipeline. Each stage transition requires:

1. **Verification** — Confirm the previous stage is complete
2. **Timestamp** — Record when the transition happened
3. **Evidence** — Note what triggered the transition (email, tracking update, inspection report)
4. **Next expected date** — When the next stage should complete

Log every transition:

```bash
echo '{"ts":"'$(date -u +%Y-%m-%dT%H:%M:%SZ)'","po":"{{PO_NUMBER}}","from_stage":"{{PREVIOUS_STAGE}}","to_stage":"{{NEW_STAGE}}","triggered_by":"{{TRIGGER}}","next_expected":"{{NEXT_EXPECTED_DATE}}","pm":"{{ASSIGNED_PM}}"}' >> ~/.reva-turbo/orders/{{PO_NUMBER}}/order-state.jsonl
```

**HUMAN-IN-THE-LOOP CHECKPOINT:**

Before advancing any stage, confirm with the PM:

> Advancing **{{PO_NUMBER}}** from **{{PREVIOUS_STAGE_NAME}}** to **{{NEW_STAGE_NAME}}**.
> Trigger: {{TRIGGER}}
>
> A) Confirm — advance the stage
> B) Not yet — keep current stage
> C) Flag a delay on this order

### Step 4: Delay Management

Reference `references/delay-management.md` for delay procedures. When a delay is flagged:

1. Record the delay with reason and revised timeline
2. Calculate impact on customer delivery date
3. Determine if escalation is needed (delay > 2 weeks triggers reva-turbo-escalate)
4. Draft customer communication if delivery date is affected

```bash
echo '{"ts":"'$(date -u +%Y-%m-%dT%H:%M:%SZ)'","po":"{{PO_NUMBER}}","event":"delay","stage":"{{CURRENT_STAGE}}","reason":"{{DELAY_REASON}}","original_date":"{{ORIGINAL_DATE}}","revised_date":"{{REVISED_DATE}}","days_delayed":{{DAYS_DELAYED}},"escalation_required":{{ESCALATION_BOOL}}}' >> ~/.reva-turbo/orders/{{PO_NUMBER}}/order-state.jsonl
```

If escalation is required:

> **Escalation Required:** This delay of {{DAYS_DELAYED}} days exceeds the 2-week threshold. Recommend running reva-turbo-escalate. Proceed?

### Step 5: Status Report Generation

Use the template from `templates/Order Status Report.md` to generate a formatted status report for the current order. Reference `references/status-codes.md` for status code definitions.

### Step 6: Audit Trail

Every action in this skill is logged to the order's state file. Additionally, log to the global audit trail:

```bash
echo '{"ts":"'$(date -u +%Y-%m-%dT%H:%M:%SZ)'","skill":"reva-turbo-order-track","po":"{{PO_NUMBER}}","action":"{{ACTION}}","pm":"{{ASSIGNED_PM}}","detail":"{{DETAIL}}"}' >> ~/.reva-turbo/state/audit-trail.jsonl 2>/dev/null || true
```

## Report Naming

Save order status reports as:
```
REVA-TURBO-OrderStatus-{YYYY-MM-DD}-{PO_NUMBER}.md
```

## Template References

- `prompts/order-tracking-system.md` — System prompt for order tracking logic
- `prompts/order-tracking-user-template.md` — User interaction template
- `references/order-stages.md` — 12-stage pipeline definition
- `references/status-codes.md` — Status code reference
- `references/delay-management.md` — Delay handling procedures
- `templates/Order Status Report.md` — Status report output template
