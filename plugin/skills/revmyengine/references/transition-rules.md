# REVA-TURBO Lifecycle Transition Rules

This document defines the complete lifecycle transition map for the REVA-TURBO PM workflow. For each stage, it specifies the trigger, expected input and output data, HITL and hard gate requirements, next stages, error paths, and autopilot eligibility.

---

## Stage 1: rfq-intake → rfq-qualify

**Trigger:** PM receives a new RFQ from any channel (email, website form, phone, CRM). PM invokes `/reva-turbo:reva-turbo-rfq-intake` or engine auto-detects RFQ email.

**Input data (from PM or source channel):**
| Field | Type | Required |
|-------|------|----------|
| `source_channel` | string | Yes — email / website / phone / crm |
| `customer_name` | string | Yes |
| `customer_email` | string | Yes |
| `customer_company` | string | Yes |
| `part_number` | string | Yes (Rev A PN or customer PN) |
| `part_description` | string | Yes |
| `quantity` | integer | Yes |
| `material` | string | Yes |
| `application` | string | Yes |
| `delivery_date_requested` | date | Yes |
| `attachments_list` | string[] | Optional — drawing filenames, specs |
| `raw_rfq_text` | string | Optional — original email/form text |

**Output data (passed to rfq-qualify):**
| Field | Type |
|-------|------|
| `rfq_id` | string — generated (RFQ-YYYY-NNNN) |
| `customer_name` | string |
| `customer_email` | string |
| `customer_company` | string |
| `part_number` | string |
| `part_description` | string |
| `quantity` | integer |
| `material` | string |
| `application` | string |
| `delivery_date_requested` | date |
| `attachments_list` | string[] |
| `source_channel` | string |
| `intake_ts` | ISO 8601 UTC |

**HITL gate:** Yes — PM confirms RFQ record is accurate before advancing.
**Hard gate:** No — can be re-run if corrections needed.
**Next stage:** rfq-qualify
**Error path:** reva-turbo-escalate (if customer is on restricted list or known bad actor)
**Auto-advance eligible:** No — PM must confirm intake data accuracy.

---

## Stage 2: rfq-qualify → customer-gate (new) OR export-compliance (returning)

**Trigger:** rfq-intake completes and PM advances, or PM invokes `/reva-turbo:reva-turbo-rfq-qualify`.

**Input data (from rfq-intake output):**

All fields from Stage 1 output, plus:
| Field | Type | Required |
|-------|------|----------|
| `rfq_id` | string | Yes |
| `customer_name` | string | Yes |
| `part_description` | string | Yes |
| `quantity` | integer | Yes |
| `material` | string | Yes |
| `application` | string | Yes |
| `delivery_date_requested` | date | Yes |

**Output data (passed to next stage):**

All Stage 1 fields, plus:
| Field | Type |
|-------|------|
| `qualify_score` | integer (0–100) |
| `qualify_outcome` | string — pass / conditional / reject |
| `customer_type` | string — new / returning |
| `credit_status` | string — approved / pending / hold |
| `capability_match` | string — yes / no / conditional |
| `capacity_available` | boolean |
| `qualify_notes` | string |

**HITL gate:** Yes — PM reviews qualify result before advancing. Required if outcome is "conditional" or "reject".
**Hard gate:** No — PM can override qualify score with justification.
**Next stage (normal):** export-compliance (returning customer with approved credit)
**Next stage (conditional):** customer-gate (new customer — must complete onboarding before compliance screen)
**Error path:** reva-turbo-escalate (if qualify outcome is reject — escalate to Senior PM)
**Auto-advance eligible:** Conditional — if returning customer with A/B qualify score and approved credit, autopilot may advance to export-compliance without PM prompt (Trust Level 3 only).

---

## Stage 3: customer-gate → export-compliance

**Trigger:** rfq-qualify identifies a new customer; PM invokes `/reva-turbo:reva-turbo-customer-gate`.

**Input data (from rfq-qualify output):**
| Field | Type | Required |
|-------|------|----------|
| `rfq_id` | string | Yes |
| `customer_name` | string | Yes |
| `customer_email` | string | Yes |
| `customer_company` | string | Yes |
| `customer_type` | string — always "new" at this stage | Yes |

**Output data (passed to export-compliance):**

