---
name: pmlord-rules
preamble-tier: 2
version: 1.0.0
description: |
  Business rules engine for Rev A Manufacturing. Define rules once, apply forever.
  Turns tribal knowledge into automated policy. Covers pricing, approvals, alerts,
  routing, quality, workflow, and customer rules. The operating system layer of PMLORD.
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
mkdir -p ~/.pmlord/analytics
echo '{"skill":"pmlord-rules","ts":"'$(date -u +%Y-%m-%dT%H:%M:%SZ)'"}' >> ~/.pmlord/analytics/skill-usage.jsonl 2>/dev/null || true
```

## Purpose

Turn Rev A Manufacturing's tribal knowledge into codified, automatically-enforced business rules. A PM sets a rule once -- "apply 5% volume discount when quantity exceeds 500" -- and every relevant skill checks and applies that rule from that point forward. No more remembering, no more inconsistency, no more "we forgot to add the expedite fee."

Rules are stored in `~/.pmlord/rules.yaml` and evaluated by the rules engine (`bin/rules-engine.sh`).

## Flow

### Step 0: Mode Selection

> **PMLORD Rules Engine**
>
> What do you want to do?
>
> A) **Create** a new rule
> B) **Edit** an existing rule
> C) **Disable/enable** a rule
> D) **Delete** a rule
> E) **View** all rules (list with status)
> F) **Test** a rule against historical data
> G) **Import** rules from the rule library
> H) **View rule evaluation log**
>
> Select A-H: ___

Route to the appropriate sub-flow below.

---

### Mode A: Create a New Rule

#### Step A1: Rule Type Selection

> What type of rule do you want to create?
>
> 1. **Pricing rule** -- volume discounts, customer-specific pricing, surcharges, fees
> 2. **Approval rule** -- threshold-based routing for sign-off
> 3. **Alert rule** -- condition-based notifications via pmlord-pulse
> 4. **Routing rule** -- partner selection based on part type, capacity, score
> 5. **Quality rule** -- inspection criteria, AQL levels, special requirements
> 6. **Workflow rule** -- auto-skip steps, add extra steps, conditional branching
> 7. **Customer rule** -- customer-specific preferences, terms, handling instructions
>
> Select 1-7: ___

#### Step A2: Rule Definition

Collect rule details based on the selected type. Reference `references/rule-syntax.md` for the complete format.

> **Define your rule:**
>
> 1. Rule name (human-readable): ___
> 2. Description (what does this rule do and why): ___
>
> **Trigger condition:**
> 3. Field to evaluate: ___
>    (Examples: quantity, total_value, customer_name, process_type, margin_pct, lead_time_weeks, partner_name, material_type, complexity, customer_tier)
> 4. Operator: ___
>    (Options: >, <, >=, <=, ==, !=, contains, starts_with, in, not_in, between)
> 5. Value: ___
>    (Examples: 500, "Acme Corp", ["machining", "turning"], [10, 20] for between)
>
> **Action:**
> 6. Action type: ___
>    (Options: pricing_adjustment, require_approval, send_alert, route_to_partner, set_quality_level, add_workflow_step, skip_workflow_step, set_field_value, flag_for_review)
> 7. Action details: ___
>    (Depends on action type -- see below)
>
> **Scope and priority:**
> 8. Which skills does this rule apply to: ___
>    (Examples: pmlord-rfq-quote, pmlord-order-track, all)
> 9. Priority (1 = highest, 100 = lowest): ___
>    (Used for conflict resolution when multiple rules match)

**Action detail prompts by action type:**

For **pricing_adjustment**:
> - Adjustment type: percentage / fixed_amount
> - Adjustment value: ___ (e.g., -5% or +$25)
> - Apply to: unit_price / total_price / shipping / tooling

For **require_approval**:
> - Approver: Senior PM / Donovan Weber / specific name
> - Approval context message: ___

For **send_alert**:
> - Alert recipient: ___ (PM name or "all")
> - Alert severity: info / warning / critical
> - Alert message template: ___

For **route_to_partner**:
> - Partner name: ___
> - Routing reason: ___
> - Fallback partner (if primary unavailable): ___

For **set_quality_level**:
> - Inspection level: standard / enhanced / full
> - AQL level: ___ (e.g., 1.0, 2.5, 4.0)
> - Special requirements: ___

For **add_workflow_step**:
> - Step name: ___
> - Insert after step: ___
> - Step instructions: ___

For **skip_workflow_step**:
> - Step to skip: ___
> - Skip reason: ___

For **set_field_value**:
> - Field name: ___
> - Value to set: ___

For **flag_for_review**:
> - Review type: PM review / Senior PM review / Donovan review
> - Flag message: ___

#### Step A3: Compound Conditions (Optional)

> Does this rule have multiple conditions? (AND/OR logic)
>
> A) Single condition (as defined above) -- proceed
> B) Multiple conditions -- add more

If B, collect additional conditions:

> **Additional condition:**
> - Logic: AND / OR (relative to previous conditions)
> - Field: ___
> - Operator: ___
> - Value: ___

Build the compound trigger:

```yaml
trigger:
  logic: "and"  # or "or"
  conditions:
    - field: quantity
      operator: ">"
      value: 500
    - field: customer_tier
      operator: "in"
      value: ["Gold", "Platinum"]
