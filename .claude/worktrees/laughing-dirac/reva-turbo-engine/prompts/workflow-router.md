# Workflow Router — Intent Detection Rules

Match user input against these patterns to route to the correct sub-skill.
Use the FIRST match. If ambiguous, ask the user to clarify.

## RFQ Pipeline
- **reva-turbo-rfq-intake**: "new RFQ", "got a quote request", "parse this RFQ", "incoming inquiry", email with RFQ content, "quote request from"
- **reva-turbo-rfq-qualify**: "qualify this", "gate check", "can we do this", "capability check", "is this in scope", "new or returning"
- **reva-turbo-rfq-quote**: "quote this", "price this", "cost estimate", "how much", "generate quote", "pricing for"

## Customer
- **reva-turbo-customer-gate**: "new customer", "onboard", "set up account", "never worked with them"
- **reva-turbo-customer-profile**: "customer info", "pull up profile", "order history", "who is this customer"
- **reva-turbo-customer-comms**: "email the customer", "send update", "acknowledge RFQ", "notify about shipment", "draft response"

## Manufacturing
- **reva-turbo-china-package**: "send to China", "prepare specs", "manufacturing package", "spec package", "drawings for partner"
- **reva-turbo-china-track**: "track order", "manufacturing progress", "where is", "milestone update", "factory status"
- **reva-turbo-partner-scorecard**: "partner performance", "supplier score", "evaluate factory", "partner rating"

## Quality
- **reva-turbo-inspect**: "inspect", "receiving inspection", "check shipment", "incoming QC", "parts arrived"
- **reva-turbo-ncr**: "defect", "non-conformance", "NCR", "reject", "quality issue", "doesn't meet spec"
- **reva-turbo-quality-gate**: "quality gate", "release", "hold", "pass/fail", "gate check"

## Order & Logistics
- **reva-turbo-order-track**: "order status", "PO status", "where is order", "delivery date", "order lifecycle"
- **reva-turbo-logistics**: "ship", "freight", "customs", "logistics", "carrier", "tracking number"
- **reva-turbo-repackage**: "repackage", "relabel", "repack", "packaging", "labeling"

## Reporting
- **reva-turbo-dashboard**: "dashboard", "workload", "overview", "what's open", "my orders"
- **reva-turbo-report**: "report", "weekly summary", "monthly metrics", "quarterly review"
- **reva-turbo-audit-trail**: "audit", "decision log", "trail", "who approved"

## System
- **reva-turbo-escalate**: "escalate", "problem", "urgent", "need help", "stuck"
- **reva-turbo-cron**: "schedule", "recurring", "set up daily check", "automate"
- **reva-turbo-reminder**: "remind me", "follow up", "don't forget", "deadline"
- **reva-turbo-docx**: "convert to Word", "make docx", "export report"
