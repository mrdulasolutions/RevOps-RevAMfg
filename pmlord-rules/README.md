# pmlord-rules

Business rules engine for the PMLORD system.

## What It Does

Turns Rev A Manufacturing's tribal knowledge into codified, automatically-enforced business rules:

1. **Create rules** with WHEN/THEN logic covering pricing, approvals, alerts, routing, quality, workflow, and customer-specific behavior
2. **Manage rules** -- edit, enable/disable, delete, view all rules
3. **Test rules** against real historical data before activating
4. **Import rules** from a pre-built library of 25+ common business rules
5. **Evaluate rules** automatically when other PMLORD skills run
6. **Resolve conflicts** when multiple rules match with priority-based ordering
7. **Audit rule application** with complete logging of every evaluation

## Usage

```
/pmlord-rules
```

Select from eight modes: create, edit, disable/enable, delete, view, test, import from library, or view evaluation log.

## How It Works

Rules are stored in `~/.pmlord/rules.yaml`. When any PMLORD skill runs (quoting, order tracking, etc.), it calls the rules engine to check for applicable rules. The engine evaluates all active rules against the current context and returns matching actions.

## Inputs

- Rule definitions (trigger condition, action, scope, priority)
- Context data from other skills (order details, customer data, etc.)
- Historical order data (for testing)

## Outputs

- Rules stored in `~/.pmlord/rules.yaml`
- Rule changes logged to `~/.pmlord/state/rules-log.jsonl`
- Rule evaluations logged to `~/.pmlord/state/rules-eval-log.jsonl`
- Actions returned to calling skills (pricing adjustments, approval requirements, alerts, etc.)

## Files

| File | Purpose |
|------|---------|
| `SKILL.md` | Skill instructions and flow |
| `skill.yaml` | Skill manifest |
| `prompts/rules-system.md` | Rule evaluation logic and conflict resolution |
| `references/rule-syntax.md` | Complete rule definition format and operators |
| `references/rule-library.md` | 25+ pre-built rules organized by category |
| `bin/rules-engine.sh` | Shell script for rule evaluation |

## Integration

Other PMLORD skills integrate with the rules engine by calling:

```bash
echo '{"context": "data"}' | bash ~/.pmlord/bin/rules-engine.sh --scope "skill-name"
```

The engine returns a JSON array of matching rules and their actions.

## Override Protocol

- Low severity rules: PM can override with justification logged
- Medium severity rules: PM can override with justification logged
- High severity rules: Senior PM approval required to override
- Critical severity rules: Donovan Weber approval required to override

All overrides are logged to the audit trail.