All rfq-qualify output fields, plus:
| Field | Type |
|-------|------|
| `customer_profile_created` | boolean |
| `nda_status` | string — signed / pending / none |
| `credit_terms` | string — net30 / prepay / cod / other |
| `credit_approved` | boolean |
| `customer_slug` | string — URL-safe customer identifier |
| `onboarding_ts` | ISO 8601 UTC |

**HITL gate:** Yes — PM must confirm customer profile and credit terms.
**Hard gate:** Yes — cannot proceed to quoting without completed customer gate for new customers.
**Next stage:** export-compliance
**Error path:** reva-turbo-escalate (if credit check fails or customer is flagged)
**Auto-advance eligible:** No — always requires PM confirmation for new customer onboarding.

---

## Stage 4: export-compliance → rfq-quote

**Trigger:** Customer gate clears (or rfq-qualify clears for returning customers); PM invokes `/reva-turbo:reva-turbo-export-compliance` or system auto-triggers.

**Input data:**
| Field | Type | Required |
|-------|------|----------|
| `rfq_id` | string | Yes |
| `customer_name` | string | Yes |
| `customer_company` | string | Yes |
| `part_description` | string | Yes |
| `material` | string | Yes |
| `application` | string | Yes |
| `quantity` | integer | Yes |
| `customer_country` | string | Yes — default US |
| `end_use_description` | string | Yes |

**Output data (passed to rfq-quote):**

All prior fields, plus:
| Field | Type |
|-------|------|
| `eccn` | string — ECCN classification (e.g. EAR99, 2B001) |
| `itar_status` | string — controlled / not_controlled |
| `sanctions_clear` | boolean |
| `license_status` | string — no_license_required / license_required / license_granted / denied |
| `exchek_report_path` | string — path to ExChek report file |
| `compliance_cleared` | boolean |
| `compliance_ts` | ISO 8601 UTC |

**HITL gate:** Yes — PM must review compliance finding before advancing to quote.
**Hard gate:** Yes (hard_gate: true in conductor.json) — Cannot proceed to rfq-quote if compliance_cleared is false or license is required and not yet granted.
**Next stage:** rfq-quote (only if compliance_cleared = true)
**Error path:** reva-turbo-escalate (if ITAR controlled, license required, or sanctions flag) → Donovan Weber is final escalation authority per CLIENT.md
**Auto-advance eligible:** No — compliance is always a hard HITL gate regardless of trust level.

---

## Stage 5: rfq-quote → customer-comms (send quote)

**Trigger:** Export compliance clears; PM invokes `/reva-turbo:reva-turbo-rfq-quote`.

**Input data:**
| Field | Type | Required |
|-------|------|----------|
| `rfq_id` | string | Yes |
| `customer_name` | string | Yes |
| `customer_email` | string | Yes |
| `part_number` | string | Yes |
| `part_description` | string | Yes |
| `quantity` | integer | Yes |
| `material` | string | Yes |
| `delivery_date_requested` | date | Yes |
| `eccn` | string | Yes |
| `compliance_cleared` | boolean | Yes — must be true |

**Output data (passed to customer-comms):**
| Field | Type |
|-------|------|
| `quote_id` | string — QTE-YYYY-NNNN |
| `unit_price` | decimal |
| `total_price` | decimal |
| `estimated_cost_breakdown` | object — {partner_quote, tooling, shipping_intl, duties, overhead} |
| `target_margin` | decimal — percentage |
| `lead_time_days` | integer |
| `quote_expiry` | date — default 30 days from issue |
| `payment_terms` | string |
| `quote_doc_path` | string |

**HITL gate:** Yes — PM reviews and approves quote before it is sent to customer. Pricing is confirmed by PM.
**Hard gate:** No — PM can revise and re-generate.
**Next stage:** customer-comms (send quote to customer)
**Error path:** reva-turbo-escalate (if cost estimate exceeds Rev A capacity or margin is below threshold)
**Auto-advance eligible:** No — PM must approve every customer-facing quote.

---

## Stage 6: customer-comms → [await acceptance] → partner-select

**Trigger:** PM approves quote; reva-turbo-customer-comms sends quote email to customer.

**Input data:**
| Field | Type | Required |
|-------|------|----------|
| `quote_id` | string | Yes |
| `customer_email` | string | Yes |
| `quote_doc_path` | string | Yes |
| `quote_expiry` | date | Yes |

**Output data:**
| Field | Type |
|-------|------|
| `comms_sent_ts` | ISO 8601 UTC |
| `comms_type` | string — quote_sent |
| `awaiting_response` | boolean — true |

