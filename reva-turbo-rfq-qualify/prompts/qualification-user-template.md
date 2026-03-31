# Qualification User Template

Input variables for RFQ qualification gate checks.

## From Intake Record

- **{{RFQ_ID}}** — RFQ identifier
- **{{CUSTOMER_COMPANY}}** — Customer company name
- **{{CUSTOMER_TYPE}}** — New or Returning
- **{{CONTACT_NAME}}** — Primary contact
- **{{PART_DESCRIPTION}}** — Part or assembly description
- **{{MANUFACTURING_PROCESS}}** — Required process type
- **{{MATERIAL}}** — Material specification
- **{{FINISH}}** — Finish/coating requirements
- **{{TOLERANCES}}** — Critical tolerances
- **{{QUANTITY}}** — Requested quantity (all tiers)
- **{{DELIVERY_TIMELINE}}** — Customer requested delivery
- **{{TARGET_PRICE}}** — Customer target price
- **{{SPECIAL_REQUIREMENTS}}** — Certifications, testing, etc.
- **{{QUALITY_REQUIREMENTS}}** — Quality documentation requirements
- **{{EXPORT_CONTROL}}** — Export control flags
- **{{ASSIGNED_PM}}** — PM assigned to this RFQ
- **{{DRAWING_REF}}** — Drawing/CAD references
- **{{PRIORITY}}** — Priority level

## Gate Check Variables (generated during qualification)

- **{{GATE_1_RESULT}}** — Customer Status result (PASS / FLAG / NEW)
- **{{GATE_1_DETAIL}}** — Customer history summary or new customer flags
- **{{GATE_2_RESULT}}** — Capability Match result (FULL MATCH / PARTIAL MATCH / NO MATCH)
- **{{GATE_2_DETAIL}}** — Capability assessment detail
- **{{GATE_3_SCORE}}** — Complexity score (1-5)
- **{{GATE_3_LEVEL}}** — Complexity level (Simple / Low / Medium / High / Critical)
- **{{GATE_3_DETAIL}}** — Complexity rationale
- **{{GATE_4_RESULT}}** — Capacity result (Available / Tight / Unavailable)
- **{{GATE_4_DETAIL}}** — Capacity and timeline assessment
- **{{GATE_5_RESULT}}** — Credit result (Clear / Pending / Risk)
- **{{GATE_5_DETAIL}}** — Credit assessment detail

## Decision Variables

- **{{DECISION}}** — PROCEED / CONDITIONAL / DECLINE
- **{{RATIONALE}}** — Decision rationale
- **{{CONDITIONS}}** — Conditions for CONDITIONAL decision (if applicable)
- **{{NEXT_SKILL}}** — Recommended next skill in workflow
- **{{ESCALATION_NEEDED}}** — Whether escalation to Donovan Weber is recommended
