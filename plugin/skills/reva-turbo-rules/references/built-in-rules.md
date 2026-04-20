# Built-in Rules — Rev A Manufacturing

## Pricing Rules

```yaml
- rule_id: RULE-P01
  name: Minimum Margin
  description: Prevent quotes below profitability floor
  category: pricing
  trigger: when_evaluated
  conditions:
    - field: quote.gross_margin_pct
      operator: lt
      value: 0.25
  action:
    type: block
    message: "Quote blocked: gross margin {{actual}}% is below minimum 25%"
  severity: high
  active: true

- rule_id: RULE-P02
  name: Large Order Discount Cap
  description: Prevent excessive discounts on large orders
  category: pricing
  trigger: when_evaluated
  conditions:
    - field: quote.total_value
      operator: gt
      value: 50000
    - field: quote.discount_pct
      operator: gt
      value: 0.15
      join: and
  action:
    type: warn
    message: "Discount {{actual}}% exceeds 15% cap on orders > $50K"
  severity: medium
  active: true

- rule_id: RULE-P03
  name: Tooling Cost Threshold
  description: Escalate high tooling costs for approval
  category: pricing
  trigger: when_evaluated
  conditions:
    - field: quote.tooling_cost
      operator: gt
      value: 10000
  action:
    type: escalate
    message: "Tooling cost ${{actual}} requires VP approval"
    target: donovan-weber
  severity: high
  active: true

- rule_id: RULE-P04
  name: Rush Premium
  description: Auto-add premium for rush orders
  category: pricing
  trigger: when_evaluated
  conditions:
    - field: quote.lead_time_days
      operator: lt
      value: 21
  action:
    type: adjust
    message: "Rush premium 20% applied — lead time {{actual}} days < 3 weeks"
  severity: low
  active: true

- rule_id: RULE-P05
  name: New Customer Pricing Review
  description: Flag first-time customer quotes for BD review
  category: pricing
  trigger: when_evaluated
  conditions:
    - field: customer.order_count
      operator: eq
      value: 0
  action:
    type: flag
    message: "New customer — route quote to BD for relationship pricing review"
  severity: low
  active: true
```

## Quality Rules

```yaml
- rule_id: RULE-Q01
  name: Reject Rate Trigger
  description: Escalate when partner reject rate exceeds threshold
  category: quality
  trigger: when_evaluated
  conditions:
    - field: partner.reject_rate_30d
      operator: gt
      value: 0.05
  action:
    type: escalate
    message: "Partner {{partner}} reject rate {{actual}}% exceeds 5% threshold"
  severity: high
  active: true

- rule_id: RULE-Q02
  name: Critical Dimension Hold
  description: Block shipment if critical dimensions out of spec
  category: quality
  trigger: when_evaluated
  conditions:
    - field: inspection.critical_dims_pass
      operator: eq
      value: false
  action:
    type: block
    message: "SHIPMENT BLOCKED — critical dimension(s) out of specification"
  severity: critical
  active: true

- rule_id: RULE-Q03
  name: First Article Required
  description: Require FAI approval on new part numbers
  category: quality
  trigger: when_evaluated
  conditions:
    - field: part.is_new
      operator: eq
      value: true
    - field: part.fai_approved
      operator: eq
      value: false
      join: and
  action:
    type: block
    message: "First article inspection required before production release"
  severity: high
  active: true

- rule_id: RULE-Q04
  name: NCR Repeat Block
  description: Block new orders to partners with too many open NCRs
  category: quality
  trigger: when_evaluated
  conditions:
    - field: partner.open_ncr_count
      operator: gte
      value: 3
  action:
    type: block
    message: "Partner has {{actual}} open NCRs — resolve before placing new orders"
  severity: high
  active: true

- rule_id: RULE-Q05
  name: Material Cert Required
  description: Hold inspection until material certification received
  category: quality
  trigger: when_evaluated
  conditions:
    - field: shipment.material_cert_received
      operator: eq
      value: false
  action:
    type: block
    message: "Material certification not received — inspection on hold"
  severity: medium
  active: true
```

## Capacity Rules

```yaml
- rule_id: RULE-C01
  name: PM Overload Warning
  description: Warn when PM has too many active orders
  category: capacity
  trigger: when_evaluated
  conditions:
    - field: pm.active_order_count
      operator: gt
      value: 15
  action:
    type: warn
    message: "PM {{pm}} has {{actual}} active orders — consider rebalancing"
  severity: medium
  active: true

- rule_id: RULE-C02
  name: Partner Concentration Risk
  description: Flag over-reliance on single partner
  category: capacity
  trigger: when_evaluated
  conditions:
    - field: partner.volume_share_pct
      operator: gt
      value: 0.60
  action:
    type: flag
    message: "Partner {{partner}} handles {{actual}}% of volume — concentration risk"
  severity: medium
  active: true

- rule_id: RULE-C03
  name: Lead Time Buffer
  description: Warn if quoted lead time too tight
  category: capacity
  trigger: when_evaluated
  conditions:
    - field: quote.lead_time_buffer_days
      operator: lt
      value: 5
  action:
    type: warn
    message: "Lead time buffer only {{actual}} days — risk of late delivery"
  severity: medium
  active: true
```