**HITL gate:** Yes — PM must approve the email text before it is sent. Never auto-send customer communications.
**Hard gate:** No — PM can edit and resend.
**Next stage:** [waiting state] — engine waits for customer PO or acceptance. When acceptance arrives → partner-select.
**Error path:** reva-turbo-cron (quote-followup-check task fires after 5 days of no response)
**Auto-advance eligible:** No — advancement to partner-select requires PM to confirm customer acceptance/PO received.

---

## Stage 7: partner-select → china-package

**Trigger:** Customer accepts quote (PO received); PM invokes `/reva-turbo:reva-turbo-partner-select`.

**Input data:**
| Field | Type | Required |
|-------|------|----------|
| `rfq_id` | string | Yes |
| `quote_id` | string | Yes |
| `customer_name` | string | Yes |
| `part_number` | string | Yes |
| `part_description` | string | Yes |
| `quantity` | integer | Yes |
| `material` | string | Yes |
| `delivery_date_requested` | date | Yes |
| `estimated_cost_breakdown` | object | Yes |
| `target_margin` | decimal | Yes |
| `lead_time_days` | integer | Yes |
| `quote_expiry` | date | Yes |

**Output data (passed to china-package):**

All prior fields, plus:
| Field | Type |
|-------|------|
| `selected_partner` | string — partner name |
| `partner_location` | string |
| `partner_score` | integer (0–100) |
| `selection_rationale` | string |
| `partner_ip_status` | string — nnn / nda / limited / none |
| `alternatives_considered` | string[] |

**HITL gate:** Yes (hard HITL — cannot be bypassed). PM must explicitly confirm partner selection at Step 4 of partner-select.
**Hard gate:** Yes — no partner assigned without PM confirmation.
**Next stage:** china-package
**Error path:** reva-turbo-escalate (if no qualified partner available — escalate to Donovan Weber)
**Auto-advance eligible:** No — partner selection always requires PM confirmation.

---

## Stage 8: china-package → china-track

**Trigger:** Partner selected; PM invokes `/reva-turbo:reva-turbo-china-package`.

**Input data:**

All partner-select output fields.

**Output data (passed to china-track):**
| Field | Type |
|-------|------|
| `package_sent_date` | date |
| `package_contents` | string[] — drawing filenames, spec docs |
| `drawing_revision` | string |
| `special_instructions` | string |
| `tooling_required` | boolean |
| `tooling_approved` | boolean |
| `target_ship_date` | date |
| `partner_po_number` | string |

**HITL gate:** Yes — PM reviews package contents before sending to partner. PM confirms drawing revision and special instructions.
**Hard gate:** No — PM can recall and revise package.
**Next stage:** china-track
**Error path:** reva-turbo-escalate (if partner does not acknowledge package within 48 hours)
**Auto-advance eligible:** Conditional — if Trust Level 3, autopilot may advance to china-track after package sent confirmation is received from partner.

---

## Stage 9: china-track → import-compliance

**Trigger:** Partner confirms production complete and goods ready to ship; PM invokes `/reva-turbo:reva-turbo-china-track` or autopilot monitors.

**Input data:**

All china-package output fields.

**Output data (passed to import-compliance):**
| Field | Type |
|-------|------|
| `ship_date` | date |
| `carrier` | string |
| `tracking_number` | string |
| `port_of_export` | string |
| `eta_port_of_entry` | date |
| `invoice_value` | decimal — USD |
| `invoice_currency` | string — USD / CNY |
| `packing_list_confirmed` | boolean |
| `milestone_log` | object[] — production milestones with dates |

**HITL gate:** Yes — PM reviews final shipment confirmation and invoice value before advancing to import compliance.
**Hard gate:** No — PM can update tracking or delay advancement.
**Next stage:** import-compliance
**Error path:** reva-turbo-escalate (if shipment is delayed beyond SLA, or invoice value differs materially from quote)
**Auto-advance eligible:** Conditional — autopilot may auto-advance to import-compliance at Trust Level 3 when goods ship and tracking number is confirmed.

---

## Stage 10: import-compliance → logistics (routing decision)

**Trigger:** Goods confirmed shipped from China; PM invokes `/reva-turbo:reva-turbo-import-compliance`.

**Input data:**

All china-track output fields.

