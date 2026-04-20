# Quick Actions Catalog

Complete reference for all REVA-TURBO quick actions. Each entry includes syntax, examples, what gets pre-filled, what requires confirmation, and which skill is invoked.

---

## 1. quote — Create a Quote

**Syntax:** `quote [customer] [qty] [part] [material]`

**Examples:**
- `quote acme 5000 widget-a aluminum`
- `quote "Acme Corp" 10k bracket`
- `q acme 5k` (uses last part + default material)

**Pre-filled from context:**
- Customer contact info (from customer profile)
- Part specs (from last quote or order)
- Material (from input, last quote, or saved preference)
- Finish (from last quote or saved preference)
- Partner (from customer preferred or saved preference)
- Margin (from saved preference)
- Pricing (calculated from loaded data)

**Requires confirmation:** All pre-filled fields shown for review before generating quote.

**Routes to:** `/reva-turbo:reva-turbo-rfq-quote`

---

## 2. reorder — Duplicate a Previous Order

**Syntax:** `reorder [customer] [PO#]`

**Examples:**
- `reorder acme PO-1234`
- `reorder acme` (uses most recent order)
- `again acme` (shorthand)

**Pre-filled from context:**
- All fields from the original order
- Dates updated to current + original lead time
- Pricing recalculated if >30 days since original quote

**Requires confirmation:** Updated dates and any price changes flagged.

**Routes to:** `/reva-turbo:reva-turbo-rfq-quote` (new quote) then `/reva-turbo:reva-turbo-order-track` (new order)

---

## 3. track — Track an Order

**Syntax:** `track [PO#]`

**Examples:**
- `track ORD-2026-0142`
- `track PO-1234`
- `where's order 142`

**Pre-filled from context:**
- Order details, milestones, current stage
- Partner status from china-track
- Shipping status from logistics

**Requires confirmation:** None (read-only action).

**Routes to:** `/reva-turbo:reva-turbo-china-track`

---

## 4. status — Customer Order Status

**Syntax:** `status [customer]`

**Examples:**
- `status acme`
- `what's open for acme`
- `active orders acme`

**Pre-filled from context:**
- All open orders for the customer
- Current stage, expected dates, any flags

**Requires confirmation:** None (read-only action).

**Routes to:** `/reva-turbo:reva-turbo-dashboard` (filtered by customer)

---

## 5. send update — Send Status Update

**Syntax:** `send update [customer]` or `send update [PO#]`

**Examples:**
- `send update acme`
- `update acme on ORD-2026-0142`
- `email status to john@acme.com`

**Pre-filled from context:**
- Customer contact (from profile)
- Order status summary (from order-track + china-track)
- Milestone progress (from china-track)
- Any flags or delays

**Requires confirmation:** Draft email shown for PM review before sending.

**Routes to:** `/reva-turbo:reva-turbo-customer-comms`

---

## 6. inspect — Generate Inspection Checklist

**Syntax:** `inspect [PO#]`

**Examples:**
- `inspect ORD-2026-0142`
- `qc PO-1234`
- `inspection checklist 142`

**Pre-filled from context:**
- Part specs and drawing references
- Material specifications
- Tolerance requirements
- Previous inspection results (if reorder)
- NCR history for this part/partner

**Requires confirmation:** Checklist items shown for PM review.

**Routes to:** `/reva-turbo:reva-turbo-inspect`

---

## 7. ncr — Create Non-Conformance Report

**Syntax:** `ncr [PO#] [defect description]`

**Examples:**
- `ncr ORD-2026-0142 surface scratches on 50 pcs`
- `ncr PO-1234 out of tolerance on bore diameter`
- `defect 142 wrong material`

**Pre-filled from context:**
- Part number, partner, quantities (from order)
- Inspection criteria (from inspect checklist)
- Partner history (from scorecard)

**Requires confirmation:** NCR details shown for PM review before creating.

**Routes to:** `/reva-turbo:reva-turbo-ncr`

---

## 8. scorecard — Partner Performance Score

**Syntax:** `scorecard [partner]`

**Examples:**
- `scorecard shenzhen`
- `score partner-abc`
- `rating shenzhen mfg`

**Pre-filled from context:**
- Partner performance data
- Quality metrics (NCR rate, on-time delivery, communication)
- Trend over last 6 months

**Requires confirmation:** None (read-only action).

**Routes to:** `/reva-turbo:reva-turbo-partner-scorecard`

---

## 9. escalate — Create Escalation

**Syntax:** `escalate [PO#] [reason]`

**Examples:**
- `escalate ORD-2026-0142 delay exceeds 2 weeks`
- `escalate PO-1234 customer complaint`
- `flag 142 quality issue`

**Pre-filled from context:**
- Order details and current status
- Delay duration (calculated)
- Escalation level (from escalation matrix)
- Recommended recipient

**Requires confirmation:** Escalation details and routing confirmed before submitting.

**Routes to:** `/reva-turbo:reva-turbo-escalate`

---

## 10. dashboard — PM Workload View

**Syntax:** `dashboard`

**Examples:**
- `dashboard`
- `dash`
- `my orders`
- `workload`

**Pre-filled from context:**
- All orders assigned to PM
- Grouped by status/stage
- Flags for overdue, at-risk, action-needed

**Requires confirmation:** None (read-only action).

**Routes to:** `/reva-turbo:reva-turbo-dashboard`

---

## 11. profile — Customer Profile

