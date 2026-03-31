#!/usr/bin/env bash
# pulse-check.sh — Scan REVA-TURBO state files for alert-triggering conditions
# Called by reva-turbo-cron on a schedule or manually via /reva-turbo-pulse
#
# Usage: ./pulse-check.sh [pm_name]
# Example: ./pulse-check.sh Sarah
#
# Outputs JSON alert records to stdout. Each line is one detected alert condition.
# The calling skill (reva-turbo-pulse) handles delivery and filtering.
#
# Exit codes:
#   0 — Scan complete (alerts may or may not have been found)
#   1 — Error (missing state directory, invalid config)

set -euo pipefail

PM_NAME="${1:-default}"
STATE_DIR="${HOME}/.reva-turbo/state"
ALERTS_FILE="${STATE_DIR}/pulse-alerts.jsonl"
NOW=$(date -u +%Y-%m-%dT%H:%M:%SZ)
NOW_EPOCH=$(date +%s)
ALERT_COUNT=0

# --- Validation ---

if [ ! -d "$STATE_DIR" ]; then
    echo '{"error":"State directory not found","path":"'"$STATE_DIR"'","ts":"'"$NOW"'"}'
    exit 1
fi

mkdir -p "$STATE_DIR"

# --- Helper: Calculate days between two ISO timestamps ---
days_since() {
    local target_date="$1"
    # Extract date portion and convert to epoch
    local target_epoch
    target_epoch=$(date -j -f "%Y-%m-%dT%H:%M:%SZ" "$target_date" +%s 2>/dev/null || date -d "$target_date" +%s 2>/dev/null || echo "0")
    if [ "$target_epoch" = "0" ]; then
        echo "0"
        return
    fi
    echo $(( (NOW_EPOCH - target_epoch) / 86400 ))
}

# --- Alert sequence counter ---
next_alert_id() {
    ALERT_COUNT=$((ALERT_COUNT + 1))
    printf "PULSE-%05d" "$ALERT_COUNT"
}

# --- SCAN 1: Workflow State — Detect stale stages (DELAY_DETECTED) ---