**Output data (passed to logistics):**
| Field | Type |
|-------|------|
| `hts_codes` | string[] — HTS classification(s) |
| `duty_amount` | decimal — USD |
| `effective_duty_rate` | decimal — percentage |
| `section_301_applies` | boolean |
| `customs_docs_status` | string — complete / pending / exception |
| `isf_filed` | boolean |
| `flow_type` | string — direct / i_and_f |
| `compliance_cleared` | boolean |
| `compliance_ts` | ISO 8601 UTC |

**HITL gate:** Yes — PM reviews duty estimate and customs docs status before proceeding.
**Hard gate:** Yes — cannot proceed to logistics if customs_docs_status is "exception" or compliance_cleared is false.
**Next stage:** logistics
**Error path:** reva-turbo-escalate (if customs exception, denied entry, or duty amount exceeds estimate by >20%)
**Auto-advance eligible:** Conditional — at Trust Level 3, autopilot may advance to logistics if compliance_cleared is true and all docs are complete.

---

## Stage 11: Logistics Path A (Direct) → customer-comms → order-track

**Trigger:** import-compliance clears; logistics routing decision = direct China→Customer.

**Input data:**

All import-compliance output fields, plus:
| Field | Type |
|-------|------|
| `flow_type` | string — "direct" |
| `partner_score` | integer |
| `customer_type` | string |

**Process:**
1. Logistics confirms routing = Direct
2. Partner ships to customer address (customer is consignee, Rev A is notify party and Importer of Record)
3. Customs entry filed to customer address as ultimate consignee
4. Rev A coordinates customs remotely
5. customer-comms — PM approves direct ship notification to customer with tracking
6. order-track — order status advanced to shipped → delivered

**Output data (passed to order-track):**
| Field | Type |
|-------|------|
| `routing_type` | string — "direct" |
| `final_tracking_number` | string |
| `delivery_date_estimated` | date |
| `delivery_date_actual` | date (when confirmed) |
| `customs_entry_number` | string |

**HITL gate:** Yes — PM must approve customer notification before sending.
**Hard gate:** No.
**Next stage:** order-track → profit (closeout) → audit-trail (archive)
**Error path:** reva-turbo-escalate (delivery exception, customs hold, damage in transit)
**Auto-advance eligible:** Conditional — autopilot may file logistics records and update order-track at Trust Level 3, but customer notification always requires PM approval.

---

## Stage 12: Logistics Path B (I&F) → inspect → quality-gate → repackage → logistics (domestic) → customer-comms → order-track

**Trigger:** Logistics routing decision = Inspect & Forward. Triggered by: new customer, C-rated vendor, first production run, ITAR, contract requires Rev A CoC, order value >$50K with no precedent.

**Input data:**

All import-compliance output fields, plus:
| Field | Type |
|-------|------|
| `flow_type` | string — "i_and_f" |
| `i_and_f_trigger` | string — reason for I&F routing |

**Sub-stage sequence:**

**12a. inspect** — Goods arrive at Rev A facility. PM runs incoming inspection. AQL sampling applied per lot size. Disposition: ACCEPT / REJECT / HOLD.
- REJECT → reva-turbo-ncr (non-conformance report filed)
- HOLD → reva-turbo-pulse alert to PM + Senior PM
- ACCEPT → advance to quality-gate

**12b. quality-gate** — G1–G4 gate checks. PM confirms all gates pass.

**12c. repackage** — Goods repackaged and relabeled for customer. Rev A CoC generated.

**12d. logistics (domestic)** — Domestic carrier selected. Shipment to customer.

**12e. customer-comms** — PM approves shipment notification with tracking.

**12f. order-track** — Order advanced to shipped → delivered.

**Output data (passed to order-track):**
| Field | Type |
|-------|------|
| `routing_type` | string — "i_and_f" |
| `inspection_report_path` | string |
| `inspection_disposition` | string — accept |
| `rev_a_coc_path` | string |
| `final_tracking_number` | string |
| `delivery_date_actual` | date |

**HITL gates:** Multiple — inspect disposition, quality gate sign-off, customer notification.
**Hard gates:** inspect (cannot advance on REJECT without NCR), quality-gate (cannot ship on fail).
**Error path:** reva-turbo-ncr (inspection rejection), reva-turbo-escalate (repeat quality failures), reva-turbo-change-order (customer requests modification during I&F)
**Auto-advance eligible:** Conditional — autopilot may advance administrative steps at Trust Level 3. All quality dispositions and customer communications require PM confirmation.

---

