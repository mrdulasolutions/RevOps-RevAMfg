#!/usr/bin/env bash
# rules-evaluate.sh — Load and display current rules state
# Usage: bash rules-evaluate.sh [category]
set -euo pipefail

STATE_DIR="${REVA-TURBO_STATE_DIR:-$HOME/.reva-turbo}"
RULES_FILE="$STATE_DIR/state/rules.yaml"

CATEGORY="${1:-all}"

if [ ! -f "$RULES_FILE" ]; then
  echo "NO_CUSTOM_RULES"
  echo "Only built-in rules are active. Custom rules file not found at $RULES_FILE"
  exit 0
fi

if [ "$CATEGORY" = "all" ]; then
  echo "=== Custom Rules ==="
  cat "$RULES_FILE"
else
  echo "=== Custom Rules: $CATEGORY ==="
  # Extract rules for category (simple grep-based filter)
  awk "/category: ${CATEGORY}/,/^- rule_id:|^$/" "$RULES_FILE" 2>/dev/null || echo "No custom rules for category: $CATEGORY"
fi
