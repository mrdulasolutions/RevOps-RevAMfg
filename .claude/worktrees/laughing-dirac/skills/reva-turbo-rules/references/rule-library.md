# Rule Library

Pre-built business rules for Rev A Manufacturing. Import these directly into your rules engine or use as templates for custom rules.

---

## Pricing Rules

### P1: Volume Discount 5% (qty > 500)

```yaml
- id: "LIB-P1"
  name: "Volume discount 5%"
  type: pricing
  description: "Apply 5% discount to unit price when order quantity exceeds 500 units. Rewards volume commitments."
  trigger:
    field: quantity
    operator: ">"
    value: 500
  action:
    type: pricing_adjustment
    adjustment_type: percentage
    adjustment_value: -5
    apply_to: unit_price
  scope: [reva-turbo-rfq-quote]
  priority: 20
  active: true
```

**Rationale:** Higher quantities reduce per-unit manufacturing and overhead costs. Passing 5% to the customer incentivizes larger orders while preserving healthy margins.

### P2: Volume Discount 10% (qty > 2,000)

```yaml
- id: "LIB-P2"
  name: "Volume discount 10%"
  type: pricing
  description: "Apply 10% discount to unit price for large production orders exceeding 2,000 units."
  trigger:
    field: quantity
    operator: ">"
    value: 2000
  action:
    type: pricing_adjustment
    adjustment_type: percentage
    adjustment_value: -10
    apply_to: unit_price
  scope: [reva-turbo-rfq-quote]
  priority: 15
  active: true
```

**Rationale:** Production-level quantities significantly reduce per-unit cost. This supersedes P1 (higher priority) for large orders.

### P3: Expedite Surcharge 10%

```yaml
- id: "LIB-P3"
  name: "Expedite surcharge 10%"
  type: pricing
  description: "Apply 10% surcharge to total price when requested lead time is less than 4 weeks. Covers air freight and partner rush fees."
  trigger:
    field: lead_time_weeks
    operator: "<"
    value: 4
  action:
    type: pricing_adjustment
    adjustment_type: percentage
    adjustment_value: 10
    apply_to: total_price
  scope: [reva-turbo-rfq-quote]
  priority: 10
  active: true
```

**Rationale:** Lead times under 4 weeks require air freight instead of ocean and may incur partner rush charges. The surcharge covers these additional costs.

### P4: New Customer Setup Fee

```yaml
- id: "LIB-P4"
  name: "New customer setup fee"
  type: pricing
  description: "Add $150 setup fee for first-time customers to cover onboarding, credit check, and account setup."
  trigger:
    field: customer_first_order
    operator: "=="
    value: true
  action:
    type: pricing_adjustment
    adjustment_type: fixed_amount
    adjustment_value: 150
    apply_to: total_price
  scope: [reva-turbo-rfq-quote]
  priority: 30
  active: true
```

**Rationale:** New customers require onboarding effort. This fee is typically waived for orders over $10K (create a separate override rule if desired).

### P5: Repeat Order Discount 3%

```yaml
- id: "LIB-P5"
  name: "Repeat order discount 3%"
  type: pricing
  description: "Apply 3% loyalty discount on repeat orders for the same part from existing customers."
  trigger:
    field: is_repeat_order
    operator: "=="
    value: true
  action:
    type: pricing_adjustment
    adjustment_type: percentage
    adjustment_value: -3
    apply_to: unit_price
  scope: [reva-turbo-rfq-quote]
  priority: 25
  active: true
```

**Rationale:** Repeat orders have lower overhead (no new quoting, existing tooling, known process). Sharing savings with the customer encourages loyalty.

### P6: Platinum Customer Preferred Pricing

```yaml
- id: "LIB-P6"
  name: "Platinum customer preferred pricing"
  type: pricing
  description: "Apply 5% preferred pricing for Platinum tier customers on all orders."
  trigger:
    field: customer_tier
    operator: "=="
    value: "Platinum"
  action:
    type: pricing_adjustment
    adjustment_type: percentage
    adjustment_value: -5
    apply_to: unit_price
  scope: [reva-turbo-rfq-quote]
  priority: 18
  active: true
```

**Rationale:** Platinum customers represent high lifetime value. Preferred pricing reinforces the relationship and reduces competitive risk.

