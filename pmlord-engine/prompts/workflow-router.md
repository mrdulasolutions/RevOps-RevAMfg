# Workflow Router — Intent Detection Rules

Match user input against these patterns to route to the correct sub-skill.
Use the FIRST match. If ambiguous, ask the user to clarify.

## RFQ Pipeline
- **pmlord-rfq-intake**: "new RFQ", "got a quote request", "parse this RFQ", "incoming inquiry", email with RFQ content, "quote request from"
- **pmlord-rfq-qualify**: "qualify this", "gate check", "can we do this", "capability check", "is this in scope", "new or returning"
- **pmlord-rfq-quote**: "quote this", "price this", "cost estimate", "how much", "generate quote", "pricing for"

## Customer
- **pmlord-customer-gate**: "new customer", "onboard", "set up account", "never worked with them"
- **pmlord-customer-profile**: "customer info", "pull up profile", "order history", "who is this customer"
- **pmlord-customer-comms**: "email the customer", "send update", "acknowledge RFQ", "notify about shipment", "draft response"

## Manufacturing
- **pmlord-china-package**: "send to China", "prepare specs", "manufacturing package", "spec package", "drawings for partner"
- **pmlord-china-track**: "track order", "manufacturing progress", "where is", "milestone update", "factory status"
- **pmlord-partner-scorecard**: "partner performance", "supplier score", "evaluate factory", "partner rating"

## Quality
- **pmlord-inspect**: "inspect", "receiving inspection", "check shipment", "incoming QC", "parts arrived"
- **pmlord-ncr**: "defect", "non-conformance", "NCR", "reject", "quality issue", "doesn't meet spec"
- **pmlord-quality-gate**: "quality gate", "release", "hold", "pass/fail", "gate check"

## Order & Logistics
- **pmlord-order-track**: "order status", "PO status", "where is order", "delivery date", "order lifecycle"
- **pmlord-logistics**: "ship", "freight", "customs", "logistics", "carrier", "tracking number"
- **pmlord-repackage**: "repackage", "relabel", "repack", "packaging", "labeling"

## Reporting
- **pmlord-dashboard**: "dashboard", "workload", "overview", "what's open", "my orders"
- **pmlord-report**: "report", "weekly summary", "monthly metrics", "quarterly review"
- **pmlord-audit-trail**: "audit", "decision log", "trail", "who approved"

## System
- **pmlord-escalate**: "escalate", "problem", "urgent", "need help", "stuck"
- **pmlord-cron**: "schedule", "recurring", "set up daily check", "automate"
- **pmlord-reminder**: "remind me", "follow up", "don't forget", "deadline"
- **pmlord-docx**: "convert to Word", "make docx", "export report"
