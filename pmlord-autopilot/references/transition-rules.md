# Autopilot Transition Rules

Complete transition matrix for the PMLORD lifecycle. Each row defines a transition from one skill/stage to the next, whether it should fire automatically, and what conditions must be met.

## Transition Matrix

| # | From | To | Auto? | Condition | Notes |
|---|------|----|-------|-----------|-------|
| T01 | rfq-intake | rfq-qualify | YES | All required fields extracted (customer, contact, part, qty, timeline) | Core intake fields must be present. Missing optional fields are acceptable. |
| T02 | rfq-qualify (PROCEED) | rfq-quote | YES | Qualification gate passed: returning customer OR new customer gate cleared | Qualification result must be PROCEED, not HOLD or REJECT. |
| T03 | rfq-qualify (new customer) | customer-gate | YES | New customer detected during qualification | Auto-route to customer onboarding gate. |
| T04 | customer-gate (APPROVED) | rfq-quote | YES | Customer gate passed, credit and capability confirmed | Only if gate result is APPROVED. |
| T05 | customer-gate (REJECTED) | customer-comms | PAUSE | Customer gate rejected — PM must draft rejection comms | Never auto-send a rejection. PM writes the response. |
| T06 | rfq-quote (generated) | customer-comms | **PAUSE** | Quote requires PM approval before sending to customer | PM reviews quote, adjusts if needed, approves send. |
| T07 | customer-comms (quote sent) | order-track | YES | Quote sent, create order tracker in "awaiting PO" status | Passive tracking until customer responds. |
| T08 | customer accepts (PO received) | china-package | YES | Purchase order received and validated | PO must match quote terms. If discrepancy, PAUSE instead. |
| T09 | china-package (complete) | china-track | YES | Manufacturing package sent to partner | Package must be acknowledged by partner. |
| T10 | china-track (M10: shipped) | inspect | YES | Partner reports goods shipped / in transit | Transition when tracking shows shipment initiated. |
| T11 | inspect (ACCEPT) | quality-gate | YES | Incoming inspection passed | Auto-advance to quality gate for formal gate check. |
| T12 | inspect (REJECT) | ncr | YES | Incoming inspection failed | Auto-create NCR with inspection failure data pre-filled. |
| T13 | quality-gate (PASS) | repackage | YES | Quality gate passed AND order type is inspect-and-forward | Route to repackaging if parts need Rev A repackaging. |
| T14 | quality-gate (PASS) | logistics | YES | Quality gate passed AND order type is direct ship | Route directly to logistics if no repackaging needed. |
| T15 | quality-gate (CONDITIONAL PASS) | repackage or logistics | **PAUSE** | Conditional pass requires PM to review conditions and decide | PM must acknowledge conditions before advancing. |
| T16 | quality-gate (FAIL) | ncr | YES | Quality gate failed | Auto-create NCR with gate failure data. |
| T17 | repackage (complete) | logistics | YES | Repackaging complete, parts ready to ship | Verify pack-out matches customer requirements. |
| T18 | logistics (shipped) | customer-comms | **PAUSE** | Shipment notification needs PM approval before sending | PM reviews tracking info and approves customer notification. |
| T19 | customer-comms (ship notif sent) | order-track (delivery watch) | YES | Shipment notification sent, begin delivery tracking | Passive tracking until delivery confirmed. |
| T20 | delivery confirmed | order-track (close) | YES | Delivery confirmed by carrier or customer | Auto-close the order with final status. |
| T21 | order-track (closed) | partner-scorecard | YES | Order complete, trigger partner score update | Auto-update partner scorecard with order performance data. |

## NEVER AUTO Transitions

The following are NEVER automatic regardless of mode or conditions:

| Action | Reason |
|--------|--------|
| customer-comms (any send) | All customer-facing communications require PM review and explicit approval |
| escalate (any trigger) | PM must be fully informed before any escalation fires |
| quality-gate (decision) | PASS/CONDITIONAL/FAIL decision requires human quality judgment |
| ncr (disposition) | Rework/scrap/return/use-as-is/concession requires PM and quality team |
| rfq-quote (price override) | Any manual price adjustment requires PM sign-off |
| partner-scorecard (score override) | Manual score changes require PM justification |

## Condition Evaluation

When evaluating conditions:

1. **"All required fields extracted"** — Check the skill's output for completeness. The skill's SKILL.md defines what is required vs. optional.
2. **"Gate passed"** — Read the gate result from the skill's output. Must be explicit PASS or PROCEED.
3. **"New customer detected"** — The qualification skill flags this. Check for `new_customer: true` in the output.
4. **"PO received"** — Verify a PO document or PO number exists in the order record.
5. **"Package sent"** — Check china-package skill output for sent confirmation.
6. **"Shipped"** — Check china-track for milestone M10 (shipped from partner).
7. **"Inspection passed/failed"** — Read inspect skill output for ACCEPT or REJECT.
8. **"Repackaging complete"** — Check repackage skill output for completion confirmation.
9. **"Delivery confirmed"** — Carrier tracking or customer confirmation of receipt.

## Conditional Routing

Some transitions have multiple possible destinations:

| From | Condition A | Route A | Condition B | Route B |
|------|-------------|---------|-------------|---------|
| rfq-qualify | Returning customer | rfq-quote | New customer | customer-gate |
| inspect | ACCEPT | quality-gate | REJECT | ncr |
| quality-gate PASS | Inspect-and-forward | repackage | Direct ship | logistics |
| quality-gate | PASS | next stage | FAIL | ncr |

When multiple routes are possible, evaluate conditions in order and take the first match.
