---
name: reva-turbo-logistics
preamble-tier: 2
version: 1.0.0
description: |
  Shipping and logistics coordination for Rev A Manufacturing. Supports two
  primary flows: (1) Direct China→Customer — vendor ships directly to customer,
  Rev A handles import compliance and documentation remotely; (2) Inspect &
  Forward — goods route through Rev A for inspection before customer delivery.
  Direct flow is the default for qualified vendors and returning customers.
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

**Default flow is Direct China→Customer.** This is the preferred model — faster delivery, lower landed cost, no double-handling. Inspect-and-forward is the exception, not the rule.

Reference `references/routing-logic.md` for the decision matrix. Evaluate:

**Direct China→Customer qualifiers (recommend direct if ALL apply):**
1. Partner score is A or B (trusted vendor)
2. Returning customer (prior successful orders on record)
3. Pre-shipment inspection completed at factory (G1/G2 passed in China)
4. Product is non-ITAR, non-controlled
5. Customer has not requested Rev A inspection

**Inspect-and-forward triggers (override to I&F if ANY apply):**
1. New customer (no prior order history)
2. Partner score C or below
3. First production run of a new part or new vendor
4. Quality gate requires physical inspection at Rev A
5. Customer contract requires Rev A CoC (Certificate of Conformance)
6. Order value >$50K with no prior precedent
7. ITAR/controlled product requiring Rev A handling documentation

**HUMAN-IN-THE-LOOP CHECKPOINT:**

> **Routing Decision for {{PO_NUMBER}}**
>
> | Factor | Value | Signal |
> |--------|-------|--------|
> | Partner Score | {{PARTNER_SCORE}} | {{PARTNER_SIGNAL}} |
> | Customer Type | {{CUSTOMER_TYPE}} | {{CUSTOMER_SIGNAL}} |
> | Pre-ship Inspection | {{PSI_STATUS}} | {{PSI_SIGNAL}} |
> | Product Controls | {{CONTROL_STATUS}} | {{CONTROL_SIGNAL}} |
> | Order Value | {{ORDER_VALUE}} | {{VALUE_SIGNAL}} |
>
> **Recommended Routing: {{RECOMMENDED_ROUTING}}**
> {{ROUTING_RATIONALE}}
>
> A) **Direct China→Customer** — Vendor ships to customer. Rev A handles import docs remotely.
> B) **Inspect & Forward** — Goods route through Rev A before customer delivery.
> C) **Direct with Pre-Ship Inspection** — Rev A inspector (or 3rd party) inspects at factory, then direct ship.

### Direct China→Customer Flow

When routing is Direct:

1. **Consignee on shipment** = Customer name and address (not Rev A)
2. **Notify party** = Rev A Manufacturing (for import visibility)
3. **Importer of Record** = Rev A Manufacturing (Rev A remains responsible for import compliance)
4. **Rev A role** = Remote coordination — customs docs, duty payment, ISF filing, compliance clearance
5. **Partner instruction** = Generate `templates/Direct Ship Instructions.md` for the China vendor
6. **Customer notification** = Notify customer of direct ship with tracking details via `reva-turbo-customer-comms`

Log direct ship decision:
```bash
echo '{"ts":"'$(date -u +%Y-%m-%dT%H:%M:%SZ)'","po":"{{PO_NUMBER}}","routing":"direct_to_customer","customer":"{{CUSTOMER}}","partner":"{{PARTNER}}","rationale":"{{RATIONALE}}","pm":"{{PM_NAME}}"}' >> ~/.reva-turbo/shipments/shipment-log.jsonl
```

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

#### Carrier Restrictions by Product Type

| Product Type | Air Restrictions | Ocean Restrictions | Special Handling |
|-------------|------------------|--------------------|-----------------|
| Lithium batteries (standalone) | Many carriers restrict or prohibit — verify with carrier before booking | No general restriction | UN3480 / UN3481 labeling required; IATA PI 965/966/967 compliance |
| Lithium batteries (in equipment) | Allowed with restrictions — state of charge limits apply | No general restriction | PI 966 / 967 compliance; quantity limits per package |
| Hazmat (flammable, corrosive, oxidizer) | Requires IATA DGR compliance; some carriers refuse | Requires IMDG compliance | Dangerous Goods Declaration required; shipper's certification |
| ITAR-controlled hardware | Check BIS/DDTC export license before any carrier booking | Same | Carrier must agree to controlled cargo; end-user restrictions apply |
| Oversized / overweight | Not air-eligible above 300kg or dimensions exceeding airline maximums | No general restriction | Special handling surcharges apply |
| Standard commercial goods | No restriction | No restriction | Standard commercial |

If shipping lithium batteries or hazmat: confirm carrier acceptance in writing before booking. Do not assume.

#### ISF Filing Deadline

**Ocean shipments only.** ISF (Importer Security Filing, CBP Form ISF-10+2) must be filed **at least 24 hours before vessel departure** from the foreign port. Late filing triggers CBP penalties ($5,000 per violation). Rev A Manufacturing is the Importer of Record and responsible for ISF filing. Flag to PM if ETA from partner leaves less than 48 hours of buffer for ISF preparation.

```bash
# Log ISF filing status
echo '{"ts":"'$(date -u +%Y-%m-%dT%H:%M:%SZ)'","po":"{{PO_NUMBER}}","action":"isf_filed","vessel_etd":"{{VESSEL_ETD}}","filed_at":"'$(date -u +%Y-%m-%dT%H:%M:%SZ)'","filing_agent":"{{AGENT}}"}' >> ~/.reva-turbo/shipments/shipment-log.jsonl
```

#### Incoterms Selection Logic

Choose the correct Incoterm based on routing and Rev A's role:

| Incoterm | Who Arranges Transport | Rev A Pays From | Use When |
|----------|----------------------|-----------------|----------|
| **FOB (Free on Board)** | Rev A from port of export | Port of export (China) to destination | Standard — partner delivers to port in China, Rev A pays freight from that point forward |
| **EXW (Ex Works)** | Rev A arranges all transport | Partner's factory door | Rev A wants full control of freight and customs from factory; partner does nothing after production |
| **DDP (Delivered Duty Paid)** | Partner arranges to customer door | Nothing (partner covers all) | Direct-to-customer flow where partner is trusted to deliver; good for qualified vendors on returning-customer orders |
| **DAP (Delivered at Place)** | Partner to named destination | Duty and import clearance only | Partner ships to customer address but Rev A handles import clearance |

Default recommendation:
- **Direct China→Customer flow:** DDP (trusted partner delivers to customer door, Rev A handles import compliance) or FOB (Rev A coordinates customs from port)
- **Inspect & Forward flow:** FOB or EXW (Rev A controls all freight to its facility)

#### Direct-to-Customer: Customs Entry Notes

When routing is Direct China→Customer:
- **Ultimate Consignee:** Customer name and delivery address (not Rev A)
- **Importer of Record:** Rev A Manufacturing (Rev A remains legally responsible for import compliance)
- **Customs entry filed to:** Customer delivery address as ultimate consignee
- **Notify party:** Rev A Manufacturing (for import visibility and duty payment)
- Rev A coordinates duty payment, ISF filing, and customs release remotely — goods never touch Rev A's facility
- Customer receives goods directly from partner; Rev A provides shipping documentation and customs clearance confirmation

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
4. Apply thresholds from `skills/revmyengine/references/escalation-thresholds.md` (Section 3: Order Delivery):
   - >3 days impact: PM alert via reva-turbo-pulse
   - >5 days impact: Customer notification required
   - >7 days impact: Trigger reva-turbo-escalate
5. Notify PM and customer if delivery date is affected

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