## Stage 13: Any Stage → escalate (on hold / block / critical error)

**Trigger:** Any skill encounters a blocking condition, critical error, or PM invokes `/reva-turbo:reva-turbo-escalate`.

**Escalation conditions:**
- Compliance block (export or import)
- Quality rejection with no resolution path
- Partner non-responsive >48 hours
- Delivery delay exceeding customer SLA
- Change order scope beyond PM authority
- Credit or pricing conflict

**Escalation matrix (from CLIENT.md):**
- Senior PM (Ray Yeh / Harley Scott) — operational issues, quality holds, partner issues
- Donovan Weber — compliance escalations, major customer issues, credit decisions above threshold

**Input data:**
| Field | Type |
|-------|------|
| `escalation_type` | string — compliance / quality / partner / delivery / credit / other |
| `escalating_skill` | string |
| `order_id` | string |
| `customer` | string |
| `description` | string |
| `urgency` | string — routine / urgent / critical |

**HITL gate:** Yes — PM confirms escalation before notifying escalation contact.
**Hard gate:** No — PM can un-escalate if issue self-resolves.
**Auto-advance eligible:** No — escalations always require PM initiation.

---

## Stage 14: Any Stage → change-order (on scope change)

**Trigger:** Customer requests a change to part spec, quantity, delivery date, or material. PM invokes `/reva-turbo:reva-turbo-change-order`.

**Input data:**
| Field | Type |
|-------|------|
| `order_id` | string |
| `change_description` | string |
| `change_type` | string — spec / quantity / delivery / material / cancel |
| `current_stage` | string |
| `requested_by` | string — customer / pm / partner |

**Output data:**
| Field | Type |
|-------|------|
| `change_order_id` | string — CO-YYYY-NNNN |
| `impact_cost` | decimal — delta |
| `impact_lead_time` | integer — days delta |
| `change_approved` | boolean |
| `revised_quote_required` | boolean |
| `partner_notification_required` | boolean |

**HITL gate:** Yes — PM reviews impact analysis and approves change before notifying customer or partner.
**Hard gate:** No.
**Next stage:** Returns to appropriate lifecycle stage based on change type (e.g., spec change may return to export-compliance; quantity change may return to rfq-quote).
**Auto-advance eligible:** No — change orders always require PM authorization.

---

## Stage 15: order-track → profit (closeout) → audit-trail (archive)

**Trigger:** Order delivered and confirmed; PM advances to closeout.

**Input data:**

All order delivery fields from final logistics stage.

**profit output:**
| Field | Type |
|-------|------|
| `total_revenue` | decimal |
| `total_cost_actual` | decimal |
| `gross_margin` | decimal — percentage |
| `cost_variance` | decimal — actual vs estimated |
| `profit_report_path` | string |

**audit-trail archive output:**
| Field | Type |
|-------|------|
| `archive_ts` | ISO 8601 UTC |
| `total_audit_entries` | integer |
| `archive_path` | string |
| `retention_expiry` | date — per retention policy |

**HITL gate:** Yes — PM confirms closeout and reviews margin before archiving.
**Hard gate:** No.
**Next stage:** None — order complete.
**Auto-advance eligible:** Conditional — profit calculation may auto-run at Trust Level 3. PM must confirm final margin and archive.

---

## Quick Reference — HITL and Hard Gate Summary

| Stage | HITL Required | Hard Gate | Auto-Advance (L3) |
|-------|--------------|-----------|-------------------|
| rfq-intake | Yes | No | No |
| rfq-qualify | Yes (conditional/reject) | No | Conditional (pass only) |
| customer-gate | Yes | Yes (new customers) | No |
| export-compliance | Yes | Yes | No |
| rfq-quote | Yes | No | No |
| customer-comms (quote send) | Yes | No | No |
| partner-select | Yes | Yes | No |
| china-package | Yes | No | Conditional |
| china-track | Yes | No | Conditional |
| import-compliance | Yes | Yes | Conditional |
| logistics (routing) | Yes | No | Conditional |
| inspect | Yes (disposition) | Yes (reject→NCR) | No |
| quality-gate | Yes | Yes | No |
| repackage | No | No | Yes |
| customer-comms (shipment) | Yes | No | No |
| order-track | No | No | Yes |
| profit (closeout) | Yes | No | Conditional |
| audit-trail (archive) | Yes | No | Conditional |
| escalate | Yes | No | No |
| change-order | Yes | No | No |