### P7: Material Surcharge for Exotic Alloys

```yaml
- id: "LIB-P7"
  name: "Exotic alloy material surcharge"
  type: pricing
  description: "Add 8% surcharge for orders using titanium, Inconel, or other exotic alloys to cover material price volatility."
  trigger:
    field: material_type
    operator: "in"
    value: ["titanium", "inconel", "hastelloy", "monel", "kovar"]
  action:
    type: pricing_adjustment
    adjustment_type: percentage
    adjustment_value: 8
    apply_to: unit_price
  scope: [reva-turbo-rfq-quote]
  priority: 12
  active: true
```

**Rationale:** Exotic alloy prices are highly volatile. The surcharge provides a buffer against price swings between quoting and purchasing.

---

## Approval Rules

### A1: Senior PM Approval for Quotes > $50K

```yaml
- id: "LIB-A1"
  name: "Senior PM approval for large quotes"
  type: approval
  description: "Require Senior PM sign-off before sending any quote exceeding $50,000 to the customer."
  trigger:
    field: total_value
    operator: ">"
    value: 50000
  action:
    type: require_approval
    approver: "Senior PM"
    message: "This quote exceeds $50K. Senior PM review required before sending to customer."
    blocking: true
  scope: [reva-turbo-rfq-quote, reva-turbo-customer-comms]
  priority: 5
  active: true
```

### A2: Donovan Approval for Quotes > $100K

```yaml
- id: "LIB-A2"
  name: "Donovan approval for major quotes"
  type: approval
  description: "Require Donovan Weber sign-off for any quote exceeding $100,000."
  trigger:
    field: total_value
    operator: ">"
    value: 100000
  action:
    type: require_approval
    approver: "Donovan Weber"
    message: "This quote exceeds $100K. Donovan Weber approval required."
    blocking: true
  scope: [reva-turbo-rfq-quote, reva-turbo-customer-comms]
  priority: 3
  active: true
```

### A3: Margin Floor Approval

```yaml
- id: "LIB-A3"
  name: "Low margin approval required"
  type: approval
  description: "Require approval when gross margin falls below 18%. Senior PM for 15-18%, Donovan for below 15%."
  trigger:
    field: margin_pct
    operator: "<"
    value: 18
  action:
    type: require_approval
    approver: "Senior PM"
    message: "Margin is below 18%. Approval required to proceed at this price point."
    blocking: true
  scope: [reva-turbo-rfq-quote]
  priority: 4
  active: true
```

### A4: New Customer Large Order Approval

```yaml
- id: "LIB-A4"
  name: "New customer large order approval"
  type: approval
  description: "Require Senior PM approval for first orders from new customers exceeding $25,000."
  trigger:
    logic: "and"
    conditions:
      - field: customer_first_order
        operator: "=="
        value: true
      - field: total_value
        operator: ">"
        value: 25000
  action:
    type: require_approval
    approver: "Senior PM"
    message: "First order from new customer exceeding $25K. Review customer creditworthiness and order feasibility."
    blocking: true
  scope: [reva-turbo-rfq-quote]
  priority: 6
  active: true
```

---

## Alert Rules

### L1: Delivery Delay Warning (7 days)

```yaml
- id: "LIB-L1"
  name: "Delivery delay warning"
  type: alert
  description: "Alert assigned PM when an order is more than 7 days past its expected delivery date."
  trigger:
    field: days_past_deadline
    operator: ">"
    value: 7
  action:
    type: send_alert
    recipient: "assigned_pm"
    severity: "warning"
    message: "Order {{order_id}} for {{customer_name}} is {{days_past_deadline}} days past expected delivery. Follow up with partner."
    channel: "pulse"
  scope: [reva-turbo-order-track, reva-turbo-pulse]
  priority: 15
  active: true
```

### L2: Delivery Delay Escalation (14 days)

```yaml
- id: "LIB-L2"
  name: "Delivery delay escalation"
  type: alert
  description: "Escalate to Senior PM and assigned PM when delivery is more than 14 days late."
  trigger:
    field: days_past_deadline
    operator: ">"
    value: 14
  action:
    type: send_alert
    recipient: "all"
    severity: "critical"
    message: "ESCALATION: Order {{order_id}} for {{customer_name}} is {{days_past_deadline}} days late. Customer communication and partner intervention required."
    channel: "both"
  scope: [reva-turbo-order-track, reva-turbo-pulse]
  priority: 5
  active: true
```

