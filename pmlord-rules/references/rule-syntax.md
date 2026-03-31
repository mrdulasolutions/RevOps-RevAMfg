# Rule Syntax Reference

Complete specification for PMLORD business rule definitions.

## Rule Schema

```yaml
rules:
  - id: "RULE-YYYYMMDD-NNNN"           # Auto-generated unique ID
    name: "Human-readable rule name"     # Required. Short, descriptive.
    type: "pricing"                      # Required. See Rule Types below.
    description: "What this rule does"   # Required. Full explanation.

    trigger:                             # Required. When the rule fires.
      # Simple trigger (single condition):
      field: "quantity"                  # The data field to evaluate
      operator: ">"                      # Comparison operator
      value: 500                         # Threshold or match value

      # Compound trigger (multiple conditions):
      # logic: "and"                     # "and" or "or"
      # conditions:
      #   - field: "quantity"
      #     operator: ">"
      #     value: 500
      #   - field: "customer_tier"
      #     operator: "in"
      #     value: ["Gold", "Platinum"]

    action:                              # Required. What happens when triggered.
      type: "pricing_adjustment"         # Action type. See Action Types below.
      # Additional fields depend on action type

    scope:                               # Required. Which skills evaluate this rule.
      - "pmlord-rfq-quote"              # Skill names, or ["all"] for all skills

    priority: 10                         # Required. 1 = highest, 100 = lowest.
    active: true                         # Required. Is the rule currently enforced?

    created_by: "Donovan Weber"          # Required. Who created this rule.
    created_at: "2026-03-30T00:00:00Z"   # Required. ISO 8601 timestamp.
    updated_at: "2026-03-30T00:00:00Z"   # Required. Last modification timestamp.

    # Optional fields:
    expires_at: null                     # ISO 8601. Rule auto-disables after this date.
    notes: ""                            # Internal notes about this rule.
    override_count: 0                    # How many times PMs have overridden this rule.
    last_triggered: null                 # Timestamp of last trigger.
    trigger_count: 0                     # Total number of times this rule has triggered.
```

## Rule Types

| Type | Value | Description |
|------|-------|-------------|
| Pricing | `pricing` | Volume discounts, surcharges, customer-specific pricing |
| Approval | `approval` | Threshold-based routing for sign-off |
| Alert | `alert` | Condition-based notifications |
| Routing | `routing` | Partner/vendor selection |
| Quality | `quality` | Inspection and acceptance criteria |
| Workflow | `workflow` | Process step modifications |
| Customer | `customer` | Customer-specific handling |

## Supported Trigger Fields

| Field Name | Type | Description | Example Values |
|-----------|------|-------------|---------------|
| `quantity` | number | Order quantity | 100, 500, 5000 |
| `total_value` | number | Total order value in USD | 5000, 50000, 150000 |
| `unit_price` | number | Price per unit in USD | 2.50, 45.00 |
| `margin_pct` | number | Gross margin percentage | 15, 25, 35.5 |
| `customer_name` | string | Customer company name | "Acme Corp" |
| `customer_tier` | string | Customer tier classification | "Platinum", "Gold", "Silver", "New" |
| `customer_first_order` | boolean | Is this the customer's first order? | true, false |
| `process_type` | string | Manufacturing process | "machining", "injection_molding", "sheet_metal", "die_casting", "stamping", "assembly" |
| `material_type` | string | Material classification | "aluminum_6061", "stainless_316", "abs_plastic", "nylon" |
| `complexity` | number | Order complexity rating (1-5) | 1, 2, 3, 4, 5 |
| `partner_name` | string | Manufacturing partner name | "Shenzhen Precision MFG" |
| `partner_score` | number | Partner scorecard rating (0-100) | 85, 92 |
| `lead_time_weeks` | number | Requested lead time in weeks | 2, 4, 8, 12 |
| `shipping_method` | string | Shipping mode | "ocean", "air", "courier" |
| `has_ncr` | boolean | Does this order have an active NCR? | true, false |
| `ncr_count` | number | Number of NCRs on this order | 0, 1, 3 |
| `is_repeat_order` | boolean | Is this a repeat of a previous order? | true, false |
| `tooling_required` | boolean | Does this order require new tooling? | true, false |
| `tooling_cost` | number | Tooling cost in USD | 0, 5000, 25000 |
| `pm` | string | Assigned PM name | "Ray", "Harley" |
| `order_stage` | string | Current workflow stage | "rfq", "quoting", "ordered", "manufacturing", "shipping", "inspection", "delivered" |
| `days_since_order` | number | Calendar days since order placed | 15, 30, 60 |
| `days_until_deadline` | number | Calendar days until customer deadline | 5, 14, 30 |
| `country_of_origin` | string | Manufacturing country | "China", "Taiwan", "Vietnam" |
| `certification_required` | string | Required certifications | "ISO9001", "AS9100", "IATF16949", "none" |

## Supported Operators

