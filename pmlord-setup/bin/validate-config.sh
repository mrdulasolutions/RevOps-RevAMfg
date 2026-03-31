#!/usr/bin/env bash
# validate-config.sh — Validate PMLORD config files
# Usage: bash validate-config.sh <config-file-path>
# Output: JSON with valid (true/false), errors array, warnings array
set -euo pipefail

CONFIG_FILE="${1:-}"

if [ -z "$CONFIG_FILE" ]; then
  echo '{"valid":false,"errors":["No config file specified"],"warnings":[]}'
  exit 1
fi

if [ ! -f "$CONFIG_FILE" ]; then
  echo '{"valid":false,"errors":["File not found: '"$CONFIG_FILE"'"],"warnings":[]}'
  exit 1
fi

ERRORS=()
WARNINGS=()

# Check for basic YAML validity (simple syntax check)
# Look for common YAML errors: tabs instead of spaces, missing colons
if grep -P '^\t' "$CONFIG_FILE" >/dev/null 2>&1; then
  ERRORS+=("YAML files must use spaces, not tabs for indentation")
fi

# Check for remaining {{PLACEHOLDER}} values
PLACEHOLDERS=$(grep -oP '\{\{[A-Z_]+\}\}' "$CONFIG_FILE" 2>/dev/null | sort -u || true)
if [ -n "$PLACEHOLDERS" ]; then
  PLACEHOLDER_COUNT=$(echo "$PLACEHOLDERS" | wc -l | tr -d ' ')
  WARNINGS+=("$PLACEHOLDER_COUNT unconfigured placeholder(s) found")
  while IFS= read -r ph; do
    WARNINGS+=("Unconfigured: $ph")
  done <<< "$PLACEHOLDERS"
fi

# Check file is not empty
if [ ! -s "$CONFIG_FILE" ]; then
  ERRORS+=("Config file is empty")
fi

# Check file has at least one non-comment, non-blank line
CONTENT_LINES=$(grep -v '^#' "$CONFIG_FILE" 2>/dev/null | grep -v '^$' | wc -l | tr -d ' ')
if [ "$CONTENT_LINES" -eq 0 ]; then
  ERRORS+=("Config file has no content (only comments or blank lines)")
fi

# Build JSON output
VALID="true"
if [ ${#ERRORS[@]} -gt 0 ]; then
  VALID="false"
fi

# Format errors array
ERROR_JSON="[]"
if [ ${#ERRORS[@]} -gt 0 ]; then
  ERROR_JSON="["
  for i in "${!ERRORS[@]}"; do
    [ "$i" -gt 0 ] && ERROR_JSON+=","
    ERROR_JSON+="\"${ERRORS[$i]}\""
  done
  ERROR_JSON+="]"
fi

# Format warnings array
WARN_JSON="[]"
if [ ${#WARNINGS[@]} -gt 0 ]; then
  WARN_JSON="["
  for i in "${!WARNINGS[@]}"; do
    [ "$i" -gt 0 ] && WARN_JSON+=","
    WARN_JSON+="\"${WARNINGS[$i]}\""
  done
  WARN_JSON+="]"
fi

echo "{\"valid\":$VALID,\"errors\":$ERROR_JSON,\"warnings\":$WARN_JSON,\"file\":\"$(basename "$CONFIG_FILE")\"}"
