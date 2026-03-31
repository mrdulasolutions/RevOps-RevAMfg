#!/usr/bin/env bash
# =============================================================================
# PMLORD Rules Engine v1.0.0
# =============================================================================
# Evaluates business rules against a context object.
#
# Usage:
#   echo '{"quantity": 750, "customer_tier": "Gold"}' | rules-engine.sh --scope "pmlord-rfq-quote"
#   echo '{"context": "data"}' | rules-engine.sh --test --rule-id "RULE-20260330-0001"
#   rules-engine.sh --list
#   rules-engine.sh --stats
#
# Input:  JSON context object on stdin
# Output: JSON array of matching rules and their actions on stdout
#
# Rules file: ~/.pmlord/rules.yaml
# Eval log:   ~/.pmlord/state/rules-eval-log.jsonl
# =============================================================================

set -euo pipefail

RULES_FILE="${HOME}/.pmlord/rules.yaml"
EVAL_LOG="${HOME}/.pmlord/state/rules-eval-log.jsonl"
STATE_DIR="${HOME}/.pmlord/state"

# --- Defaults ---
SCOPE=""
TEST_MODE=false
TEST_RULE_ID=""
LIST_MODE=false
STATS_MODE=false

# --- Parse arguments ---
while [[ $# -gt 0 ]]; do
  case "$1" in
    --scope)
      SCOPE="$2"
      shift 2
      ;;
    --test)
      TEST_MODE=true
      shift
      ;;
    --rule-id)
      TEST_RULE_ID="$2"
      shift 2
      ;;
    --list)
      LIST_MODE=true
      shift
      ;;
    --stats)
      STATS_MODE=true
      shift
      ;;
    --help|-h)
      echo "PMLORD Rules Engine v1.0.0"
      echo ""
      echo "Usage:"
      echo "  echo '{\"quantity\": 750}' | $0 --scope \"pmlord-rfq-quote\""
      echo "  echo '{\"context\": \"data\"}' | $0 --test --rule-id \"RULE-ID\""
      echo "  $0 --list"
      echo "  $0 --stats"
      echo ""
      echo "Options:"
      echo "  --scope SKILL   Evaluate rules scoped to this skill"
      echo "  --test          Run in test mode (no actions taken, no logging)"
      echo "  --rule-id ID    Test a specific rule only"
      echo "  --list          List all rules and their status"
      echo "  --stats         Show rule evaluation statistics"
      echo "  --help          Show this help message"
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      exit 1
      ;;
  esac
done

# --- Ensure dependencies ---
check_dependency() {
  if ! command -v "$1" &>/dev/null; then
    echo "{\"error\": \"Required command '$1' not found. Install it and retry.\"}"
    exit 1
  fi
}

# We need python3 or jq for JSON processing. Try python3 first (more likely on macOS).
PYTHON=""
if command -v python3 &>/dev/null; then
  PYTHON="python3"
elif command -v python &>/dev/null; then
  PYTHON="python"
fi

# --- Ensure state directory exists ---
mkdir -p "$STATE_DIR"

# --- List mode ---
if $LIST_MODE; then
  if [ ! -f "$RULES_FILE" ]; then
    echo "No rules file found at $RULES_FILE"
    echo "Create rules using: /pmlord-rules"
    exit 0
  fi

  if [ -n "$PYTHON" ]; then
    $PYTHON - "$RULES_FILE" <<'PYEOF'
import sys, json

try:
    import yaml
    with open(sys.argv[1], 'r') as f:
        data = yaml.safe_load(f)
except ImportError:
    # Fallback: basic YAML parsing for simple structures
    print("Note: PyYAML not installed. Install with: pip3 install pyyaml")
    print("Showing raw rules file:")
    with open(sys.argv[1], 'r') as f:
        print(f.read())
    sys.exit(0)

if not data or 'rules' not in data or not data['rules']:
    print("No rules defined.")
    sys.exit(0)

rules = data['rules']
active_count = sum(1 for r in rules if r.get('active', False))
inactive_count = len(rules) - active_count

print(f"{'#':<4} {'ID':<22} {'Name':<35} {'Type':<12} {'Priority':<10} {'Active':<8}")
print("-" * 95)
for i, rule in enumerate(rules, 1):
    rid = rule.get('id', 'N/A')[:20]
    name = rule.get('name', 'Unnamed')[:33]
    rtype = rule.get('type', 'unknown')[:10]
    priority = str(rule.get('priority', 50))
    active = 'YES' if rule.get('active', False) else 'NO'
    print(f"{i:<4} {rid:<22} {name:<35} {rtype:<12} {priority:<10} {active:<8}")

print("-" * 95)
print(f"Total: {len(rules)} rules ({active_count} active, {inactive_count} inactive)")
PYEOF
  else
    echo "Python not available. Displaying raw rules file:"
    cat "$RULES_FILE"
  fi
  exit 0
fi

