# Audit Trail User Template

Use this template when interacting with the PM about audit trail actions.

## Log Entry

```
AUDIT TRAIL ENTRY

Action Type: {{ACTION_TYPE}} [decision/approval/override/communication/escalation/correction]
Reference: {{REFERENCE_ID}} (PO or RFQ number)
Customer: {{CUSTOMER_COMPANY}}
Description: {{DESCRIPTION}}
Justification: {{JUSTIFICATION}} (required for overrides/corrections)
PM: {{PM_NAME}}

Log this entry? [Y/N]
```

## Query Results

```
AUDIT TRAIL QUERY: {{QUERY_TYPE}} = "{{QUERY_VALUE}}"
Results: {{RESULT_COUNT}} entries

| # | Timestamp | Type | Reference | Action | PM |
|---|-----------|------|-----------|--------|-----|
| {{RESULT_ROW_1}} |
| {{RESULT_ROW_2}} |
| {{RESULT_ROW_3}} |

[Show full details for entry #? / Export report? / New query?]
```

## Integrity Check

```
AUDIT TRAIL INTEGRITY CHECK

File: ~/.pmlord/state/audit-trail.jsonl
Total Entries: {{TOTAL_ENTRIES}}
File Size: {{FILE_SIZE}}
Last Entry: {{LAST_ENTRY_TS}}
Previous Check: {{PREV_CHECK_TS}} ({{PREV_ENTRIES}} entries)
Status: {{INTEGRITY_STATUS}}
```