**Syntax:** `profile [customer]`

**Examples:**
- `profile acme`
- `customer acme corp`
- `account acme`

**Pre-filled from context:**
- Full customer profile with contacts, history, preferences

**Requires confirmation:** None (read-only action).

**Routes to:** `/reva-turbo:reva-turbo-customer-profile`

---

## 12. remind — Set a Reminder

**Syntax:** `remind [order/customer] [date] [message]`

**Examples:**
- `remind ORD-2026-0142 friday follow up on tooling`
- `remind acme next week check on PO status`
- `followup 142 in 3 days`

**Pre-filled from context:**
- Order/customer reference
- Date parsed from natural language

**Requires confirmation:** Reminder details confirmed.

**Routes to:** `/reva-turbo:reva-turbo-reminder`

---

## 13. report — Generate Report

**Syntax:** `report [type] [scope]`

**Examples:**
- `report monthly acme`
- `report quality Q1`
- `report partner shenzhen`
- `report profit ORD-2026-0142`

**Pre-filled from context:**
- Report scope and date range
- Relevant data loaded

**Requires confirmation:** Report parameters confirmed before generating.

**Routes to:** `/reva-turbo:reva-turbo-report`

---

## 14. package — China Package

**Syntax:** `package [PO#]`

**Examples:**
- `package ORD-2026-0142`
- `china package 142`

**Pre-filled from context:**
- Order specs, drawings, quality requirements
- Partner details

**Requires confirmation:** Package contents reviewed before sending.

**Routes to:** `/reva-turbo:reva-turbo-china-package`

---

## 15. logistics — Shipping Status

**Syntax:** `logistics [PO#]`

**Examples:**
- `logistics ORD-2026-0142`
- `shipping status 142`
- `freight 142`

**Pre-filled from context:**
- Shipping method, carrier, tracking
- Estimated arrival, customs status

**Requires confirmation:** None (read-only action).

**Routes to:** `/reva-turbo:reva-turbo-logistics`

---

## 16. qualify — Qualify an RFQ

**Syntax:** `qualify [RFQ description]`

**Examples:**
- `qualify aluminum bracket 10k pcs tight tolerance`
- `can we do titanium medical implant`
- `feasibility check cnc housing`

**Pre-filled from context:**
- Capability match against partner matrix
- Similar past orders

**Requires confirmation:** Qualification result confirmed.

**Routes to:** `/reva-turbo:reva-turbo-rfq-qualify`

---

## 17. gate — Quality Gate Check

**Syntax:** `gate [PO#] [stage]`

**Examples:**
- `gate ORD-2026-0142 tooling`
- `checkpoint 142 production`
- `stage gate 142`

**Pre-filled from context:**
- Gate checklist for the specified stage
- Order specs and requirements

**Requires confirmation:** Gate pass/fail decision confirmed by PM.

**Routes to:** `/reva-turbo:reva-turbo-quality-gate`

---

## 18. audit — Audit Trail

**Syntax:** `audit [reference] [date range]`

**Examples:**
- `audit ORD-2026-0142`
- `audit acme last 30 days`
- `trail 142`

**Pre-filled from context:**
- All audit entries for the reference

**Requires confirmation:** None (read-only action).

**Routes to:** `/reva-turbo:reva-turbo-audit-trail`

---

## 19. profit — Profit Analysis

**Syntax:** `profit [order/customer]`

**Examples:**
- `profit ORD-2026-0142`
- `margin acme`
- `profitability shenzhen orders`

**Pre-filled from context:**
- Revenue, costs, margins for the scope

**Requires confirmation:** None (read-only action).

**Routes to:** `/reva-turbo:reva-turbo-profit`

---

## 20. pulse — System Health

**Syntax:** `pulse`

**Examples:**
- `pulse`
- `system status`
- `health check`

**Pre-filled from context:**
- Sync health, pending actions, overdue items, system status

**Requires confirmation:** None (read-only action).

**Routes to:** `/reva-turbo:reva-turbo-pulse`

---

## 21. change — Change Order

**Syntax:** `change [PO#] [change type] [new value]`

**Examples:**
- `change ORD-2026-0142 quantity 10000`
- `change 142 material steel 304`
- `co 142 delivery 2 weeks earlier`

**Pre-filled from context:**
- Original order values
- Impact analysis initiated automatically

**Requires confirmation:** Full impact analysis reviewed before approving.

**Routes to:** `/reva-turbo:reva-turbo-change-order`

---

## 22. sync — Manual Sync

**Syntax:** `sync [entity] [system]`

**Examples:**
- `sync order ORD-2026-0142`
- `sync customer acme`
- `sync all`

**Pre-filled from context:**
- Entity data from REVA-TURBO
- External system connection status

**Requires confirmation:** Sync results shown.

**Routes to:** `/reva-turbo:reva-turbo-sync`

---

## 23. help — Show Available Commands

**Syntax:** `help` or `commands`

**Examples:**
- `help`
- `what can you do`
- `commands`

Shows this quick actions catalog in summary form.

---

## Meta Commands

These modify behavior rather than executing actions:

| Command | What It Does |
|---------|-------------|
| `set alias [short] = [long]` | Create an abbreviation |
| `set default [field] [value]` | Update saved preference |
| `history` | Show last 10 commands |
| `redo [number]` | Re-run a command from history |
| `undo` | Cancel last action (if possible) |
| `preferences` | Show all saved preferences |
