# reva-turbo-order-track

Full order lifecycle tracking skill for the REVA-TURBO engine.

## What It Does

Tracks every order through 12 defined stages from purchase order receipt through final closure. The skill:

1. Initializes new order tracking records with all relevant data
2. Manages stage transitions with verification and timestamps
3. Handles delays with impact analysis and escalation triggers
4. Generates formatted status reports
5. Maintains a complete audit trail of all order events

## The 12 Stages

| # | Stage | Description |
|---|-------|-------------|
| 01 | PO Received | Purchase order received from customer |
| 02 | PO Acknowledged | PO confirmed and acknowledged to customer |
| 03 | Specs Sent to China | Manufacturing specs transmitted to China partner |
| 04 | Mfg in Progress | Manufacturing underway at China facility |
| 05 | Mfg Complete | Manufacturing finished, ready to ship |
| 06 | Shipped from China | Product shipped from China |
| 07 | Received at Rev A | Product received at Rev A facility |
| 08 | Inspection Complete | Quality inspection completed |
| 09 | Repackaged | Product repackaged for customer delivery |
| 10 | Shipped to Customer | Product shipped to end customer |
| 11 | Delivered | Customer confirms receipt |
| 12 | Closed | Order closed, all documentation complete |

## Usage

```
/reva-turbo-order-track
```

Or ask REVA-TURBO to check on an order by PO number or customer name.

## Inputs

- PO number, customer information, part details
- Stage transition triggers (emails, tracking updates, inspection reports)
- Delay notifications with reasons

## Outputs

- Order state log at `~/.reva-turbo/orders/{PO_NUMBER}/order-state.jsonl`
- Order status reports
- Audit trail entries

## Files

| File | Purpose |
|------|---------|
| `SKILL.md` | Skill instructions and flow |
| `skill.yaml` | Skill manifest |
| `prompts/order-tracking-system.md` | System prompt for tracking logic |
| `prompts/order-tracking-user-template.md` | User interaction template |
| `references/order-stages.md` | 12-stage pipeline definition |
| `references/status-codes.md` | Status code reference |
| `references/delay-management.md` | Delay handling procedures |
| `templates/Order Status Report.md` | Status report output template |

## Next Step

When delays exceed 2 weeks, the skill recommends running `reva-turbo-escalate`. When inspection is needed, it connects with `reva-turbo-inspect`. For repackaging, it triggers `reva-turbo-repackage`.