```

#### Step A4: Rule Validation

**HUMAN-IN-THE-LOOP CHECKPOINT:**

> ## New Rule Review
>
> **Name:** {{RULE_NAME}}
> **Type:** {{RULE_TYPE}}
> **Description:** {{RULE_DESCRIPTION}}
>
> **WHEN:** {{TRIGGER_READABLE}}
> **THEN:** {{ACTION_READABLE}}
>
> **Scope:** {{RULE_SCOPE}}
> **Priority:** {{RULE_PRIORITY}}
>
> **Example:** If an order comes in with {{EXAMPLE_CONTEXT}}, this rule would {{EXAMPLE_EFFECT}}.
>
> A) Save this rule (active immediately)
> B) Save as draft (inactive until enabled)
> C) Test against historical data first
> D) Edit the rule
> E) Cancel

#### Step A5: Save Rule

Initialize the rules file if it does not exist:

```bash
mkdir -p ~/.pmlord
if [ ! -f ~/.pmlord/rules.yaml ]; then
  echo "rules: []" > ~/.pmlord/rules.yaml
fi
```

Append the new rule (the skill will read the current rules.yaml, add the new rule to the array, and write it back):

```bash
# Rule ID generation
_RULE_ID="RULE-$(date +%Y%m%d)-$(printf '%04d' $((RANDOM % 9999 + 1)))"
echo "$_RULE_ID"
```

Log the rule creation:

```bash
mkdir -p ~/.pmlord/state
echo '{"ts":"'$(date -u +%Y-%m-%dT%H:%M:%SZ)'","type":"rule_created","rule_id":"{{RULE_ID}}","rule_name":"{{RULE_NAME}}","rule_type":"{{RULE_TYPE}}","created_by":"{{PM_NAME}}","active":{{ACTIVE}}}' >> ~/.pmlord/state/rules-log.jsonl 2>/dev/null || true
```

> Rule **{{RULE_NAME}}** ({{RULE_ID}}) created and {{ACTIVE_STATUS}}.
> This rule will be evaluated by: {{RULE_SCOPE}}
> Priority: {{RULE_PRIORITY}}

---

### Mode B: Edit an Existing Rule

#### Step B1: Rule Selection

List all rules:

```bash
cat ~/.pmlord/rules.yaml 2>/dev/null || echo "No rules file found. Create rules first."
```

> Select a rule to edit (enter rule ID or name): ___

#### Step B2: Edit Fields

Display the current rule and ask which fields to change:

> **Current rule: {{RULE_NAME}} ({{RULE_ID}})**
>
> 1. Name: {{RULE_NAME}}
> 2. Description: {{RULE_DESCRIPTION}}
> 3. Trigger: {{TRIGGER_READABLE}}
> 4. Action: {{ACTION_READABLE}}
> 5. Scope: {{RULE_SCOPE}}
> 6. Priority: {{RULE_PRIORITY}}
> 7. Active: {{ACTIVE}}
>
> Which field(s) to edit? (enter numbers, comma-separated): ___

Collect new values for selected fields, then update the rules.yaml file.

Log the edit:

```bash
echo '{"ts":"'$(date -u +%Y-%m-%dT%H:%M:%SZ)'","type":"rule_edited","rule_id":"{{RULE_ID}}","edited_by":"{{PM_NAME}}","fields_changed":"{{CHANGED_FIELDS}}"}' >> ~/.pmlord/state/rules-log.jsonl 2>/dev/null || true
```

---

### Mode C: Disable/Enable a Rule

```bash
cat ~/.pmlord/rules.yaml 2>/dev/null || echo "No rules file found."
```

> Select a rule to toggle (enter rule ID or name): ___
>
> Current status: {{CURRENT_STATUS}}
> New status: {{NEW_STATUS}}
>
> Confirm? (Y/N)

Update the `active` field in rules.yaml. Log the change:

```bash
echo '{"ts":"'$(date -u +%Y-%m-%dT%H:%M:%SZ)'","type":"rule_toggled","rule_id":"{{RULE_ID}}","new_status":"{{NEW_STATUS}}","toggled_by":"{{PM_NAME}}"}' >> ~/.pmlord/state/rules-log.jsonl 2>/dev/null || true
```

---

### Mode D: Delete a Rule

> **WARNING:** Deleting a rule is permanent. Consider disabling instead.
>
> Rule to delete: {{RULE_NAME}} ({{RULE_ID}})
>
> A) Disable instead of delete (recommended)
> B) Delete permanently
> C) Cancel

If B, remove from rules.yaml and log:

```bash
echo '{"ts":"'$(date -u +%Y-%m-%dT%H:%M:%SZ)'","type":"rule_deleted","rule_id":"{{RULE_ID}}","deleted_by":"{{PM_NAME}}","rule_name":"{{RULE_NAME}}"}' >> ~/.pmlord/state/rules-log.jsonl 2>/dev/null || true
```

---

### Mode E: View All Rules

```bash
cat ~/.pmlord/rules.yaml 2>/dev/null || echo "No rules defined yet."
```

Display rules in a readable table:

| # | ID | Name | Type | Trigger | Action | Scope | Priority | Active |
|---|-----|------|------|---------|--------|-------|----------|--------|
{{#RULES}}
| {{NUM}} | {{RULE_ID}} | {{RULE_NAME}} | {{RULE_TYPE}} | {{TRIGGER_SHORT}} | {{ACTION_SHORT}} | {{SCOPE}} | {{PRIORITY}} | {{ACTIVE}} |
{{/RULES}}

Summary:
- Total rules: {{TOTAL_RULES}}
- Active: {{ACTIVE_COUNT}}
- Inactive: {{INACTIVE_COUNT}}
- By type: Pricing ({{PRICING_COUNT}}), Approval ({{APPROVAL_COUNT}}), Alert ({{ALERT_COUNT}}), Routing ({{ROUTING_COUNT}}), Quality ({{QUALITY_COUNT}}), Workflow ({{WORKFLOW_COUNT}}), Customer ({{CUSTOMER_COUNT}})

---

### Mode F: Test a Rule

#### Step F1: Select Rule to Test

> Which rule do you want to test? (enter rule ID or name): ___

#### Step F2: Provide Test Context

> Provide test context (or enter "historical" to test against past orders):
>
> If providing manual context:
> - Quantity: ___
> - Total value: $___
> - Customer: ___
> - Customer tier: ___
> - Process type: ___
> - Material type: ___
> - Partner: ___
> - Complexity: ___
> - Lead time (weeks): ___
> - Margin %: ___

If "historical", scan workflow state for completed orders:

```bash
grep '"status":"complete"' ~/.pmlord/state/workflow-state.jsonl 2>/dev/null | tail -20 || echo "No historical orders found"
```

#### Step F3: Evaluate and Report

Run the rule against the test context using `bin/rules-engine.sh`:

```bash
echo '{{TEST_CONTEXT_JSON}}' | bash ~/.pmlord/bin/rules-engine.sh --test --rule-id "{{RULE_ID}}"
```

> **Test Results for rule: {{RULE_NAME}}**
>
> **Against manual context:**
> - Rule triggered: {{YES_NO}}
> - Trigger details: {{TRIGGER_EVAL}}
> - Action that would be taken: {{ACTION_DETAIL}}
>
> **Against historical data (if selected):**
>
> | Order ID | Customer | Would Trigger? | Effect |
> |----------|----------|---------------|--------|
> {{#HISTORICAL_RESULTS}}
> | {{ORDER_ID}} | {{CUSTOMER}} | {{TRIGGERED}} | {{EFFECT}} |
> {{/HISTORICAL_RESULTS}}
>
> Summary: This rule would have triggered on {{TRIGGER_COUNT}} of {{TOTAL_ORDERS}} orders ({{TRIGGER_PCT}}%).
> {{IMPACT_SUMMARY}}

---

### Mode G: Import from Rule Library

Display the pre-built rule library. Reference `references/rule-library.md`.

> **Rule Library -- Pre-Built Rules**
>
> Select rules to import (enter numbers, comma-separated):
>
> **Pricing Rules:**
> 1. Volume discount 5% for qty > 500
> 2. Volume discount 10% for qty > 2,000
> 3. Expedite surcharge 10% for lead time < 4 weeks
> 4. New customer setup fee $150
> 5. Repeat order discount 3%
> 6. Platinum customer preferred pricing 5%
> 7. Exotic alloy material surcharge 8%
>
> **Approval Rules:**
> 8. Senior PM approval for quotes > $50K
> 9. Donovan approval for quotes > $100K
> 10. Low margin approval (below 18%)
> 11. New customer large order approval (> $25K)
>
> **Alert Rules:**
> 12. Delivery delay warning (7 days)
> 13. Delivery delay escalation (14 days)
> 14. NCR filed notification
> 15. Payment overdue (30 days)
> 16. High-value RFQ notification (> $75K)
>
> **Routing Rules:**
> 17. Route injection molding to [partner]
> 18. Route 5-axis machining to [partner]
> 19. Route sheet metal to [partner]
>
> **Quality Rules:**
> 20. Enhanced inspection for new customers
> 21. Full inspection for aerospace/medical
> 22. Tighter AQL for Platinum customers
> 23. Quality upgrade for NCR-prone orders
>
> **Workflow Rules:**
> 24. Extra QC checkpoint for complex orders
> 25. Skip repackaging for direct ship
> 26. Engineering review for new designs
> 27. PO verification for orders > $25K
>
> **Customer Rules:**
> 28. Customer-specific packaging template
> 29. Customer communication preferences template
> 30. Credit hold for slow-paying customers
> 31. Auto-apply payment terms by tier
>
> Select rules to import: ___

For each selected rule, confirm and set any required parameters (e.g., partner name for routing rules), then save to rules.yaml.

---

### Mode H: View Rule Evaluation Log

```bash
tail -50 ~/.pmlord/state/rules-eval-log.jsonl 2>/dev/null || echo "No rule evaluations logged yet."
```

Display recent rule evaluations:

| Timestamp | Rule | Triggered By | Context | Action Taken |
|-----------|------|-------------|---------|-------------|
{{#EVAL_LOG}}
| {{EVAL_TS}} | {{EVAL_RULE}} | {{EVAL_SKILL}} | {{EVAL_CONTEXT}} | {{EVAL_ACTION}} |
{{/EVAL_LOG}}

---

## Rule Evaluation (How Other Skills Use Rules)

When any PMLORD skill runs, it should check for applicable rules by calling the rules engine:

```bash
echo '{{CURRENT_CONTEXT_JSON}}' | bash ~/.pmlord/bin/rules-engine.sh --scope "{{SKILL_NAME}}"
```

The engine returns a JSON array of matching rules and their actions. The calling skill must:

1. Parse the returned actions
2. Apply pricing adjustments to the quote
3. Route approval requests to the correct approver
4. Send alerts via pmlord-pulse
5. Modify workflow steps as specified
6. Set quality levels as specified
7. Log every rule application

### Rule Conflict Resolution

When multiple rules match the same context:

1. **Same action type, same direction:** Apply the highest-priority rule (lowest priority number). Log that lower-priority rules were suppressed.
2. **Same action type, conflicting direction:** Flag for PM decision. Present both rules and ask which should apply.
3. **Different action types:** Apply all rules (they are not in conflict). A pricing rule and a quality rule can both apply to the same order.
4. **Equal priority, conflicting:** Always flag for PM decision. Never silently choose.

### Rule Evaluation Logging

Every rule evaluation is logged:

```bash
echo '{"ts":"'$(date -u +%Y-%m-%dT%H:%M:%SZ)'","type":"rule_evaluation","rule_id":"{{RULE_ID}}","rule_name":"{{RULE_NAME}}","triggered":{{TRIGGERED}},"context_skill":"{{SKILL_NAME}}","context_order":"{{ORDER_ID}}","context_customer":"{{CUSTOMER}}","action_taken":"{{ACTION_TAKEN}}"}' >> ~/.pmlord/state/rules-eval-log.jsonl 2>/dev/null || true
```

## Rule Storage

Rules are stored in `~/.pmlord/rules.yaml`. See `references/rule-syntax.md` for the complete schema.

Example rules.yaml:

```yaml
rules:
  - id: "RULE-20260330-0001"
    name: "Volume discount 5%"
    type: pricing
    description: "Apply 5% discount to unit price for orders with quantity over 500"
    trigger:
      field: quantity
      operator: ">"
      value: 500
    action:
      type: pricing_adjustment
      adjustment_type: percentage
      adjustment_value: -5
      apply_to: unit_price
    scope:
      - pmlord-rfq-quote
    priority: 10
    active: true
    created_by: "Donovan Weber"
    created_at: "2026-03-30T00:00:00Z"
    updated_at: "2026-03-30T00:00:00Z"

  - id: "RULE-20260330-0002"
    name: "Senior PM approval for large quotes"
    type: approval
    description: "Require Senior PM sign-off for any quote exceeding $50,000"
    trigger:
      field: total_value
      operator: ">"
      value: 50000
    action:
      type: require_approval
      approver: "Senior PM"
      message: "This quote exceeds $50K and requires Senior PM approval before sending to customer."
    scope:
      - pmlord-rfq-quote
      - pmlord-customer-comms
    priority: 5
    active: true
    created_by: "Donovan Weber"
    created_at: "2026-03-30T00:00:00Z"
    updated_at: "2026-03-30T00:00:00Z"
```

## Template References

- `prompts/rules-system.md` -- Rule definition syntax, evaluation logic, conflict resolution
- `references/rule-syntax.md` -- Complete rule format specification
- `references/rule-library.md` -- 31 pre-built rules ready to import
- `bin/rules-engine.sh` -- Rule evaluation script
