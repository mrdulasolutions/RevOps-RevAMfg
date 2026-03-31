# Sync Field Mappings

Complete bidirectional field mappings between PMLORD and external systems.

---

## PMLORD Order Stage to CRM Deal Stage

### HubSpot Mapping

| PMLORD Order Stage | HubSpot Deal Stage | HubSpot Pipeline |
|-------------------|-------------------|-----------------|
| RFQ Received | Qualification | Sales Pipeline |
| Quote Sent | Quote Sent | Sales Pipeline |
| Quote Follow-up | Negotiation | Sales Pipeline |
| PO Received | Contract Signed | Sales Pipeline |
| Order Placed with Partner | In Production | Fulfillment Pipeline |
| Tooling In Progress | In Production | Fulfillment Pipeline |
| Tooling Approved | In Production | Fulfillment Pipeline |
| First Article | In Production | Fulfillment Pipeline |
| Production Run | In Production | Fulfillment Pipeline |
| QC / Inspection | Quality Check | Fulfillment Pipeline |
| Ready to Ship | Ready to Ship | Fulfillment Pipeline |
| Shipped | Shipped | Fulfillment Pipeline |
| In Transit | Shipped | Fulfillment Pipeline |
| Customs Clearance | Shipped | Fulfillment Pipeline |
| Delivered | Delivered | Fulfillment Pipeline |
| Invoice Sent | Closed Won | Sales Pipeline |
| Payment Received | Closed Won | Sales Pipeline |
| Order Cancelled | Closed Lost | Sales Pipeline |

### Dynamics 365 Mapping

| PMLORD Order Stage | Dynamics Opportunity Stage | Status Reason |
|-------------------|--------------------------|---------------|
| RFQ Received | Qualify | In Progress |
| Quote Sent | Propose | In Progress |
| PO Received | Close | Won |
| In Production | (Custom entity: Order) | Active |
| Shipped | (Custom entity: Order) | Shipped |
| Delivered | (Custom entity: Order) | Delivered |
| Payment Received | Close | Won - Paid |

---

## PMLORD Customer Profile to CRM Account/Contact

### Outbound (PMLORD to CRM)

| PMLORD Field | CRM Field | Sync Direction | Notes |
|-------------|-----------|---------------|-------|
| customer_name | Account Name | Bidirectional | CRM is primary |
| primary_contact.name | Contact Full Name | CRM primary | |
| primary_contact.email | Contact Email | CRM primary | |
| primary_contact.phone | Contact Phone | CRM primary | |
| primary_contact.title | Contact Title | CRM primary | |
| shipping_address | Account Shipping Address | Bidirectional | |
| billing_address | Account Billing Address | Bidirectional | |
| total_orders | Custom: Total Orders | PMLORD primary | |
| total_revenue | Custom: Lifetime Revenue | PMLORD primary | |
| last_order_date | Custom: Last Order Date | PMLORD primary | |
| preferred_partner | Custom: Preferred Partner | PMLORD primary | |
| quality_score | Custom: Quality Score | PMLORD primary | |

### Inbound (CRM to PMLORD)

| CRM Field | PMLORD Field | Auto-Sync? | Notes |
|-----------|-------------|-----------|-------|
| Contact Email (changed) | primary_contact.email | Yes | |
| Contact Phone (changed) | primary_contact.phone | Yes | |
| Contact Title (changed) | primary_contact.title | Yes | |
| New Contact on Account | Add to contacts list | PM confirms | |
| Account Owner changed | assigned_pm | PM confirms | |
| Account Industry | industry | Yes | |
| Account Website | website | Yes | |
| Deal Note added | activity_log | Yes (append) | |

---

## Email Subject Patterns to PMLORD Entity Matching

### RFQ Detection

| Subject Pattern | Confidence | Action |
|----------------|-----------|--------|
| "RFQ" (exact) | High | Create RFQ intake |
| "Request for Quote" | High | Create RFQ intake |
| "Quotation Request" | High | Create RFQ intake |
| "Can you quote" | Medium | Flag for PM review |
| "Pricing for" | Medium | Flag for PM review |
| "Need a price on" | Medium | Flag for PM review |
| "Interested in" + attachment | Low | Flag for PM review |

### PO Detection

| Subject Pattern | Confidence | Action |
|----------------|-----------|--------|
| "PO-\d{4,}" or "PO#\d{4,}" | High | Link to order |
| "Purchase Order" + PDF attachment | High | Link to order |
| "Order confirmation" from customer | Medium | Link to order |
| "Approved" + quote reference | Medium | Link to quote |

### Partner Milestone Detection

| Email Pattern | Milestone | Action |
|--------------|-----------|--------|
| "tooling complete" or "mold ready" | Tooling Complete | Update china-track |
| "first article" or "sample ready" or "T1 sample" | First Article Ready | Update china-track |
| "production start" or "mass production" | Production Started | Update china-track |
| "production complete" or "order ready" | Production Complete | Update china-track |
| "QC passed" or "inspection report" + attachment | QC Complete | Update china-track |
| "shipped" or "shipment" + tracking number | Shipped | Update logistics |
| "packing list" + attachment | Ready to Ship | Update china-track |
| "delay" or "behind schedule" or "push back" | Delay Flag | Alert PM |

---

## PMLORD Activity to CRM Activity Log

| PMLORD Event | CRM Activity Type | CRM Activity Subject |
|-------------|-------------------|---------------------|
| Quote sent | Email | "Quote sent: [Quote ID] - $[Amount]" |
| Status update sent | Email | "Status update: [Order ID]" |
| Meeting scheduled | Meeting | "[Customer] - [Topic]" |
| NCR created | Note | "NCR: [NCR ID] - [Description]" |
| NCR resolved | Note | "NCR Resolved: [NCR ID] - [Resolution]" |
| Escalation created | Note | "ESCALATION: [Description]" |
| Change order approved | Note | "Change Order: [CO#] - [Change]" |
| Order delivered | Note | "Order Delivered: [Order ID]" |
| Payment received | Note | "Payment Received: [Order ID] - $[Amount]" |

---

## Sync Priority

When multiple updates are pending, process in this order:

1. **Financial** — Payment, pricing, invoice updates (highest priority)
2. **Customer-facing** — Status updates, communications, delivery
3. **Operational** — Order stage, milestones, production
4. **Informational** — Contact updates, notes, calendar
5. **Analytics** — Scores, metrics, reports (lowest priority)
