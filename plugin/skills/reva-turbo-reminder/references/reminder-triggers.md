# Reminder Trigger Definitions

## RFQ / Quote Reminders

### Quote No-Response Follow-Up
- **Trigger ID:** `quote-no-response`
- **Trigger Event:** Quote sent to customer
- **Fire At:** T+3 business days (3 business days after quote was sent)
- **Condition:** Customer has not responded (no acceptance, rejection, or questions)
- **Priority:** Medium
- **Action:** Follow up with customer via email. Draft using reva-turbo-customer-comms.
- **Suggested Message:** "We sent a quote for [part description] on [date]. Wanted to check if you have any questions or need any adjustments."
- **Repeat:** Fire again at T+5 if still no response
- **Escalation:** If no response by T+10, flag for PM review — customer may not be interested

### Quote Expiration Warning
- **Trigger ID:** `quote-expiration`
- **Trigger Event:** Quote expiration date approaching
- **Fire At:** T-5 calendar days (5 days before expiration)
- **Condition:** Quote is still open (not accepted, rejected, or withdrawn)
- **Priority:** Medium
- **Action:** Notify customer that quote expires soon. Offer to extend if needed.
- **Suggested Message:** "Your quote for [part description] expires on [date]. Let us know if you need an extension or have any questions."
- **Repeat:** Fire again at T-2 if still open
- **Escalation:** On expiration date, mark quote as expired

## Order / Delivery Reminders

### Delivery Approaching (T-7)
- **Trigger ID:** `delivery-t7`
- **Trigger Event:** Customer delivery date
- **Fire At:** T-7 calendar days
- **Condition:** Order is active and not yet at Stage 10 (Shipped to Customer)
- **Priority:** Medium
- **Action:** Review order status. If order is not on track to deliver on time, flag as at-risk.
- **Internal Action:** Check current stage against expected timeline. If behind, initiate delay management.

### Delivery Approaching (T-3)
- **Trigger ID:** `delivery-t3`
- **Trigger Event:** Customer delivery date
- **Fire At:** T-3 calendar days
- **Condition:** Order is active and not yet at Stage 11 (Delivered)
- **Priority:** High
- **Action:** Confirm shipment is on schedule. If not shipped yet, this is urgent.
- **If At Stage 10:** Verify tracking shows on-time delivery
- **If Before Stage 10:** Flag as at-risk, consider expediting

### Delivery Tomorrow (T-1)
- **Trigger ID:** `delivery-t1`
- **Trigger Event:** Customer delivery date
- **Fire At:** T-1 calendar day
- **Condition:** Order is active and not yet at Stage 11 (Delivered)
- **Priority:** Critical
- **Action:** Final delivery confirmation. Verify tracking shows delivery for tomorrow.
- **If Not Shipped:** Immediate escalation required

### Post-Delivery Satisfaction Check
- **Trigger ID:** `post-delivery-satisfaction`
- **Trigger Event:** Delivery confirmed (Stage 11)
- **Fire At:** T+3 business days after delivery
- **Condition:** Order is at Stage 11, satisfaction check not yet logged
- **Priority:** Medium
- **Action:** Contact customer to confirm satisfaction. Ask about product quality, packaging, communication.
- **Suggested Message:** "Your order [PO number] was delivered on [date]. We want to make sure everything met your expectations. Any feedback?"
- **Log Result:** Satisfied / Minor issue / Major issue. If issue, trigger appropriate workflow.

## Quality Reminders

### Inspection Due
- **Trigger ID:** `inspection-due`
- **Trigger Event:** Product received at Rev A (Stage 07)
- **Fire At:** T+1 business day after receipt
- **Condition:** Order is at Stage 07, inspection not yet started
- **Priority:** High
- **Action:** Schedule and begin inspection. Do not let product sit unexamined.
- **Repeat:** Daily until inspection is started
- **Escalation:** If not inspected within 3 business days, flag to Senior PM

### NCR Corrective Action Due
- **Trigger ID:** `ncr-corrective-due`
- **Trigger Event:** NCR corrective action deadline
- **Fire At:** T-3 business days before deadline
- **Condition:** NCR is open, corrective action not yet completed
- **Priority:** High
- **Action:** Follow up with responsible party (partner or internal) on corrective action progress.
- **Repeat:** Fire again at T-1
- **Escalation:** If deadline passes without completion, escalate via reva-turbo-escalate

## Partner Reminders

### Partner Status Request
- **Trigger ID:** `partner-status-request`
- **Trigger Event:** Order at Stage 04 (Mfg in Progress) for more than 7 days without update
- **Fire At:** Every 7 calendar days while at Stage 04
- **Condition:** No status update received from partner in the last 7 days
- **Priority:** Medium
- **Action:** Request manufacturing status update from partner
- **Suggested Message:** "Requesting status update on PO [PO number]. Please confirm current production status, expected completion date, and any issues."

## Reminder Priority Levels

| Priority | Urgency | Example |
|----------|---------|---------|
| Critical | Action needed today | Delivery tomorrow, not shipped |
| High | Action needed within 1-2 days | Inspection due, NCR deadline approaching |
| Medium | Action needed this week | Quote follow-up, partner status request |
| Low | Informational | Quote expiration in 5 days |

## Snooze Rules

| Snooze Count | Allowed | Next Fire |
|-------------|---------|-----------|
| 1st snooze | Yes | +1 business day |
| 2nd snooze | Yes | +1 business day |
| 3rd snooze | Yes (last chance) | +1 business day |
| 4th attempt | No snooze | Must acknowledge or dismiss with documented reason |

## Deduplication

A reminder is considered already fired if the reminder-log.jsonl contains an entry with:
- Same `trigger` ID
- Same `ref` (PO/RFQ number)
- Status is not "snoozed" or the snooze_until date has passed
- Fired within the current trigger window