# --- Stats mode ---
if $STATS_MODE; then
  if [ ! -f "$EVAL_LOG" ]; then
    echo "No evaluation log found. Rules have not been evaluated yet."
    exit 0
  fi

  if [ -n "$PYTHON" ]; then
    $PYTHON - "$EVAL_LOG" <<'PYEOF'
import sys, json
from collections import Counter, defaultdict

log_file = sys.argv[1]
total = 0
triggered = 0
rule_triggers = Counter()
skill_evals = Counter()
customer_triggers = defaultdict(int)

with open(log_file, 'r') as f:
    for line in f:
        line = line.strip()
        if not line:
            continue
        try:
            entry = json.loads(line)
            total += 1
            if entry.get('triggered', False):
                triggered += 1
                rule_triggers[entry.get('rule_name', 'unknown')] += 1
                customer_triggers[entry.get('context_customer', 'unknown')] += 1
            skill_evals[entry.get('context_skill', 'unknown')] += 1
        except json.JSONDecodeError:
            continue

print("PMLORD Rules Engine -- Evaluation Statistics")
print("=" * 60)
print(f"Total evaluations:   {total}")
print(f"Rules triggered:     {triggered}")
print(f"Trigger rate:        {(triggered/total*100):.1f}%" if total > 0 else "N/A")
print()

if rule_triggers:
    print("Top triggered rules:")
    for rule, count in rule_triggers.most_common(10):
        print(f"  {count:>5}x  {rule}")
    print()

if skill_evals:
    print("Evaluations by skill:")
    for skill, count in skill_evals.most_common():
        print(f"  {count:>5}x  {skill}")
    print()

if customer_triggers:
    print("Triggers by customer:")
    for cust, count in customer_triggers.most_common(10):
        print(f"  {count:>5}x  {cust}")
PYEOF
  else
    echo "Python not available. Showing raw log tail:"
    tail -20 "$EVAL_LOG"
  fi
  exit 0
fi

# --- Evaluate mode (default) ---
if [ ! -f "$RULES_FILE" ]; then
  echo '{"matching_rules": [], "message": "No rules file found. Create rules first."}'
  exit 0
fi

# Read context from stdin
CONTEXT=""
if [ ! -t 0 ]; then
  CONTEXT=$(cat)
fi

if [ -z "$CONTEXT" ]; then
  echo '{"error": "No context provided on stdin. Pipe a JSON object to this script."}' >&2
  exit 1
fi

# --- Main evaluation logic (Python) ---
if [ -z "$PYTHON" ]; then
  echo '{"error": "Python is required for rule evaluation. Install python3."}' >&2
  exit 1
fi

$PYTHON - "$RULES_FILE" "$SCOPE" "$TEST_MODE" "$TEST_RULE_ID" "$EVAL_LOG" <<PYEOF "$CONTEXT"
import sys
import json
from datetime import datetime, timezone

rules_file = sys.argv[1]
scope = sys.argv[2]
test_mode = sys.argv[3] == "True"
test_rule_id = sys.argv[4]
eval_log_path = sys.argv[5]
context_json = sys.stdin.read().strip()

# --- Parse context ---
try:
    context = json.loads(context_json)
except json.JSONDecodeError as e:
    print(json.dumps({"error": f"Invalid JSON context: {str(e)}"}))
    sys.exit(1)

# --- Parse rules ---
try:
    import yaml
    with open(rules_file, 'r') as f:
        rules_data = yaml.safe_load(f)
except ImportError:
    # Minimal YAML parser for simple rule files
    # This handles the basic structure we generate
    import re
    rules_data = {"rules": []}
    print(json.dumps({
        "error": "PyYAML not installed. Install with: pip3 install pyyaml",
        "matching_rules": []
    }))
    sys.exit(1)
except FileNotFoundError:
    print(json.dumps({"matching_rules": [], "message": "Rules file not found"}))
    sys.exit(0)

if not rules_data or 'rules' not in rules_data or not rules_data['rules']:
    print(json.dumps({"matching_rules": [], "message": "No rules defined"}))
    sys.exit(0)

rules = rules_data['rules']

# --- Filter rules ---
def rule_in_scope(rule, scope):
    """Check if a rule applies to the given scope."""
    if not scope:
        return True
    rule_scope = rule.get('scope', [])
    if isinstance(rule_scope, str):
        rule_scope = [rule_scope]
    return 'all' in rule_scope or scope in rule_scope

def evaluate_condition(field, operator, value, context):
    """Evaluate a single trigger condition against the context."""
    if field not in context:
        return False

    ctx_val = context[field]

    try:
        if operator == ">":
            return float(ctx_val) > float(value)
        elif operator == "<":
            return float(ctx_val) < float(value)
        elif operator == ">=":
            return float(ctx_val) >= float(value)
        elif operator == "<=":
            return float(ctx_val) <= float(value)
        elif operator == "==":
            if isinstance(value, bool):
                return ctx_val == value
            return str(ctx_val) == str(value)
        elif operator == "!=":
            return str(ctx_val) != str(value)
        elif operator == "contains":
            return str(value).lower() in str(ctx_val).lower()
        elif operator == "starts_with":
            return str(ctx_val).lower().startswith(str(value).lower())
        elif operator == "in":
            if isinstance(value, list):
                return ctx_val in value
            return False
        elif operator == "not_in":
            if isinstance(value, list):
                return ctx_val not in value
            return False
        elif operator == "between":
            if isinstance(value, list) and len(value) == 2:
                return float(value[0]) <= float(ctx_val) <= float(value[1])
            return False
        else:
            return False
    except (ValueError, TypeError):
        return False

