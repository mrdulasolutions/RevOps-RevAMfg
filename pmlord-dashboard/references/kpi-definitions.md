# KPI Definitions

## 1. On-Time Delivery Rate (OTD)

**Formula:** (Orders delivered on or before promised date / Total orders delivered) x 100

**Measurement Period:** Trailing 90 days

**Data Source:** `~/.pmlord/orders/*/order-state.jsonl` — compare `customer_delivery_date` (promised) vs actual delivery timestamp at Stage 11.

**Target:** >= 95%
**Warning:** 90-94%
**Critical:** < 90%

**Notes:** An order is "on time" if delivered on or before the date promised to the customer at PO acknowledgment. If the customer agrees to a revised date, use the revised date.

## 2. Quality Rate

**Formula:** (Orders with zero NCRs / Total orders completed) x 100

**Measurement Period:** Trailing 90 days

**Data Source:** `~/.pmlord/state/ncr-log.jsonl` cross-referenced with completed orders.

**Target:** >= 98%
**Warning:** 95-97%
**Critical:** < 95%

## 3. RFQ Response Time

**Formula:** Average business days from RFQ receipt to quote delivery

**Measurement Period:** Trailing 90 days

**Data Source:** `~/.pmlord/state/workflow-state.jsonl` — timestamp delta between `pmlord-rfq-intake` complete and `pmlord-rfq-quote` complete.

**Target:** <= 2 business days
**Warning:** 3-4 business days
**Critical:** >= 5 business days

## 4. RFQ Conversion Rate

**Formula:** (Quotes accepted by customer / Total quotes sent) x 100

**Measurement Period:** Trailing 90 days

**Data Source:** `~/.pmlord/state/workflow-state.jsonl` — count of RFQs reaching "won" status vs total reaching "quoted" status.

**Target:** >= 30%
**Warning:** 20-29%
**Critical:** < 20%

## 5. Average Lead Time

**Formula:** Average calendar days from PO received (Stage 01) to delivered (Stage 11)

**Measurement Period:** Trailing 90 days

**Data Source:** `~/.pmlord/orders/*/order-state.jsonl` — timestamp delta between Stage 01 and Stage 11.

**Target:** <= 45 calendar days
**Warning:** 46-60 calendar days
**Critical:** > 60 calendar days

**Notes:** Separate by routing type (direct vs inspect-and-forward) for meaningful comparison.

## 6. Partner Average Score

**Formula:** Weighted average of all active partner scorecard grades

**Data Source:** `~/.pmlord/state/partner-scores.jsonl`

**Grading Scale:**
- A+ = 4.3, A = 4.0, A- = 3.7
- B+ = 3.3, B = 3.0, B- = 2.7
- C+ = 2.3, C = 2.0, C- = 1.7
- D = 1.0, F = 0.0

**Target:** >= 3.3 (B+)
**Warning:** 2.7-3.2 (B- to B)
**Critical:** < 2.7 (C+ or below)

## 7. Open Escalations

**Formula:** Count of escalations with status "open"

**Data Source:** `~/.pmlord/state/escalation-log.jsonl`

**Target:** 0
**Warning:** 1-2
**Critical:** 3+

## 8. PM Workload

**Formula:** Count of active orders assigned to each PM

**Data Source:** `~/.pmlord/state/workflow-state.jsonl` filtered by `pm` field and `status:"active"`.

**Guideline:** Each PM should manage 10-20 active orders. Above 20 indicates overload.

## 9. Revenue in Pipeline

**Formula:** Sum of quoted prices for all active orders (Stage 01-11)

**Data Source:** Order records with quoted price field.

**Display:** Total and broken down by stage grouping:
- Early (Stages 01-03): PO to specs sent
- Manufacturing (Stages 04-05): In production
- Transit (Stages 06-07): Shipping
- Final (Stages 08-12): Inspection through closure

## 10. RFQ Pipeline Value

**Formula:** Sum of estimated values for all open RFQs not yet converted to orders

**Data Source:** `~/.pmlord/rfqs/*/intake-record.md` — extract estimated value field.
