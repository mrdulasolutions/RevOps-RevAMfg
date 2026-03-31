#!/usr/bin/env bash
# trust-check.sh — Read current effective trust level
# Usage: bash trust-check.sh [--user <pm-slug>] [--skill <skill-name>] [--entity <type>:<id>]
# Output: JSON with level (1/2/3), name (learn/assist/operate), source (system/user/skill/entity)
#
# Specificity chain: entity > skill > user > system > default
# Safety caps are applied after resolution.
set -euo pipefail

STATE_DIR="${HOME}/.reva-turbo/state"
USERS_DIR="${HOME}/.reva-turbo/users"

# Parse arguments
USER_SLUG=""
SKILL_NAME=""
ENTITY_TYPE=""
ENTITY_ID=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --user)
      USER_SLUG="$2"
      shift 2
      ;;
    --skill)
      SKILL_NAME="$2"
      shift 2
      ;;
    --entity)
      ENTITY_TYPE="${2%%:*}"
      ENTITY_ID="${2#*:}"
      shift 2
      ;;
    *)
      echo "Unknown argument: $1" >&2
      exit 1
      ;;
  esac
done

# Helper: map level number to name
level_name() {
  case "$1" in
    1) echo "learn" ;;
    2) echo "assist" ;;
    3) echo "operate" ;;
    *) echo "unknown" ;;
  esac
}

# Safety caps: skill -> max level
safety_cap() {
  local skill="$1"
  case "$skill" in
    reva-turbo-export-compliance) echo 2 ;;
    reva-turbo-import-compliance) echo 2 ;;
    reva-turbo-quality-gate)      echo 2 ;;
    reva-turbo-inspect)           echo 2 ;;
    *)                        echo 3 ;;
  esac
}

# --- Resolution chain ---

RESOLVED_LEVEL=""
RESOLVED_SOURCE=""

# 1. Check entity override (most specific)
if [[ -n "$ENTITY_TYPE" && -n "$ENTITY_ID" && -f "${STATE_DIR}/trust-overrides.jsonl" ]]; then
  # Read overrides file, find last active entry for this entity
  ENTITY_MATCH=$(grep "\"entity_type\":\"${ENTITY_TYPE}\"" "${STATE_DIR}/trust-overrides.jsonl" 2>/dev/null \
    | grep "\"entity_id\":\"${ENTITY_ID}\"" \
    | grep '"active":true' \
    | tail -1 || true)

  if [[ -n "$ENTITY_MATCH" ]]; then
    # Check expiry
    EXPIRES=$(echo "$ENTITY_MATCH" | sed -n 's/.*"expires":"\([^"]*\)".*/\1/p' || true)
    NOW=$(date -u +%Y-%m-%dT%H:%M:%SZ)
    if [[ -z "$EXPIRES" || "$EXPIRES" == "null" || "$NOW" < "$EXPIRES" ]]; then
      RESOLVED_LEVEL=$(echo "$ENTITY_MATCH" | sed -n 's/.*"level":\([0-9]*\).*/\1/p')
      RESOLVED_SOURCE="entity:${ENTITY_TYPE}:${ENTITY_ID}"
    fi
  fi
fi

# 2. Check skill override
if [[ -z "$RESOLVED_LEVEL" && -n "$SKILL_NAME" && -f "${STATE_DIR}/trust-overrides.jsonl" ]]; then
  SKILL_MATCH=$(grep "\"type\":\"skill\"" "${STATE_DIR}/trust-overrides.jsonl" 2>/dev/null \
    | grep "\"skill\":\"${SKILL_NAME}\"" \
    | grep '"active":true' \
    | tail -1 || true)

  if [[ -n "$SKILL_MATCH" ]]; then
    EXPIRES=$(echo "$SKILL_MATCH" | sed -n 's/.*"expires":"\([^"]*\)".*/\1/p' || true)
    NOW=$(date -u +%Y-%m-%dT%H:%M:%SZ)
    if [[ -z "$EXPIRES" || "$EXPIRES" == "null" || "$NOW" < "$EXPIRES" ]]; then
      RESOLVED_LEVEL=$(echo "$SKILL_MATCH" | sed -n 's/.*"level":\([0-9]*\).*/\1/p')
      RESOLVED_SOURCE="skill:${SKILL_NAME}"
    fi
  fi
fi

# 3. Check per-user override
if [[ -z "$RESOLVED_LEVEL" && -n "$USER_SLUG" && -f "${USERS_DIR}/${USER_SLUG}/trust-level.json" ]]; then
  RESOLVED_LEVEL=$(sed -n 's/.*"level":\([0-9]*\).*/\1/p' "${USERS_DIR}/${USER_SLUG}/trust-level.json" | head -1)
  if [[ -n "$RESOLVED_LEVEL" ]]; then
    RESOLVED_SOURCE="user:${USER_SLUG}"
  fi
fi

# 4. Check system default
if [[ -z "$RESOLVED_LEVEL" && -f "${STATE_DIR}/trust-level.json" ]]; then
  RESOLVED_LEVEL=$(sed -n 's/.*"level":\([0-9]*\).*/\1/p' "${STATE_DIR}/trust-level.json" | head -1)
  if [[ -n "$RESOLVED_LEVEL" ]]; then
    RESOLVED_SOURCE="system"
  fi
fi

# 5. Hard default: Level 1 LEARN
if [[ -z "$RESOLVED_LEVEL" ]]; then
  RESOLVED_LEVEL=1
  RESOLVED_SOURCE="default"
fi

# Apply safety cap if a skill is specified
CAPPED="false"
ORIGINAL_LEVEL="$RESOLVED_LEVEL"
if [[ -n "$SKILL_NAME" ]]; then
  MAX_LEVEL=$(safety_cap "$SKILL_NAME")
  if [[ "$RESOLVED_LEVEL" -gt "$MAX_LEVEL" ]]; then
    RESOLVED_LEVEL="$MAX_LEVEL"
    CAPPED="true"
  fi
fi

RESOLVED_NAME=$(level_name "$RESOLVED_LEVEL")

# Output JSON
cat <<EOF
{
  "level": ${RESOLVED_LEVEL},
  "name": "${RESOLVED_NAME}",
  "source": "${RESOLVED_SOURCE}",
  "capped": ${CAPPED},
  "original_level": ${ORIGINAL_LEVEL},
  "skill": "${SKILL_NAME}",
  "user": "${USER_SLUG}",
  "entity_type": "${ENTITY_TYPE}",
  "entity_id": "${ENTITY_ID}"
}
EOF