def evaluate_trigger(trigger, context):
    """Evaluate a trigger (simple or compound) against the context."""
    if 'logic' in trigger or 'conditions' in trigger:
        # Compound trigger
        logic = trigger.get('logic', 'and').lower()
        conditions = trigger.get('conditions', [])

        results = []
        for cond in conditions:
            if 'logic' in cond or 'conditions' in cond:
                # Nested compound
                results.append(evaluate_trigger(cond, context))
            else:
                results.append(evaluate_condition(
                    cond.get('field', ''),
                    cond.get('operator', '=='),
                    cond.get('value'),
                    context
                ))

        if logic == 'and':
            return all(results)
        elif logic == 'or':
            return any(results)
        return False
    else:
        # Simple trigger
        return evaluate_condition(
            trigger.get('field', ''),
            trigger.get('operator', '=='),
            trigger.get('value'),
            context
        )

# --- Evaluate each rule ---
matching_rules = []
evaluation_results = []
now = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")

for rule in rules:
    rule_id = rule.get('id', 'unknown')

    # Skip inactive rules (unless testing a specific rule)
    if not rule.get('active', False) and test_rule_id != rule_id:
        continue

    # Skip out-of-scope rules
    if not rule_in_scope(rule, scope):
        continue

    # If testing a specific rule, skip others
    if test_rule_id and rule_id != test_rule_id:
        continue

    # Check for expiration
    expires_at = rule.get('expires_at')
    if expires_at:
        try:
            exp_dt = datetime.fromisoformat(expires_at.replace('Z', '+00:00'))
            if datetime.now(timezone.utc) > exp_dt:
                continue
        except (ValueError, AttributeError):
            pass

    # Evaluate trigger
    trigger = rule.get('trigger', {})
    triggered = evaluate_trigger(trigger, context)

    eval_entry = {
        "rule_id": rule_id,
        "rule_name": rule.get('name', 'unnamed'),
        "triggered": triggered,
        "trigger_details": {
            "field": trigger.get('field', trigger.get('logic', 'compound')),
            "operator": trigger.get('operator', ''),
            "value": trigger.get('value', ''),
            "context_value": context.get(trigger.get('field', ''), 'N/A')
        }
    }

    if triggered:
        action = rule.get('action', {})
        match_entry = {
            "rule_id": rule_id,
            "rule_name": rule.get('name', 'unnamed'),
            "rule_type": rule.get('type', 'unknown'),
            "priority": rule.get('priority', 50),
            "action": action,
            "trigger_summary": f"{trigger.get('field', 'compound')} {trigger.get('operator', '')} {trigger.get('value', '')}"
        }
        matching_rules.append(match_entry)
        eval_entry["action"] = action

    evaluation_results.append(eval_entry)

    # Log evaluation (unless in test mode)
    if not test_mode:
        log_entry = {
            "ts": now,
            "type": "rule_evaluation",
            "rule_id": rule_id,
            "rule_name": rule.get('name', 'unnamed'),
            "triggered": triggered,
            "context_skill": scope or context.get('skill', 'unknown'),
            "context_order": context.get('order_id', ''),
            "context_customer": context.get('customer_name', ''),
            "action_taken": json.dumps(rule.get('action', {})) if triggered else "none"
        }
        try:
            with open(eval_log_path, 'a') as f:
                f.write(json.dumps(log_entry) + "\n")
        except IOError:
            pass

# --- Sort matching rules by priority (lower number = higher priority) ---
matching_rules.sort(key=lambda r: r.get('priority', 50))

# --- Conflict detection ---
conflicts = []
action_types = {}
for rule in matching_rules:
    atype = rule.get('action', {}).get('type', 'unknown')
    if atype in action_types:
        # Potential conflict: same action type
        existing = action_types[atype]
        conflicts.append({
            "type": "same_action_type",
            "action_type": atype,
            "rule_1": existing['rule_id'],
            "rule_1_priority": existing['priority'],
            "rule_2": rule['rule_id'],
            "rule_2_priority": rule['priority'],
            "resolution": "higher_priority_wins" if existing['priority'] != rule['priority'] else "pm_decision_required"
        })
    else:
        action_types[atype] = rule

# --- Build output ---
output = {
    "matching_rules": matching_rules,
    "total_evaluated": len(evaluation_results),
    "total_triggered": len(matching_rules),
    "conflicts": conflicts,
    "scope": scope,
    "test_mode": test_mode
}

if test_mode:
    output["evaluation_details"] = evaluation_results

print(json.dumps(output, indent=2, default=str))
PYEOF
