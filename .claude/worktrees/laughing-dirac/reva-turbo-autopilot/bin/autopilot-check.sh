#!/usr/bin/env bash
# autopilot-check.sh — Hook script for REVA-TURBO autopilot transition evaluation
# Called after any skill completes to determine if the next transition should auto-fire.
#
# Usage: ./autopilot-check.sh <entity_id> <completed_skill>
# Example: ./autopilot-check.sh RFQ-2026-0042 reva-turbo-rfq-intake
#
# Exit codes:
#   0 — Auto-transition should fire (AUTO and conditions met)
#   1 — Pause required (PAUSE point or conditions not met)
#   2 — Autopilot not enabled for this entity
#   3 — Error (missing state files, invalid entity, etc.)

set -euo pipefail

ENTITY_ID="${1:-}"
COMPLETED_SKILL="${2:-}"
STATE_DIR="${HOME}/.reva-turbo/state"
CONFIG_FILE="${STATE_DIR}/autopilot-config.jsonl"
WORKFLOW_FILE="${STATE_DIR}/workflow-state.jsonl"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TRANSITION_RULES="${SCRIPT_DIR}/references/transition-rules.md"

# --- Validation ---

if [ -z "$ENTITY_ID" ] || [ -z "$COMPLETED_SKILL" ]; then
    echo '{"error":"Usage: autopilot-check.sh <entity_id> <completed_skill>","exit":3}'
    exit 3
fi

if [ ! -f "$CONFIG_FILE" ]; then
    echo '{"entity_id":"'"$ENTITY_ID"'","autopilot":"not_configured","exit":2}'
    exit 2
fi

# --- Check if autopilot is enabled for this entity ---

# Get the latest config entry for this entity (last matching line wins)
AUTOPILOT_CONFIG=$(grep "\"entity_id\":\"${ENTITY_ID}\"" "$CONFIG_FILE" 2>/dev/null | tail -1)

if [ -z "$AUTOPILOT_CONFIG" ]; then
    echo '{"entity_id":"'"$ENTITY_ID"'","autopilot":"not_enabled","exit":2}'
    exit 2
fi

# Extract mode and enabled status
AUTOPILOT_MODE=$(echo "$AUTOPILOT_CONFIG" | sed -n 's/.*"mode":"\([^"]*\)".*/\1/p')
AUTOPILOT_ENABLED=$(echo "$AUTOPILOT_CONFIG" | sed -n 's/.*"enabled":\([a-z]*\).*/\1/p')

if [ "$AUTOPILOT_ENABLED" != "true" ]; then
    echo '{"entity_id":"'"$ENTITY_ID"'","autopilot":"disabled","mode":"'"$AUTOPILOT_MODE"'","exit":2}'
    exit 2
fi

if [ "$AUTOPILOT_MODE" = "manual" ]; then
    echo '{"entity_id":"'"$ENTITY_ID"'","autopilot":"manual_mode","action":"suggest_only","exit":2}'
    exit 2
fi

# --- Determine the next skill from conductor.json ---

# Strip the "reva-turbo-" prefix for transition rule matching
SHORT_SKILL=$(echo "$COMPLETED_SKILL" | sed 's/^reva-turbo-//')

# Define the transition map (mirrors transition-rules.md)
# Format: from_skill:to_skill:auto_or_pause
declare -A TRANSITIONS
TRANSITIONS["rfq-intake"]="rfq-qualify:AUTO"
TRANSITIONS["rfq-qualify"]="rfq-quote:AUTO"
TRANSITIONS["rfq-qualify-newcust"]="customer-gate:AUTO"
TRANSITIONS["customer-gate"]="rfq-quote:AUTO"
TRANSITIONS["rfq-quote"]="customer-comms:PAUSE"
TRANSITIONS["china-package"]="china-track:AUTO"
TRANSITIONS["china-track-shipped"]="inspect:AUTO"
TRANSITIONS["inspect-accept"]="quality-gate:AUTO"
TRANSITIONS["inspect-reject"]="ncr:AUTO"
TRANSITIONS["quality-gate-pass-repack"]="repackage:AUTO"
TRANSITIONS["quality-gate-pass-direct"]="logistics:AUTO"
TRANSITIONS["quality-gate-conditional"]="repackage:PAUSE"
TRANSITIONS["quality-gate-fail"]="ncr:AUTO"
TRANSITIONS["repackage"]="logistics:AUTO"
TRANSITIONS["logistics-shipped"]="customer-comms:PAUSE"
TRANSITIONS["delivery-confirmed"]="order-track:AUTO"
TRANSITIONS["order-track-closed"]="partner-scorecard:AUTO"

