# reva-turbo-customer-comms

Customer communications skill for the REVA-TURBO engine.

## What It Does

Drafts professional customer communications using the Rev A Manufacturing voice. Supports 5 template types:

1. **RFQ Acknowledgment** -- Confirm receipt of an RFQ with expected quote timeline
2. **Quote Submission** -- Send a completed quote with terms and next steps
3. **Order Confirmation** -- Confirm PO receipt with order details and timeline
4. **Status Update** -- Provide manufacturing or delivery status updates
5. **Shipment Notification** -- Notify of shipment with tracking and delivery details

## Usage

```
/reva-turbo-customer-comms
```

Can be invoked at any point in the PM workflow when a customer communication is needed. The REVA-TURBO engine auto-suggests this skill after quote generation and shipment events.

## Inputs

- Communication type (A-E selection)
- Customer and contact information
- Order/RFQ context
- PM review and approval

## Outputs

- Drafted communication ready for PM to send
- Communication logged to `~/.reva-turbo/comms/comms-log.jsonl`
- Workflow state logged

## Key Rule

**Never auto-send.** Every customer-facing communication must be reviewed and approved by the PM before sending.

## Files

| File | Purpose |
|------|---------|
| `SKILL.md` | Skill instructions and flow |
| `skill.yaml` | Skill manifest |
| `prompts/comms-system.md` | Rev A voice and communication guidelines |
| `prompts/comms-user-template.md` | Communication input variables |
| `references/communication-templates.md` | Structure and tone for each type |
| `references/escalation-language.md` | Language for issues and delays |
| `templates/RFQ Acknowledgment.md` | RFQ acknowledgment template |
| `templates/Quote Submission.md` | Quote submission template |
| `templates/Order Confirmation.md` | Order confirmation template |
| `templates/Status Update.md` | Status update template |
| `templates/Shipment Notification.md` | Shipment notification template |
