# Rule Schema Reference

## Required Fields

| Field | Type | Description |
|-------|------|-------------|
| `rule_id` | string | Unique ID: `RULE-{CAT}{NN}` (e.g., RULE-P01) |
| `name` | string | Human-readable rule name |
| `description` | string | What the rule enforces and why |
| `category` | enum | pricing, quality, capacity, escalation, logistics, customer, partner |
| `trigger` | enum | when_evaluated, on_event, scheduled |
| `conditions` | array | One or more condition objects |
| `action` | object | What happens when rule triggers |
| `severity` | enum | critical, high, medium, low |
| `active` | boolean | Whether rule is currently enforced |

## Condition Object

```yaml
conditions:
  - field: order.total_value      # Dot-notation data path
    operator: gt                   # Comparison operator
    value: 100000                  # Threshold
    join: and                      # How to combine with next condition
```

### Operators

| Operator | Description | Example |
|----------|-------------|---------|
| `eq` | Equals | `status eq "on_hold"` |
| `ne` | Not equals | `status ne "closed"` |
| `gt` | Greater than | `margin gt 0.25` |
| `gte` | Greater than or equal | `days_overdue gte 5` |
| `lt` | Less than | `lead_time lt 21` |
| `lte` | Less than or equal | `reject_rate lte 0.05` |
| `in` | Value in list | `category in ["machining","molding"]` |
| `not_in` | Value not in list | `status not_in ["closed","cancelled"]` |
| `contains` | String contains | `notes contains "hazmat"` |
| `between` | Range inclusive | `value between [1000, 50000]` |

## Action Object

```yaml
action:
  type: block          # Action type
  message: "Quote blocked: margin below minimum 25%"
  target: pmlord-escalate   # Optional: skill or person to route to
```

### Action Types

| Type | Behavior |
|------|----------|
| `block` | Stop workflow. Must resolve before proceeding. |
| `warn` | Display warning. PM can override with justification. |
| `auto_approve` | Proceed automatically. Log decision only. |
| `escalate` | Route to escalation matrix. |
| `notify` | Send alert via pmlord-pulse. |
| `flag` | Add review flag to record. |
| `adjust` | Auto-modify values (e.g., add premium). |

## Category Prefixes

| Category | Prefix | ID Range |
|----------|--------|----------|
| Pricing | P | RULE-P01 through RULE-P99 |
| Quality | Q | RULE-Q01 through RULE-Q99 |
| Capacity | C | RULE-C01 through RULE-C99 |
| Escalation | E | RULE-E01 through RULE-E99 |
| Logistics | L | RULE-L01 through RULE-L99 |
| Customer | CU | RULE-CU01 through RULE-CU99 |
| Partner | PR | RULE-PR01 through RULE-PR99 |
