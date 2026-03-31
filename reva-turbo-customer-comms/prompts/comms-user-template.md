# Communications User Template

Variables for customer communication drafting.

## Common Variables (all communication types)

- **{{COMM_TYPE}}** — Communication type (RFQ Acknowledgment, Quote Submission, Order Confirmation, Status Update, Shipment Notification)
- **{{CUSTOMER_COMPANY}}** — Customer company name
- **{{CONTACT_NAME}}** — Recipient name
- **{{CONTACT_EMAIL}}** — Recipient email
- **{{ASSIGNED_PM}}** — PM name (sender)
- **{{PM_EMAIL}}** — PM email address
- **{{PM_PHONE}}** — PM phone number
- **{{EMAIL_SUBJECT}}** — Email subject line
- **{{TONE}}** — Tone setting (Standard, Formal, Urgent, Apologetic)
- **{{DATE}}** — Communication date

## RFQ Acknowledgment Variables

- **{{RFQ_ID}}** — RFQ reference number
- **{{RFQ_DESCRIPTION}}** — Brief description of what was requested
- **{{QUOTE_TIMELINE}}** — When to expect the quote (e.g., "within 2-3 business days")
- **{{INITIAL_QUESTIONS}}** — Any clarifying questions for the customer
- **{{DRAWINGS_RECEIVED}}** — Whether drawings/files were received with the RFQ

## Quote Submission Variables

- **{{QUOTE_NUMBER}}** — Quote reference number
- **{{RFQ_ID}}** — Original RFQ reference
- **{{PART_DESCRIPTION}}** — Part description
- **{{QUANTITY}}** — Quoted quantity
- **{{UNIT_PRICE}}** — Per-unit price
- **{{TOTAL_PRICE}}** — Total quote amount
- **{{TOOLING_PRICE}}** — Tooling/NRE cost (if applicable)
- **{{LEAD_TIME}}** — Estimated lead time
- **{{PAYMENT_TERMS}}** — Payment terms
- **{{QUOTE_VALIDITY}}** — Quote expiration date
- **{{QUOTE_NOTES}}** — Additional notes or conditions
- **{{HOW_TO_ORDER}}** — Instructions for placing an order

## Order Confirmation Variables

- **{{PO_NUMBER}}** — Customer PO number
- **{{QUOTE_NUMBER}}** — Referenced quote number
- **{{ORDER_DETAILS}}** — Part, quantity, pricing summary
- **{{CONFIRMED_DELIVERY}}** — Confirmed delivery date or lead time
- **{{PAYMENT_TERMS}}** — Confirmed payment terms
- **{{PRODUCTION_START}}** — When production will begin
- **{{NEXT_UPDATE}}** — When customer can expect next status update

## Status Update Variables

- **{{ORDER_REFERENCE}}** — PO or order reference
- **{{CURRENT_STAGE}}** — Current production/fulfillment stage
- **{{STAGE_DETAIL}}** — Detail on current stage progress
- **{{ESTIMATED_COMPLETION}}** — Estimated completion of current stage
- **{{ESTIMATED_DELIVERY}}** — Updated estimated delivery date
- **{{ISSUES}}** — Any issues to communicate (delays, changes, questions)
- **{{ACTION_NEEDED}}** — Whether customer action is needed
- **{{NEXT_UPDATE_DATE}}** — When to expect the next update

## Shipment Notification Variables

- **{{ORDER_REFERENCE}}** — PO or order reference
- **{{CARRIER}}** — Shipping carrier name
- **{{TRACKING_NUMBER}}** — Tracking number
- **{{TRACKING_URL}}** — Tracking URL (if available)
- **{{SHIP_DATE}}** — Date shipped
- **{{ESTIMATED_ARRIVAL}}** — Estimated delivery date
- **{{PACKING_LIST}}** — Summary of items shipped
- **{{BOXES_PALLETS}}** — Number of boxes or pallets
- **{{WEIGHT}}** — Total shipment weight
- **{{DELIVERY_INSTRUCTIONS}}** — Special delivery notes
- **{{INVOICE_NOTE}}** — Invoice reference or note
