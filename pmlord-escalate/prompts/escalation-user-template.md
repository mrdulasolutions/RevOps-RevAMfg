# Escalation User Template

Use this template when interacting with the PM about escalations.

## Escalation Trigger Assessment

```
ESCALATION ASSESSMENT

Reference: {{REFERENCE_ID}} ({{CUSTOMER_COMPANY}})
Trigger Type: {{TRIGGER_TYPE}}
Details: {{TRIGGER_DETAILS}}
Severity: {{SEVERITY}}

Escalation Matrix Recommendation: {{RECOMMENDATION}}
Escalate To: {{ESCALATED_TO}}

A) Proceed with escalation
B) Add more context first
C) Handle at current level (requires justification)
```

## Escalation Initiation

```
ESCALATION INITIATED

Escalation ID: {{ESCALATION_ID}}
Reference: {{REFERENCE_ID}}
Customer: {{CUSTOMER_COMPANY}}
Trigger: {{TRIGGER_TYPE}}
Level: {{ESCALATION_LEVEL}}
Escalated To: {{ESCALATED_TO}}
PM: {{PM_NAME}}
Timestamp: {{TIMESTAMP}}

Escalation note generated: {{NOTE_FILENAME}}
```

## Escalation Status Check

```
ESCALATION STATUS: {{ESCALATION_ID}}

Reference: {{REFERENCE_ID}} ({{CUSTOMER_COMPANY}})
Level: {{ESCALATION_LEVEL}}
Escalated To: {{ESCALATED_TO}}
Days Open: {{DAYS_OPEN}}
Status: {{STATUS}}
Last Update: {{LAST_UPDATE}}

A) Log resolution
B) Escalate to next level
C) Add update/note
```

## Resolution

```
ESCALATION RESOLVED: {{ESCALATION_ID}}

Reference: {{REFERENCE_ID}} ({{CUSTOMER_COMPANY}})
Resolution: {{RESOLUTION}}
Resolved By: {{RESOLVED_BY}}
Days to Resolve: {{DAYS_TO_RESOLVE}}
Follow-Up Required: {{FOLLOWUP_REQUIRED}}

All parties notified and audit trail updated.
```