| Operator | Syntax | Operand Types | Description | Example |
|----------|--------|--------------|-------------|---------|
| Greater than | `>` | number | Field is greater than value | `quantity > 500` |
| Less than | `<` | number | Field is less than value | `margin_pct < 15` |
| Greater or equal | `>=` | number | Field is greater than or equal to value | `total_value >= 50000` |
| Less or equal | `<=` | number | Field is less than or equal to value | `lead_time_weeks <= 4` |
| Equal | `==` | number, string, boolean | Field equals value exactly | `customer_tier == "Platinum"` |
| Not equal | `!=` | number, string, boolean | Field does not equal value | `shipping_method != "ocean"` |
| Contains | `contains` | string | Field contains substring | `material_type contains "aluminum"` |
| Starts with | `starts_with` | string | Field starts with prefix | `customer_name starts_with "Acme"` |
| In list | `in` | array | Field value is in the provided list | `process_type in ["machining", "turning"]` |
| Not in list | `not_in` | array | Field value is not in the provided list | `customer_tier not_in ["New"]` |
| Between | `between` | array[2] | Field value is between two values (inclusive) | `complexity between [4, 5]` |

## Supported Action Types

### pricing_adjustment

Modify a price element.

```yaml
action:
  type: pricing_adjustment
  adjustment_type: percentage    # "percentage" or "fixed_amount"
  adjustment_value: -5           # Negative = discount, positive = surcharge
  apply_to: unit_price           # "unit_price", "total_price", "shipping", "tooling"
```

### require_approval

Route for approval before proceeding.

```yaml
action:
  type: require_approval
  approver: "Senior PM"          # "Senior PM", "Donovan Weber", or specific name
  message: "Approval message"    # Context shown to the approver
  blocking: true                 # If true, workflow stops until approved
```

### send_alert

Send a notification.

```yaml
action:
  type: send_alert
  recipient: "Ray"               # PM name, or "all" for all PMs
  severity: "warning"            # "info", "warning", "critical"
  message: "Alert: {{field}} exceeded threshold"  # Supports {{field}} interpolation
  channel: "pulse"               # "pulse" (default), "email", "both"
```

### route_to_partner

Direct manufacturing to a specific partner.

```yaml
action:
  type: route_to_partner
  partner: "Shenzhen Precision"  # Partner name
  reason: "Specialized in 5-axis machining"
  fallback: "Dongguan CNC Ltd"   # If primary partner is at capacity
  priority_level: "preferred"    # "required" (must use), "preferred" (suggest), "fallback_only"
```

### set_quality_level

Change inspection requirements.

```yaml
action:
  type: set_quality_level
  inspection_level: "enhanced"   # "standard", "enhanced", "full"
  aql_level: 1.0                 # AQL sampling level (1.0, 2.5, 4.0, 6.5)
  special_requirements:          # Additional requirements
    - "100% dimensional check on critical features"
    - "Material certification required"
```

### add_workflow_step

Insert an additional step in the workflow.

```yaml
action:
  type: add_workflow_step
  step_name: "Engineering Review"
  insert_after: "rfq_qualification"  # The step after which to insert
  instructions: "Route to engineering team for DFM review before quoting"
  assignee: "Engineering"            # Who performs this step
  estimated_duration: "2 days"
```

### skip_workflow_step

Bypass a step that is not needed.

```yaml
action:
  type: skip_workflow_step
  step_name: "repackaging"
  reason: "Direct ship to customer from partner warehouse"
  requires_confirmation: true    # PM must confirm the skip
```

### set_field_value

Set a specific field to a value.

```yaml
action:
  type: set_field_value
  field: "shipping_method"
  value: "air"
  reason: "Lead time requires air freight"
```

### flag_for_review

Mark an item for human review.

```yaml
action:
  type: flag_for_review
  review_level: "Senior PM"     # "PM", "Senior PM", "Donovan"
  flag_message: "Unusual margin profile -- review before proceeding"
  blocking: false                # If true, workflow stops until reviewed
```

## Compound Trigger Examples

### AND Logic (all conditions must match)

```yaml
trigger:
  logic: "and"
  conditions:
    - field: quantity
      operator: ">"
      value: 1000
    - field: customer_tier
      operator: "=="
      value: "Platinum"
    - field: is_repeat_order
      operator: "=="
      value: true
```

This triggers only when: quantity > 1000 AND customer is Platinum AND it is a repeat order.

### OR Logic (any condition can match)

```yaml
trigger:
  logic: "or"
  conditions:
    - field: margin_pct
      operator: "<"
      value: 15
    - field: total_value
      operator: ">"
      value: 100000
```

This triggers when: margin is below 15% OR total value exceeds $100K.

### Nested Logic

```yaml
trigger:
  logic: "and"
  conditions:
    - field: process_type
      operator: "=="
      value: "injection_molding"
    - logic: "or"
      conditions:
        - field: quantity
          operator: ">"
          value: 5000
        - field: tooling_required
          operator: "=="
          value: true
```

This triggers when: process is injection molding AND (quantity > 5000 OR tooling is required).

## Expiration

Rules can have an expiration date:

```yaml
expires_at: "2026-12-31T23:59:59Z"
```

After this date, the rules engine treats the rule as `active: false`. Useful for temporary promotions, seasonal adjustments, or trial rules.

## Rule Versioning

When a rule is edited, the previous version is preserved in the edit log. The rules-log.jsonl captures every change with before/after values, enabling full audit history.