WORKFLOW_FILE="${STATE_DIR}/workflow-state.jsonl"
if [ -f "$WORKFLOW_FILE" ]; then
    # Find entities that have been in the same stage for >3 days
    # Get the latest entry per entity
    while IFS= read -r line; do
        entity_id=$(echo "$line" | sed -n 's/.*"entity_id":"\([^"]*\)".*/\1/p')
        current_stage=$(echo "$line" | sed -n 's/.*"current_stage":"\([^"]*\)".*/\1/p')
        ts=$(echo "$line" | sed -n 's/.*"ts":"\([^"]*\)".*/\1/p')
        customer=$(echo "$line" | sed -n 's/.*"customer":"\([^"]*\)".*/\1/p')

        if [ -n "$entity_id" ] && [ -n "$ts" ]; then
            days=$(days_since "$ts")
            if [ "$days" -gt 3 ]; then
                alert_id=$(next_alert_id)
                echo '{"ts":"'"$NOW"'","alert_id":"'"$alert_id"'","alert_type":"DELAY_DETECTED","alert_code":"ALT-001","priority":"CRITICAL","entity_id":"'"$entity_id"'","entity_type":"order","customer":"'"$customer"'","message":"'"$entity_id"' has been in stage '"$current_stage"' for '"$days"' days (>3 day threshold)","pm":"'"$PM_NAME"'","status":"pending","action_required":"Review order status and contact partner","relevant_skill":"reva-turbo-order-track"}'
            fi
        fi
    done < <(sort -t'"' -k4 "$WORKFLOW_FILE" 2>/dev/null | awk -F'"entity_id":"' '{print $2}' | sort -t'"' -k1,1 -u | while read -r eid_rest; do grep "\"entity_id\":\"$(echo "$eid_rest" | cut -d'"' -f1)\"" "$WORKFLOW_FILE" | tail -1; done 2>/dev/null)
fi

# --- SCAN 2: Active RFQs — Detect expiring quotes (QUOTE_EXPIRING) ---

RFQS_FILE="${STATE_DIR}/active-rfqs.jsonl"
if [ -f "$RFQS_FILE" ]; then
    while IFS= read -r line; do
        rfq_id=$(echo "$line" | sed -n 's/.*"rfq_id":"\([^"]*\)".*/\1/p')
        quote_expires=$(echo "$line" | sed -n 's/.*"quote_expires":"\([^"]*\)".*/\1/p')
        customer=$(echo "$line" | sed -n 's/.*"customer":"\([^"]*\)".*/\1/p')
        status=$(echo "$line" | sed -n 's/.*"status":"\([^"]*\)".*/\1/p')

        if [ -n "$quote_expires" ] && [ "$status" = "quote_sent" ]; then
            days_until_expire=$(days_since "$quote_expires")
            # days_since returns positive for past dates, negative would mean future
            # For expiring soon, we need to check if it's within 3 days
            if [ "$days_until_expire" -le 0 ] && [ "$days_until_expire" -ge -3 ]; then
                alert_id=$(next_alert_id)
                echo '{"ts":"'"$NOW"'","alert_id":"'"$alert_id"'","alert_type":"QUOTE_EXPIRING","alert_code":"ALT-007","priority":"WARNING","entity_id":"'"$rfq_id"'","entity_type":"rfq","customer":"'"$customer"'","message":"Quote for '"$rfq_id"' expires in '"$((-days_until_expire))"' days","pm":"'"$PM_NAME"'","status":"pending","action_required":"Follow up with customer or extend quote","relevant_skill":"reva-turbo-customer-comms"}'
            fi
        fi
    done < "$RFQS_FILE"
fi

# --- SCAN 3: Active Orders — Detect overdue invoices (PAYMENT_OVERDUE) ---

INVOICES_FILE="${STATE_DIR}/invoices.jsonl"
if [ -f "$INVOICES_FILE" ]; then
    while IFS= read -r line; do
        invoice_id=$(echo "$line" | sed -n 's/.*"invoice_id":"\([^"]*\)".*/\1/p')
        due_date=$(echo "$line" | sed -n 's/.*"due_date":"\([^"]*\)".*/\1/p')
        customer=$(echo "$line" | sed -n 's/.*"customer":"\([^"]*\)".*/\1/p')
        paid=$(echo "$line" | sed -n 's/.*"paid":\([a-z]*\).*/\1/p')
        entity_id=$(echo "$line" | sed -n 's/.*"order_id":"\([^"]*\)".*/\1/p')

        if [ -n "$due_date" ] && [ "$paid" != "true" ]; then
            days_overdue=$(days_since "$due_date")
            if [ "$days_overdue" -gt 30 ]; then
                alert_id=$(next_alert_id)
                echo '{"ts":"'"$NOW"'","alert_id":"'"$alert_id"'","alert_type":"PAYMENT_OVERDUE","alert_code":"ALT-003","priority":"CRITICAL","entity_id":"'"$entity_id"'","entity_type":"order","customer":"'"$customer"'","message":"Invoice '"$invoice_id"' is '"$days_overdue"' days past due (>30 day threshold)","pm":"'"$PM_NAME"'","status":"pending","action_required":"Escalate to Senior PM. Contact customer AP.","relevant_skill":"reva-turbo-escalate"}'
            fi
        fi
    done < "$INVOICES_FILE"
fi

# --- SCAN 4: NCR Log — Detect new NCRs (NCR_ISSUED) ---

NCR_FILE="${STATE_DIR}/ncr-log.jsonl"
if [ -f "$NCR_FILE" ]; then
    while IFS= read -r line; do
        ncr_id=$(echo "$line" | sed -n 's/.*"ncr_id":"\([^"]*\)".*/\1/p')
        ncr_ts=$(echo "$line" | sed -n 's/.*"ts":"\([^"]*\)".*/\1/p')
        ncr_status=$(echo "$line" | sed -n 's/.*"status":"\([^"]*\)".*/\1/p')
        entity_id=$(echo "$line" | sed -n 's/.*"order_id":"\([^"]*\)".*/\1/p')
        customer=$(echo "$line" | sed -n 's/.*"customer":"\([^"]*\)".*/\1/p')

        if [ -n "$ncr_ts" ] && [ "$ncr_status" = "open" ]; then
            days_open=$(days_since "$ncr_ts")
            if [ "$days_open" -le 1 ]; then
                alert_id=$(next_alert_id)
                echo '{"ts":"'"$NOW"'","alert_id":"'"$alert_id"'","alert_type":"NCR_ISSUED","alert_code":"ALT-002","priority":"CRITICAL","entity_id":"'"$entity_id"'","entity_type":"order","customer":"'"$customer"'","message":"New NCR '"$ncr_id"' issued for '"$entity_id"'","pm":"'"$PM_NAME"'","status":"pending","action_required":"Review NCR and determine disposition","relevant_skill":"reva-turbo-ncr"}'
            fi
        fi
    done < "$NCR_FILE"
fi

# --- SCAN 5: Partner Scores — Detect score drops (PARTNER_SCORE_DROP) ---

PARTNER_FILE="${STATE_DIR}/partner-scores.jsonl"
if [ -f "$PARTNER_FILE" ]; then
    while IFS= read -r line; do
        partner=$(echo "$line" | sed -n 's/.*"partner":"\([^"]*\)".*/\1/p')
        grade=$(echo "$line" | sed -n 's/.*"grade":"\([^"]*\)".*/\1/p')
        prev_grade=$(echo "$line" | sed -n 's/.*"previous_grade":"\([^"]*\)".*/\1/p')

        if [ "$grade" = "D" ] || [ "$grade" = "F" ]; then
            alert_id=$(next_alert_id)
            echo '{"ts":"'"$NOW"'","alert_id":"'"$alert_id"'","alert_type":"PARTNER_SCORE_DROP","alert_code":"ALT-009","priority":"WARNING","entity_id":"'"$partner"'","entity_type":"partner","message":"Partner '"$partner"' score dropped to '"$grade"' (from '"$prev_grade"')","pm":"'"$PM_NAME"'","status":"pending","action_required":"Review partner scorecard. Consider sourcing alternatives.","relevant_skill":"reva-turbo-partner-scorecard"}'
        fi
    done < "$PARTNER_FILE"
fi

# --- SCAN 6: PM Workload — Detect capacity warning ---

ORDERS_FILE="${STATE_DIR}/active-orders.jsonl"
if [ -f "$ORDERS_FILE" ]; then
    active_count=$(grep -c "\"pm\":\"${PM_NAME}\"" "$ORDERS_FILE" 2>/dev/null || echo "0")
    if [ "$active_count" -gt 15 ]; then
        alert_id=$(next_alert_id)
        echo '{"ts":"'"$NOW"'","alert_id":"'"$alert_id"'","alert_type":"CAPACITY_WARNING","alert_code":"ALT-010","priority":"WARNING","entity_id":"'"$PM_NAME"'","entity_type":"pm","message":"PM '"$PM_NAME"' has '"$active_count"' active orders (>15 threshold)","pm":"'"$PM_NAME"'","status":"pending","action_required":"Consider redistributing orders or requesting support","relevant_skill":"reva-turbo-dashboard"}'
    fi
fi

# --- Summary ---

echo '{"scan_complete":true,"ts":"'"$NOW"'","pm":"'"$PM_NAME"'","alerts_generated":'"$ALERT_COUNT"'}'