## Escalation Rules

```yaml
- rule_id: RULE-E01
  name: High Value Order
  description: Escalate large orders to president
  category: escalation
  trigger: when_evaluated
  conditions:
    - field: order.total_value
      operator: gt
      value: 100000
  action:
    type: escalate
    message: "Order value ${{actual}} exceeds $100K — escalating to Donovan Weber"
    target: donovan-weber
  severity: high
  active: true

- rule_id: RULE-E02
  name: Customer Quality Complaint
  description: Auto-escalate quality complaints
  category: escalation
  trigger: on_event
  conditions:
    - field: event.type
      operator: eq
      value: "customer_complaint"
    - field: event.category
      operator: eq
      value: "quality"
      join: and
  action:
    type: escalate
    message: "Customer quality complaint from {{customer}} — immediate escalation"
  severity: critical
  active: true

- rule_id: RULE-E03
  name: Delivery Delay
  description: Escalate significantly overdue deliveries
  category: escalation
  trigger: when_evaluated
  conditions:
    - field: order.days_past_due
      operator: gt
      value: 5
  action:
    type: escalate
    message: "Order {{order_id}} is {{actual}} days past due"
  severity: high
  active: true

- rule_id: RULE-E04
  name: Payment Overdue
  description: Flag significantly overdue payments
  category: escalation
  trigger: scheduled
  conditions:
    - field: customer.days_past_due
      operator: gt
      value: 60
  action:
    type: flag
    message: "Account {{customer}} is {{actual}} days past due — credit review needed"
  severity: high
  active: true
```

## Logistics Rules

```yaml
- rule_id: RULE-L01
  name: Customs Formal Entry
  description: Warn when formal customs entry required
  category: logistics
  trigger: when_evaluated
  conditions:
    - field: shipment.declared_value
      operator: gt
      value: 2500
  action:
    type: warn
    message: "Shipment value ${{actual}} requires formal customs entry (> $2500)"
  severity: medium
  active: true

- rule_id: RULE-L02
  name: Hazmat Classification
  description: Block shipping until hazmat status confirmed
  category: logistics
  trigger: when_evaluated
  conditions:
    - field: shipment.hazmat_classified
      operator: eq
      value: false
    - field: shipment.materials_flagged
      operator: eq
      value: true
      join: and
  action:
    type: block
    message: "Hazmat classification required before shipping"
  severity: critical
  active: true

- rule_id: RULE-L03
  name: Shipping Insurance Required
  description: Require insurance on high-value shipments
  category: logistics
  trigger: when_evaluated
  conditions:
    - field: shipment.total_value
      operator: gt
      value: 25000
  action:
    type: warn
    message: "Shipment value ${{actual}} — shipping insurance required"
  severity: medium
  active: true
```

## Customer Rules

```yaml
- rule_id: RULE-CU01
  name: Credit Hold
  description: Block orders for accounts on credit hold
  category: customer
  trigger: when_evaluated
  conditions:
    - field: customer.credit_status
      operator: eq
      value: "hold"
  action:
    type: block
    message: "Customer {{customer}} is on credit hold — cannot accept new orders"
  severity: critical
  active: true

- rule_id: RULE-CU02
  name: NDA Required
  description: Require NDA before sharing partner info
  category: customer
  trigger: when_evaluated
  conditions:
    - field: customer.nda_signed
      operator: eq
      value: false
  action:
    type: block
    message: "NDA not on file — cannot share partner or manufacturing details"
  severity: high
  active: true

- rule_id: RULE-CU03
  name: Inactive Customer Requalification
  description: Flag dormant customers for requalification
  category: customer
  trigger: scheduled
  conditions:
    - field: customer.days_since_last_order
      operator: gt
      value: 365
  action:
    type: flag
    message: "Customer {{customer}} inactive {{actual}} days — requalification recommended"
  severity: low
  active: true
```

## Partner Rules

```yaml
- rule_id: RULE-PR01
  name: Scorecard Minimum
  description: Warn when using low-performing partner
  category: partner
  trigger: when_evaluated
  conditions:
    - field: partner.scorecard_grade
      operator: in
      value: ["D", "F"]
  action:
    type: warn
    message: "Partner {{partner}} scored {{actual}} — consider alternative"
  severity: medium
  active: true

- rule_id: RULE-PR02
  name: Audit Overdue
  description: Flag partners not audited recently
  category: partner
  trigger: scheduled
  conditions:
    - field: partner.days_since_audit
      operator: gt
      value: 540
  action:
    type: flag
    message: "Partner {{partner}} last audited {{actual}} days ago — audit due"
  severity: medium
  active: true

- rule_id: RULE-PR03
  name: IP Protection Agreement
  description: Require IP agreement before sending drawings
  category: partner
  trigger: when_evaluated
  conditions:
    - field: partner.ip_agreement_signed
      operator: eq
      value: false
  action:
    type: block
    message: "IP protection agreement required before sending drawings to {{partner}}"
  severity: high
  active: true
```