### L3: NCR Filed Alert

```yaml
- id: "LIB-L3"
  name: "NCR filed alert"
  type: alert
  description: "Alert Senior PM whenever a new NCR is filed for any order."
  trigger:
    field: ncr_count
    operator: ">"
    value: 0
  action:
    type: send_alert
    recipient: "all"
    severity: "warning"
    message: "NCR filed on order {{order_id}} ({{customer_name}}). Quality issue requires attention."
    channel: "pulse"
  scope: [reva-turbo-ncr]
  priority: 10
  active: true
```

### L4: Payment Overdue Alert

```yaml
- id: "LIB-L4"
  name: "Payment overdue 30 days"
  type: alert
  description: "Alert PM and Donovan when customer payment is more than 30 days overdue."
  trigger:
    field: days_payment_overdue
    operator: ">"
    value: 30
  action:
    type: send_alert
    recipient: "all"
    severity: "warning"
    message: "Payment overdue: {{customer_name}} owes ${{amount_overdue}} on invoice {{invoice_id}}, now {{days_payment_overdue}} days past due."
    channel: "both"
  scope: [reva-turbo-pulse, reva-turbo-crm-connector]
  priority: 10
  active: true
```

### L5: High-Value RFQ Notification

```yaml
- id: "LIB-L5"
  name: "High-value RFQ notification"
  type: alert
  description: "Notify Donovan when an RFQ with estimated value over $75K is received."
  trigger:
    field: total_value
    operator: ">"
    value: 75000
  action:
    type: send_alert
    recipient: "Donovan Weber"
    severity: "info"
    message: "High-value RFQ received: {{customer_name}}, estimated value ${{total_value}}. PM: {{pm}}."
    channel: "pulse"
  scope: [reva-turbo-rfq-intake]
  priority: 20
  active: true
```

---

## Routing Rules

### R1: Route Injection Molding to Partner

```yaml
- id: "LIB-R1"
  name: "Injection molding partner routing"
  type: routing
  description: "Route injection molding orders to the preferred injection molding partner."
  trigger:
    field: process_type
    operator: "=="
    value: "injection_molding"
  action:
    type: route_to_partner
    partner: "{{INJECTION_MOLD_PARTNER}}"
    reason: "Preferred partner for injection molding with highest scorecard rating"
    fallback: "{{INJECTION_MOLD_FALLBACK}}"
    priority_level: "preferred"
  scope: [reva-turbo-rfq-qualify, reva-turbo-china-package]
  priority: 20
  active: true
```

**Note:** Set partner names during import.

### R2: Route 5-Axis Machining to Partner

```yaml
- id: "LIB-R2"
  name: "5-axis machining partner routing"
  type: routing
  description: "Route complex machining (5-axis) orders to the specialized machining partner."
  trigger:
    logic: "and"
    conditions:
      - field: process_type
        operator: "=="
        value: "machining"
      - field: complexity
        operator: ">="
        value: 4
  action:
    type: route_to_partner
    partner: "{{5AXIS_PARTNER}}"
    reason: "Complex machining requires 5-axis capability"
    fallback: "{{5AXIS_FALLBACK}}"
    priority_level: "preferred"
  scope: [reva-turbo-rfq-qualify, reva-turbo-china-package]
  priority: 15
  active: true
```

### R3: Route Sheet Metal to Partner

```yaml
- id: "LIB-R3"
  name: "Sheet metal partner routing"
  type: routing
  description: "Route sheet metal fabrication orders to the preferred sheet metal partner."
  trigger:
    field: process_type
    operator: "=="
    value: "sheet_metal"
  action:
    type: route_to_partner
    partner: "{{SHEET_METAL_PARTNER}}"
    reason: "Preferred partner for sheet metal with laser cutting and bending capability"
    fallback: "{{SHEET_METAL_FALLBACK}}"
    priority_level: "preferred"
  scope: [reva-turbo-rfq-qualify, reva-turbo-china-package]
  priority: 20
  active: true
```

---

## Quality Rules

### Q1: Enhanced Inspection for New Customers

