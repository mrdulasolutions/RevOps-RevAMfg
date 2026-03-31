---
name: pmlord-customer-comms
preamble-tier: 2
version: 1.0.0
description: |
  Draft customer communications for Rev A Manufacturing. Supports 5 template types:
  RFQ Acknowledgment, Quote Submission, Order Confirmation, Status Update, and
  Shipment Notification. Uses the Rev A voice: professional, direct, relationship-building.
compatibility: Claude Code, Claude desktop, Claude CoWork
allowed-tools:
  - Bash
  - Read
  - Write
  - Edit
  - Glob
  - Grep
  - AskUserQuestion
---

## Preamble (run first)

```bash
mkdir -p ~/.pmlord/analytics
echo '{"skill":"pmlord-customer-comms","ts":"'$(date -u +%Y-%m-%dT%H:%M:%SZ)'"}' >> ~/.pmlord/analytics/skill-usage.jsonl 2>/dev/null || true
```

## Purpose

Draft professional customer communications for Rev A Manufacturing. Every customer touchpoint should reinforce that Rev A is responsive, reliable, and easy to work with. This skill generates communications from templates, customized for the specific customer and situation.

## Voice

Reference `prompts/comms-system.md` for the full voice guide. Key principles:

- **Professional and direct.** No fluff. Get to the point.
- **Relationship-building.** Warm but not informal. The PM is a trusted partner, not a vendor.
- **Action-oriented.** Every communication should make clear what happens next.
- **Branded.** Consistent Rev A Manufacturing voice across all PMs.

## Flow

### Step 1: Select Communication Type

Determine the type of communication needed:

> What type of customer communication do you need?
>
> A) **RFQ Acknowledgment** — Confirm receipt of an RFQ
> B) **Quote Submission** — Send a completed quote to the customer
> C) **Order Confirmation** — Confirm receipt of a PO and order details
> D) **Status Update** — Provide manufacturing or order status
> E) **Shipment Notification** — Notify customer of shipment with tracking
> F) **Custom** — Other communication (I will help you draft it)

### Step 2: Gather Context

Based on the communication type, gather the required context.

**For all types, confirm:**
- Customer company and contact name
- PM sending the communication
- Any special context or tone adjustments

**Type-specific context:**

**A) RFQ Acknowledgment:**
- RFQ reference number
- Brief description of what was requested
- Expected timeline for quote delivery
- Any initial questions for the customer

**B) Quote Submission:**
- Quote number and RFQ reference
- Quote summary (total, lead time, key terms)
- Any notes or conditions
- Validity period
- Next steps / how to place an order

**C) Order Confirmation:**
- PO number and quote reference
- Order details (parts, quantities, pricing)
- Confirmed lead time and expected delivery
- Payment terms
- PM contact for questions

**D) Status Update:**
- Order/PO reference
- Current stage (in production, finishing, shipping, etc.)
- Estimated completion or delivery date
- Any issues or changes to communicate
- Whether a response is needed from the customer

**E) Shipment Notification:**
- Order/PO reference
- Carrier and tracking number
- Expected delivery date
- Packing list summary
- Delivery instructions or requirements

### Step 3: Draft Communication

Use the appropriate template from the `templates/` directory. Fill all `{{PLACEHOLDER}}` variables with the gathered context.

Reference `references/communication-templates.md` for tone and structure guidelines for each type.

If the situation involves an issue, delay, or bad news, reference `references/escalation-language.md` for appropriate language.

### Step 4: Review and Customize

**HUMAN-IN-THE-LOOP CHECKPOINT:**

Present the drafted communication to the PM:

> Here is the draft {{COMM_TYPE}} for {{CUSTOMER_COMPANY}}:
>
> ---
> {{DRAFT_CONTENT}}
> ---
>
> A) Looks good — ready to send
> B) Make edits (tell me what to change)
> C) Change the tone (more formal / more casual / more urgent)
> D) Start over
> E) Cancel

**Never auto-send a communication.** The PM must review and approve every customer-facing message.

If B, ask for specific edits and revise. If C, adjust tone per the PM's direction and re-present.

### Step 5: Prepare for Sending

After PM approval, prepare the communication:

> Approved. Here is the final communication:
>
> **To:** {{CONTACT_EMAIL}}
> **Subject:** {{EMAIL_SUBJECT}}
> **Body:** [approved content]
>
> How would you like to send this?
> A) Copy to clipboard (I will paste into email)
> B) Save to file for later
> C) Draft in CRM (if integrated)

### Step 6: Log Communication

Log the communication event:

```bash
mkdir -p ~/.pmlord/comms
echo '{"ts":"'$(date -u +%Y-%m-%dT%H:%M:%SZ)'","type":"{{COMM_TYPE}}","customer":"{{CUSTOMER_COMPANY}}","contact":"{{CONTACT_NAME}}","subject":"{{EMAIL_SUBJECT}}","pm":"{{ASSIGNED_PM}}","rfq_id":"{{RFQ_ID}}","order_id":"{{ORDER_ID}}"}' >> ~/.pmlord/comms/comms-log.jsonl 2>/dev/null || true
```

Log the workflow transition:

```bash
echo '{"ts":"'$(date -u +%Y-%m-%dT%H:%M:%SZ)'","customer":"{{CUSTOMER_COMPANY}}","stage":"pmlord-customer-comms","status":"{{COMM_TYPE}}_sent","pm":"{{ASSIGNED_PM}}"}' >> ~/.pmlord/state/workflow-state.jsonl 2>/dev/null || true
```

### Step 7: Suggest Next Step

Based on the communication type, suggest the next workflow step:

| Communication Type | Next Step |
|-------------------|-----------|
| RFQ Acknowledgment | pmlord-rfq-qualify (if not already done) |
| Quote Submission | Wait for customer response; suggest follow-up in 3-5 days |
| Order Confirmation | pmlord-china-package (prepare manufacturing package) |
| Status Update | No specific next step; continue monitoring |
| Shipment Notification | pmlord-order-track (close order after delivery confirmation) |

## Report Naming

```
PMLORD-Comms-{YYYY-MM-DD}-{CustomerShortName}-{Type}.md
```

## Template References

- `prompts/comms-system.md` — Rev A voice and communication guidelines
- `prompts/comms-user-template.md` — Communication input template
- `references/communication-templates.md` — Template structure and tone for each type
- `references/escalation-language.md` — Language for issues, delays, and bad news
- `templates/RFQ Acknowledgment.md` — RFQ acknowledgment template
- `templates/Quote Submission.md` — Quote submission template
- `templates/Order Confirmation.md` — Order confirmation template
- `templates/Status Update.md` — Status update template
- `templates/Shipment Notification.md` — Shipment notification template
