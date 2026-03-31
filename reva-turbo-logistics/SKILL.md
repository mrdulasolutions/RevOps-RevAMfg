---
name: reva-turbo-logistics
preamble-tier: 2
version: 1.0.0
description: |
  Shipping and logistics coordination for Rev A Manufacturing. Manages
  international shipping (China to Rev A) and domestic shipping (Rev A to customer).
  Handles routing decisions (direct-to-customer vs inspect-and-forward),
  carrier selection, customs documentation, and shipment tracking.
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
echo '{"skill":"reva-turbo-logistics","ts":"'$(date -u +%Y-%m-%dT%H:%M:%SZ)'"}' >> ~/.reva-turbo/analytics/skill-usage.jsonl 2>/dev/null || true
```

## Purpose

Coordinate all shipping and logistics for Rev A Manufacturing orders. This includes international freight from China manufacturing partners, customs clearance, and domestic delivery to end customers. The key decision point is routing: direct-to-customer vs inspect-and-forward through the Rev A facility.

## Flow

### Step 1: Shipment Identification

Determine which order requires logistics coordination:

> What logistics action do you need?
> A) Set up international shipment (China to Rev A / customer)
> B) Set up domestic shipment (Rev A to customer)
> C) Check shipment status
> D) Handle a shipping exception
> E) Review routing decision for an order

### Step 2: Routing Decision

Reference `references/routing-logic.md` for the decision matrix. For new orders, evaluate:

1. **Order value** — High-value orders (>$25K) default to inspect-and-forward
2. **Customer relationship** — New customers default to inspect-and-forward
3. **Product complexity** — Custom/tight-tolerance parts default to inspect-and-forward
4. **Partner score** — Partners rated B or below default to inspect-and-forward
5. **Customer request** — Customer may specify direct ship preference
6. **Regulatory** — Certain products require Rev A inspection for compliance

**HUMAN-IN-THE-LOOP CHECKPOINT:**

> **Routing Recommendation for {{PO_NUMBER}}:**
>
> Based on the decision matrix:
> - Order Value: {{ORDER_VALUE}} ({{VALUE_THRESHOLD}})
> - Customer Type: {{CUSTOMER_TYPE}} ({{CUSTOMER_THRESHOLD}})
> - Product Complexity: {{COMPLEXITY}} ({{COMPLEXITY_THRESHOLD}})
> - Partner Score: {{PARTNER_SCORE}} ({{PARTNER_THRESHOLD}})
>
> **Recommended Routing: {{RECOMMENDED_ROUTING}}**
>
> A) Accept recommendation
> B) Override to direct-to-customer
> C) Override to inspect-and-forward

### Step 3: Shipping Mode Selection

Reference `references/shipping-modes.md` to select the appropriate mode:

| Mode | Transit Time | Cost Level | Use When |
|------|-------------|------------|----------|
| Air Express | 3-5 days | Highest | Urgent/expedited orders |
| Air Freight | 5-7 days | High | Time-sensitive, moderate volume |
| Sea (FCL) | 25-35 days | Low | Full container, cost-sensitive |
| Sea (LCL) | 30-40 days | Medium-Low | Partial container |
| Sea + Air (Split) | Varies | Medium | Partial urgent, balance by sea |

### Step 4: Carrier Selection

Reference `references/freight-carriers.md` for approved carriers. Select based on:

- Shipping mode
- Origin/destination
- Cargo type and weight
- Cost quotation
- Historical reliability

### Step 5: Customs Documentation

Reference `references/customs-docs.md` for required documentation. Generate a customs documentation checklist using `templates/Customs Documentation Checklist.md`.

Required for all China imports:
- Commercial Invoice
- Packing List
- Bill of Lading / Air Waybill
- Customs Entry Form (CBP 7501)
- HTS Classification
- Country of Origin Certificate
- ISF (Importer Security Filing) for ocean shipments

### Step 6: Shipment Coordination

Use `templates/Shipping Coordination.md` to generate the coordination document. Log the shipment:

```bash
mkdir -p ~/.reva-turbo/shipments
echo '{"ts":"'$(date -u +%Y-%m-%dT%H:%M:%SZ)'","po":"{{PO_NUMBER}}","type":"{{SHIP_TYPE}}","mode":"{{SHIPPING_MODE}}","carrier":"{{CARRIER}}","tracking":"{{TRACKING_NUMBER}}","origin":"{{ORIGIN}}","destination":"{{DESTINATION}}","etd":"{{ETD}}","eta":"{{ETA}}","routing":"{{ROUTING_TYPE}}"}' >> ~/.reva-turbo/shipments/shipment-log.jsonl
```

### Step 7: Exception Handling

When a shipping exception occurs:

1. Log the exception with details
2. Assess impact on delivery date
3. Determine corrective action
4. Notify PM and customer if delivery date is affected
5. Trigger escalation if delay exceeds threshold

```bash
echo '{"ts":"'$(date -u +%Y-%m-%dT%H:%M:%SZ)'","po":"{{PO_NUMBER}}","event":"shipping_exception","type":"{{EXCEPTION_TYPE}}","detail":"{{EXCEPTION_DETAIL}}","impact_days":{{IMPACT_DAYS}}}' >> ~/.reva-turbo/shipments/shipment-log.jsonl
```

## Report Naming

Save shipping coordination documents as:
```
REVA-TURBO-Shipping-{YYYY-MM-DD}-{PO_NUMBER}.md
```

## Template References

- `prompts/logistics-system.md` — System prompt for logistics coordination
- `prompts/logistics-user-template.md` — User interaction template
- `references/shipping-modes.md` — Air/sea/ground mode details
- `references/customs-docs.md` — Customs documentation requirements
- `references/routing-logic.md` — Direct vs inspect-forward decision matrix
- `references/freight-carriers.md` — Approved carrier list
- `templates/Shipping Coordination.md` — Shipment coordination document
- `templates/Customs Documentation Checklist.md` — Customs docs checklist
