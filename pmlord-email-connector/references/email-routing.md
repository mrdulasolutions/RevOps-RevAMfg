# Email Routing Reference

## Known Sender Domains

### Customer Domains
Maintain a list of known customer email domains. Emails from these domains are likely order-related or RFQ-related.

### Partner Domains
Maintain a list of known China manufacturing partner domains. Emails from these domains are likely production updates or shipping notifications.

### Freight / Logistics Domains
| Domain Pattern | Company |
|---------------|---------|
| @dhl.com | DHL Express |
| @fedex.com | FedEx |
| @ups.com | UPS |
| @flexport.com | Flexport |
| @dbschenker.com | DB Schenker |
| @expeditors.com | Expeditors |

### Internal Domains
| Domain | Source |
|--------|--------|
| @revamfg.com | Rev A Manufacturing (internal) |

## Routing Decision Tree

```
1. Is the sender from a known partner domain?
   YES -> Route to pmlord-order-track (partner update)
   NO -> Continue

2. Does the subject/body mention a quality issue?
   YES -> Route to pmlord-ncr or pmlord-escalate
   NO -> Continue

3. Does the email contain an RFQ or quote request?
   YES -> Route to pmlord-rfq-intake
   NO -> Continue

4. Does the email reference an existing PO number?
   YES -> Route to pmlord-order-track
   NO -> Continue

5. Does the email contain shipping/tracking information?
   YES -> Route to pmlord-logistics
   NO -> Continue

6. Does the email reference invoices/payments?
   YES -> Route to pmlord-order-track (payment)
   NO -> Continue

7. Is the email from a customer or potential customer?
   YES -> Route to pmlord-customer-comms
   NO -> Classify as irrelevant/spam
```

## Email Processing Frequency

| Mode | When | Action |
|------|------|--------|
| Morning scan | Start of business day | Process all unread emails from overnight |
| Midday check | After lunch | Quick scan for urgent items |
| On-demand | PM requests | Check for specific emails or senders |

## Deduplication Strategy

Track processed emails by:
- Email message ID (if available from MCP tool)
- Combination of sender + subject + date (if message ID not available)

Store in `~/.pmlord/state/email-routing-log.jsonl` and check before processing.

## Attachment Handling

| Attachment Type | Action |
|----------------|--------|
| PDF (drawing/spec) | Flag for PM review, associate with RFQ/order |
| DWG/STEP/IGES (CAD) | Flag for PM review, note file name |
| XLSX/CSV (data) | Flag for PM review |
| PDF (invoice/PO) | Extract PO number, flag for PM review |
| Images (JPG/PNG) | May be quality evidence, flag if from quality context |
| Other | Note but do not process |

## Privacy and Data Handling

1. Do not store full email bodies in log files
2. Store only: sender, subject, classification, routing, timestamp
3. Do not forward emails to external systems without PM approval
4. Treat all customer communications as confidential
