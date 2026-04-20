# Change Order User Template

## Input Variables

```yaml
# --- Order Reference ---
ORDER_ID: "{{ORDER_ID}}"                # e.g., ORD-2026-0142
CUSTOMER: "{{CUSTOMER}}"                # Customer company name
CUSTOMER_CONTACT: "{{CUSTOMER_CONTACT}}" # Primary contact name
CUSTOMER_EMAIL: "{{CUSTOMER_EMAIL}}"     # Contact email
PART_NAME: "{{PART_NAME}}"              # Part name/description
PART_NUMBER: "{{PART_NUMBER}}"           # Part number
CURRENT_REVISION: "{{CURRENT_REVISION}}" # Current revision level (A, B, C...)
CURRENT_STAGE: "{{CURRENT_STAGE}}"       # Current production stage
PARTNER: "{{PARTNER}}"                   # Manufacturing partner
PM_NAME: "{{PM_NAME}}"                   # PM handling the change

# --- Change Details ---
CHANGE_TYPE: "{{CHANGE_TYPE}}"           # quantity_increase, quantity_decrease, material_change,
                                         # tolerance_tightened, tolerance_loosened, finish_change,
                                         # design_revision, date_earlier, date_later,
                                         # add_operation, remove_operation, packaging_change,
                                         # shipping_change

ORIGINAL_VALUE: "{{ORIGINAL_VALUE}}"     # What it was before
NEW_VALUE: "{{NEW_VALUE}}"               # What the customer wants it to be
REASON: "{{REASON}}"                     # Why the change is needed
URGENCY: "{{URGENCY}}"                   # standard, urgent, critical
REQUESTED_BY: "{{REQUESTED_BY}}"         # customer, internal, partner
CUSTOMER_APPROVED_PRICE: "{{CUSTOMER_APPROVED_PRICE}}"  # yes, no, pending, n/a

# --- Impact Analysis Results (populated by engine) ---
COST_DELTA: "{{COST_DELTA}}"             # e.g., "+$2,400" or "-$800"
TIME_DELTA: "{{TIME_DELTA}}"             # e.g., "+5 days" or "no impact"
TOOLING_IMPACT: "{{TOOLING_IMPACT}}"     # e.g., "New cavity needed" or "No impact"
QUALITY_IMPACT: "{{QUALITY_IMPACT}}"     # e.g., "CMM measurement required" or "No impact"
PARTNER_IMPACT: "{{PARTNER_IMPACT}}"     # e.g., "Production restart" or "No impact"
LOGISTICS_IMPACT: "{{LOGISTICS_IMPACT}}" # e.g., "Weight change +2kg" or "No impact"

# --- Change Order Metadata (auto-generated) ---
CO_NUMBER: "{{CO_NUMBER}}"               # e.g., CO-ORD-2026-0142-01
NEW_REVISION: "{{NEW_REVISION}}"         # e.g., Rev B
CO_DATE: "{{CO_DATE}}"                   # Date of change order
DECISION: "{{DECISION}}"                 # approved, rejected, approved_with_modifications
DECISION_NOTES: "{{DECISION_NOTES}}"     # PM notes on decision
```

## Change Request Input Form

Present to PM when capturing a change request:

```
CHANGE ORDER REQUEST

Order: {{ORDER_ID}} — {{CUSTOMER}} — {{PART_NAME}} ({{CURRENT_REVISION}})
Current Stage: {{CURRENT_STAGE}}
Partner: {{PARTNER}}

What changed?
  Change type: ________________
  Original value: ________________ (auto-loaded from order)
  New value: ________________

Why?
  Reason: ________________
  Requested by: [Customer / Internal / Partner]
  Urgency: [Standard / Urgent / Critical]

Has the customer approved a potential price change?
  [Yes / No / Pending / N/A]
```

## Impact Summary Template

Present to PM for decision:

```
CHANGE ORDER IMPACT SUMMARY — {{CO_NUMBER}}

Order: {{ORDER_ID}} — {{CUSTOMER}} — {{PART_NAME}}
Change: {{CHANGE_TYPE}}
  From: {{ORIGINAL_VALUE}}
  To:   {{NEW_VALUE}}
Reason: {{REASON}}
Requested by: {{REQUESTED_BY}}

IMPACT ANALYSIS:
  Cost:      {{COST_DELTA}}
  Lead Time: {{TIME_DELTA}}
  Tooling:   {{TOOLING_IMPACT}}
  Quality:   {{QUALITY_IMPACT}}
  Partner:   {{PARTNER_IMPACT}}
  Logistics: {{LOGISTICS_IMPACT}}

CHANGE FEE: {{CHANGE_FEE}}
REVISED TOTAL: {{NEW_TOTAL}} (was {{ORIG_TOTAL}})
REVISED DELIVERY: {{NEW_DELIVERY}} (was {{ORIG_DELIVERY}})

RECOMMENDATION: {{RECOMMENDATION}}

A) Approve change order
B) Reject change order
C) Approve with modifications
D) Request more analysis
```