```yaml
- id: "LIB-Q1"
  name: "New customer enhanced inspection"
  type: quality
  description: "Apply enhanced inspection level for the first 3 orders from any new customer."
  trigger:
    field: customer_first_order
    operator: "=="
    value: true
  action:
    type: set_quality_level
    inspection_level: "enhanced"
    aql_level: 1.0
    special_requirements:
      - "100% inspection on first article"
      - "Full dimensional report"
      - "Material certification verification"
  scope: [reva-turbo-inspect, reva-turbo-quality-gate]
  priority: 15
  active: true
```

**Rationale:** New customer relationships require extra quality diligence. A quality escape on the first order can end the relationship permanently.

### Q2: Full Inspection for Aerospace/Medical

```yaml
- id: "LIB-Q2"
  name: "Aerospace/medical full inspection"
  type: quality
  description: "Apply full inspection with documentation for parts requiring aerospace or medical certifications."
  trigger:
    field: certification_required
    operator: "in"
    value: ["AS9100", "ISO13485", "IATF16949"]
  action:
    type: set_quality_level
    inspection_level: "full"
    aql_level: 1.0
    special_requirements:
      - "100% critical dimension inspection"
      - "Full FAIR (First Article Inspection Report)"
      - "Material traceability documentation"
      - "Process certifications verified"
      - "Retain inspection records for 10 years"
  scope: [reva-turbo-inspect, reva-turbo-quality-gate]
  priority: 5
  active: true
```

### Q3: Tighter AQL for Platinum Customers

```yaml
- id: "LIB-Q3"
  name: "Platinum customer quality standard"
  type: quality
  description: "Apply tighter AQL (1.0 vs standard 2.5) for Platinum tier customers."
  trigger:
    field: customer_tier
    operator: "=="
    value: "Platinum"
  action:
    type: set_quality_level
    inspection_level: "enhanced"
    aql_level: 1.0
    special_requirements:
      - "Tighter AQL per Platinum customer agreement"
  scope: [reva-turbo-inspect, reva-turbo-quality-gate]
  priority: 12
  active: true
```

### Q4: NCR History Quality Upgrade

```yaml
- id: "LIB-Q4"
  name: "Quality upgrade for NCR-prone orders"
  type: quality
  description: "Apply enhanced inspection when an order is from a partner with NCR history on similar parts."
  trigger:
    field: has_ncr
    operator: "=="
    value: true
  action:
    type: set_quality_level
    inspection_level: "enhanced"
    aql_level: 1.0
    special_requirements:
      - "Additional checks on previously-failed dimensions"
      - "Compare against NCR findings"
  scope: [reva-turbo-inspect]
  priority: 10
  active: true
```

---

## Workflow Rules

### W1: Extra QC for Complex Orders

```yaml
- id: "LIB-W1"
  name: "Extra QC checkpoint for complex orders"
  type: workflow
  description: "Add an additional QC checkpoint step for orders with complexity rating 4 or 5."
  trigger:
    field: complexity
    operator: ">="
    value: 4
  action:
    type: add_workflow_step
    step_name: "Pre-Ship QC Review"
    insert_after: "inspection"
    instructions: "Senior PM reviews inspection results and approves shipment to customer. Verify all critical dimensions, finish quality, and documentation completeness."
    assignee: "Senior PM"
    estimated_duration: "1 day"
  scope: [reva-turbo-order-track, reva-turbo-inspect]
  priority: 20
  active: true
```

### W2: Skip Repackaging for Direct Ship

```yaml
- id: "LIB-W2"
  name: "Skip repackaging for direct ship"
  type: workflow
  description: "Skip the repackaging step when customer accepts direct shipment from partner (no Rev A touch)."
  trigger:
    field: shipping_method
    operator: "=="
    value: "direct_ship"
  action:
    type: skip_workflow_step
    step_name: "repackaging"
    reason: "Customer accepts direct shipment from manufacturing partner"
    requires_confirmation: true
  scope: [reva-turbo-order-track, reva-turbo-repackage]
  priority: 25
  active: true
```

### W3: Engineering Review for New Designs

