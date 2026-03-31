#!/usr/bin/env bash
# sync-check.sh — PMLORD Sync Health Check
# Checks sync health: last successful sync per channel, pending items, failed items
# Usage: bash sync-check.sh

set -euo pipefail

SYNC_LOG="${HOME}/.pmlord/state/sync-log.jsonl"
SYNC_CONFIG="${HOME}/.pmlord/state/sync-config.yaml"
EMAIL_QUEUE="${HOME}/.pmlord/state/email-queue.jsonl"

echo "============================================"
echo "  PMLORD Sync Health Check"
echo "  $(date -u +%Y-%m-%dT%H:%M:%SZ)"
echo "============================================"
echo ""

# Check if sync log exists
if [ ! -f "$SYNC_LOG" ]; then
    echo "[WARNING] No sync log found at $SYNC_LOG"
    echo "  Sync has never been run. Run /pmlord-sync to configure."
    exit 0
fi

# Check sync config
if [ ! -f "$SYNC_CONFIG" ]; then
    echo "[WARNING] No sync config found at $SYNC_CONFIG"
    echo "  Sync is not configured. Run /pmlord-sync to set up."
    echo ""
fi

# --- Last Sync Per Channel ---
echo "--- Last Sync Per Channel ---"
echo ""

for CHANNEL in hubspot dynamics gmail outlook google-calendar partner; do
    LAST=$(grep "\"target\":\"${CHANNEL}\"\|\"source\":\"${CHANNEL}\"" "$SYNC_LOG" 2>/dev/null | grep '"status":"success"' | tail -1)
    if [ -n "$LAST" ]; then
        TS=$(echo "$LAST" | sed 's/.*"ts":"\([^"]*\)".*/\1/')
        ACTION=$(echo "$LAST" | sed 's/.*"action":"\([^"]*\)".*/\1/')
        echo "  $CHANNEL: Last success at $TS ($ACTION)"
    else
        # Check if channel has any entries at all
        ANY=$(grep "\"target\":\"${CHANNEL}\"\|\"source\":\"${CHANNEL}\"" "$SYNC_LOG" 2>/dev/null | tail -1)
        if [ -n "$ANY" ]; then
            echo "  $CHANNEL: No successful syncs (has entries)"
        fi
    fi
done
echo ""

# --- Pending Items ---
echo "--- Pending Items ---"
echo ""
PENDING_COUNT=$(grep '"status":"pending"' "$SYNC_LOG" 2>/dev/null | wc -l | tr -d ' ')
if [ "$PENDING_COUNT" -gt 0 ]; then
    echo "  $PENDING_COUNT pending sync items:"
    grep '"status":"pending"' "$SYNC_LOG" 2>/dev/null | tail -5 | while IFS= read -r line; do
        TARGET=$(echo "$line" | sed 's/.*"target":"\([^"]*\)".*/\1/')
        ENTITY=$(echo "$line" | sed 's/.*"entity_id":"\([^"]*\)".*/\1/')
        ACTION=$(echo "$line" | sed 's/.*"action":"\([^"]*\)".*/\1/')
        echo "    - $TARGET: $ACTION ($ENTITY)"
    done
    if [ "$PENDING_COUNT" -gt 5 ]; then
        echo "    ... and $((PENDING_COUNT - 5)) more"
    fi
else
    echo "  No pending items."
fi
echo ""

# --- Failed Items ---
echo "--- Failed Items ---"
echo ""
FAILED_COUNT=$(grep '"status":"failed"' "$SYNC_LOG" 2>/dev/null | wc -l | tr -d ' ')
if [ "$FAILED_COUNT" -gt 0 ]; then
    echo "  $FAILED_COUNT failed sync items:"
    grep '"status":"failed"' "$SYNC_LOG" 2>/dev/null | tail -5 | while IFS= read -r line; do
        TARGET=$(echo "$line" | sed 's/.*"target":"\([^"]*\)".*/\1/')
        ENTITY=$(echo "$line" | sed 's/.*"entity_id":"\([^"]*\)".*/\1/')
        DETAILS=$(echo "$line" | sed 's/.*"details":"\([^"]*\)".*/\1/')
        echo "    - $TARGET: $ENTITY — $DETAILS"
    done
    if [ "$FAILED_COUNT" -gt 5 ]; then
        echo "    ... and $((FAILED_COUNT - 5)) more"
    fi
else
    echo "  No failed items."
fi
echo ""

# --- Conflicts ---
echo "--- Open Conflicts ---"
echo ""
CONFLICT_COUNT=$(grep '"status":"conflict"\|"event":"conflict"' "$SYNC_LOG" 2>/dev/null | grep -v '"resolution":"resolved"' | wc -l | tr -d ' ')
if [ "$CONFLICT_COUNT" -gt 0 ]; then
    echo "  $CONFLICT_COUNT unresolved conflicts:"
    grep '"status":"conflict"\|"event":"conflict"' "$SYNC_LOG" 2>/dev/null | grep -v '"resolution":"resolved"' | tail -5 | while IFS= read -r line; do
        FIELD=$(echo "$line" | sed 's/.*"field":"\([^"]*\)".*/\1/')
        ENTITY=$(echo "$line" | sed 's/.*"entity_id":"\([^"]*\)".*/\1/' 2>/dev/null)
        echo "    - $FIELD ($ENTITY)"
    done
else
    echo "  No unresolved conflicts."
fi
echo ""

# --- Email Queue ---
if [ -f "$EMAIL_QUEUE" ]; then
    echo "--- Email Queue ---"
    echo ""
    QUEUE_PENDING=$(grep '"status":"pending_review"' "$EMAIL_QUEUE" 2>/dev/null | wc -l | tr -d ' ')
    if [ "$QUEUE_PENDING" -gt 0 ]; then
        echo "  $QUEUE_PENDING emails pending review:"
        grep '"status":"pending_review"' "$EMAIL_QUEUE" 2>/dev/null | tail -5 | while IFS= read -r line; do
            FROM=$(echo "$line" | sed 's/.*"from":"\([^"]*\)".*/\1/')
            SUBJECT=$(echo "$line" | sed 's/.*"subject":"\([^"]*\)".*/\1/')
            echo "    - From: $FROM — $SUBJECT"
        done
    else
        echo "  Email queue is clear."
    fi
    echo ""
fi

# --- Summary ---
echo "============================================"
TOTAL_TODAY=$(grep "$(date -u +%Y-%m-%d)" "$SYNC_LOG" 2>/dev/null | wc -l | tr -d ' ')
SUCCESS_TODAY=$(grep "$(date -u +%Y-%m-%d)" "$SYNC_LOG" 2>/dev/null | grep '"status":"success"' | wc -l | tr -d ' ')
echo "  Today: $SUCCESS_TODAY successful / $TOTAL_TODAY total sync events"
echo "  Pending: $PENDING_COUNT | Failed: $FAILED_COUNT | Conflicts: $CONFLICT_COUNT"
echo "============================================"
