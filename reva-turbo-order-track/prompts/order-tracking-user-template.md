# Order Tracking User Template

Use this template when interacting with the PM about order tracking.

## New Order Initialization

```
I need the following to set up order tracking:

1. PO Number: {{PO_NUMBER}}
2. Customer Company: {{CUSTOMER_COMPANY}}
3. Contact Name: {{CONTACT_NAME}}
4. Contact Email: {{CONTACT_EMAIL}}
5. Part Description: {{PART_DESCRIPTION}}
6. Quantity: {{QUANTITY}}
7. Quoted Price: {{QUOTED_PRICE}}
8. Manufacturing Partner (China): {{MFG_PARTNER}}
9. Expected Ship Date from China: {{EXPECTED_SHIP_DATE}}
10. Customer Delivery Date: {{CUSTOMER_DELIVERY_DATE}}
11. Routing: {{ROUTING_TYPE}} [direct-to-customer / inspect-and-forward]
12. Assigned PM: {{ASSIGNED_PM}}
```

## Stage Advancement

```
Order: {{PO_NUMBER}} ({{CUSTOMER_COMPANY}})
Current Stage: {{CURRENT_STAGE_NUMBER}} - {{CURRENT_STAGE_NAME}}
Advancing to: {{NEW_STAGE_NUMBER}} - {{NEW_STAGE_NAME}}
Evidence: {{TRIGGER_EVIDENCE}}
Next milestone: {{NEXT_STAGE_NAME}} expected by {{NEXT_EXPECTED_DATE}}

Confirm? [Y/N]
```

## Delay Notification

```
DELAY ALERT for {{PO_NUMBER}} ({{CUSTOMER_COMPANY}})

Current Stage: {{CURRENT_STAGE_NAME}}
Delay Reason: {{DELAY_REASON}}
Original Target Date: {{ORIGINAL_DATE}}
Revised Target Date: {{REVISED_DATE}}
Days Delayed: {{DAYS_DELAYED}}
Impact on Customer Delivery: {{DELIVERY_IMPACT}}
Escalation Required: {{ESCALATION_BOOL}}

Action needed: {{RECOMMENDED_ACTION}}
```

## Quick Status Check

```
ORDER STATUS: {{PO_NUMBER}}
Customer: {{CUSTOMER_COMPANY}}
PM: {{ASSIGNED_PM}}
Stage: {{CURRENT_STAGE_NUMBER}}/12 - {{CURRENT_STAGE_NAME}}
Status: {{STATUS_CODE}} - {{STATUS_DESCRIPTION}}
Last Updated: {{LAST_UPDATE_TS}}
Customer Delivery Date: {{CUSTOMER_DELIVERY_DATE}}
On Track: {{ON_TRACK_BOOL}}
```