# --- PAUSE POINT CHECK ---
# These skills ALWAYS pause regardless of mode

ALWAYS_PAUSE=("customer-comms" "escalate" "quality-gate" "ncr-disposition")

for pause_skill in "${ALWAYS_PAUSE[@]}"; do
    if [ "$SHORT_SKILL" = "$pause_skill" ]; then
        echo '{"entity_id":"'"$ENTITY_ID"'","completed":"'"$COMPLETED_SKILL"'","action":"PAUSE","reason":"mandatory_pause_point","mode":"'"$AUTOPILOT_MODE"'","ts":"'"$(date -u +%Y-%m-%dT%H:%M:%SZ)"'"}'
        # Log the pause
        echo '{"ts":"'"$(date -u +%Y-%m-%dT%H:%M:%SZ)"'","entity_id":"'"$ENTITY_ID"'","from":"'"$COMPLETED_SKILL"'","trigger":"autopilot_pause","reason":"mandatory_pause_point","mode":"'"$AUTOPILOT_MODE"'"}' >> "$WORKFLOW_FILE" 2>/dev/null || true
        exit 1
    fi
done

# --- Look up the transition ---

TRANSITION_ENTRY="${TRANSITIONS[$SHORT_SKILL]:-}"

if [ -z "$TRANSITION_ENTRY" ]; then
    echo '{"entity_id":"'"$ENTITY_ID"'","completed":"'"$COMPLETED_SKILL"'","action":"no_transition_defined","exit":1}'
    exit 1
fi

NEXT_SKILL=$(echo "$TRANSITION_ENTRY" | cut -d: -f1)
AUTO_FLAG=$(echo "$TRANSITION_ENTRY" | cut -d: -f2)

# --- Evaluate ---

if [ "$AUTO_FLAG" = "PAUSE" ]; then
    echo '{"entity_id":"'"$ENTITY_ID"'","completed":"'"$COMPLETED_SKILL"'","next":"reva-turbo-'"$NEXT_SKILL"'","action":"PAUSE","reason":"transition_requires_approval","mode":"'"$AUTOPILOT_MODE"'","ts":"'"$(date -u +%Y-%m-%dT%H:%M:%SZ)"'"}'
    echo '{"ts":"'"$(date -u +%Y-%m-%dT%H:%M:%SZ)"'","entity_id":"'"$ENTITY_ID"'","from":"'"$COMPLETED_SKILL"'","to":"reva-turbo-'"$NEXT_SKILL"'","trigger":"autopilot_pause","reason":"transition_requires_approval","mode":"'"$AUTOPILOT_MODE"'"}' >> "$WORKFLOW_FILE" 2>/dev/null || true
    exit 1
fi

if [ "$AUTO_FLAG" = "AUTO" ]; then
    CANCEL_WINDOW=0
    if [ "$AUTOPILOT_MODE" = "semi_auto" ]; then
        CANCEL_WINDOW=5
    fi

    echo '{"entity_id":"'"$ENTITY_ID"'","completed":"'"$COMPLETED_SKILL"'","next":"reva-turbo-'"$NEXT_SKILL"'","action":"AUTO_ADVANCE","mode":"'"$AUTOPILOT_MODE"'","cancel_window_minutes":'"$CANCEL_WINDOW"',"ts":"'"$(date -u +%Y-%m-%dT%H:%M:%SZ)"'"}'
    echo '{"ts":"'"$(date -u +%Y-%m-%dT%H:%M:%SZ)"'","entity_id":"'"$ENTITY_ID"'","from":"'"$COMPLETED_SKILL"'","to":"reva-turbo-'"$NEXT_SKILL"'","trigger":"autopilot","mode":"'"$AUTOPILOT_MODE"'","cancel_window":'"$CANCEL_WINDOW"'}' >> "$WORKFLOW_FILE" 2>/dev/null || true
    exit 0
fi

# Fallback
echo '{"entity_id":"'"$ENTITY_ID"'","error":"unknown_transition_flag","flag":"'"$AUTO_FLAG"'","exit":3}'
exit 3