```yaml
- id: "LIB-W3"
  name: "Engineering review for new designs"
  type: workflow
  description: "Add engineering/DFM review step before quoting for orders requiring new tooling."
  trigger:
    field: tooling_required
    operator: "=="
    value: true
  action:
    type: add_workflow_step
    step_name: "Engineering DFM Review"
    insert_after: "rfq_qualification"
    instructions: "Review part design for manufacturability. Check draft angles, wall thicknesses, undercuts, tolerances. Provide DFM feedback to customer if needed."
    assignee: "Engineering"
    estimated_duration: "2 days"
  scope: [reva-turbo-rfq-qualify, reva-turbo-rfq-quote]
  priority: 15
  active: true
```

### W4: Customer Approval Step for High-Value Orders

```yaml
- id: "LIB-W4"
  name: "Customer PO verification for large orders"
  type: workflow
  description: "Add a PO verification step before manufacturing for orders exceeding $25,000."
  trigger:
    field: total_value
    operator: ">"
    value: 25000
  action:
    type: add_workflow_step
    step_name: "PO Verification"
    insert_after: "order_confirmation"
    instructions: "Verify customer PO matches quote exactly: quantities, prices, terms, delivery date. Flag any discrepancies before releasing to manufacturing."
    assignee: "PM"
    estimated_duration: "1 day"
  scope: [reva-turbo-order-track]
  priority: 18
  active: true
```

---

## Customer Rules

### C1: Special Handling Instructions

```yaml
- id: "LIB-C1"
  name: "Customer-specific packaging requirements"
  type: customer
  description: "Template for customer-specific packaging, labeling, or shipping requirements."
  trigger:
    field: customer_name
    operator: "=="
    value: "{{CUSTOMER_NAME}}"
  action:
    type: set_field_value
    field: "packaging_instructions"
    value: "{{PACKAGING_INSTRUCTIONS}}"
    reason: "Customer-specific packaging requirements per agreement"
  scope: [reva-turbo-repackage, reva-turbo-logistics]
  priority: 10
  active: true
```

**Note:** Duplicate and customize per customer during import.

### C2: Customer Communication Preferences

```yaml
- id: "LIB-C2"
  name: "Customer communication preferences"
  type: customer
  description: "Template for setting customer-preferred communication method and frequency."
  trigger:
    field: customer_name
    operator: "=="
    value: "{{CUSTOMER_NAME}}"
  action:
    type: set_field_value
    field: "comm_preferences"
    value: "{{COMM_PREFERENCES}}"
    reason: "Customer prefers {{COMM_METHOD}} updates {{COMM_FREQUENCY}}"
  scope: [reva-turbo-customer-comms]
  priority: 15
  active: true
```

### C3: Customer Credit Hold

```yaml
- id: "LIB-C3"
  name: "Credit hold for slow-paying customers"
  type: customer
  description: "Flag for PM review when placing a new order for a customer with outstanding overdue invoices."
  trigger:
    logic: "and"
    conditions:
      - field: customer_name
        operator: "=="
        value: "{{CUSTOMER_NAME}}"
      - field: days_payment_overdue
        operator: ">"
        value: 45
  action:
    type: flag_for_review
    review_level: "Senior PM"
    flag_message: "Customer has invoices overdue by more than 45 days. Review payment status before accepting new orders."
    blocking: true
  scope: [reva-turbo-rfq-quote, reva-turbo-order-track]
  priority: 3
  active: true
```

### C4: Auto-Apply Customer Terms

```yaml
- id: "LIB-C4"
  name: "Customer payment terms"
  type: customer
  description: "Automatically set payment terms based on customer tier."
  trigger:
    field: customer_tier
    operator: "in"
    value: ["Platinum", "Gold"]
  action:
    type: set_field_value
    field: "payment_terms"
    value: "Net 30"
    reason: "Platinum and Gold customers receive Net 30 terms per policy"
  scope: [reva-turbo-rfq-quote]
  priority: 30
  active: true
```

---

## Summary

| Category | Count | Rule IDs |
|----------|-------|----------|
| Pricing | 7 | P1-P7 |
| Approval | 4 | A1-A4 |
| Alert | 5 | L1-L5 |
| Routing | 3 | R1-R3 |
| Quality | 4 | Q1-Q4 |
| Workflow | 4 | W1-W4 |
| Customer | 4 | C1-C4 |
| **Total** | **31** | |

All rules in this library are templates. Partner names, customer names, and other business-specific values marked with `{{PLACEHOLDER}}` must be set during import.
