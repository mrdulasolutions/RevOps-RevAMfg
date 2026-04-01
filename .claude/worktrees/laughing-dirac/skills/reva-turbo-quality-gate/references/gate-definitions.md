# Quality Gate Definitions

## Gate Philosophy

Quality gates are mandatory checkpoints that parts must pass through before advancing to the next stage. Gates exist to:

1. Catch defects before they reach the customer.
2. Ensure documentation completeness at each stage.
3. Create an auditable quality record.
4. Provide clear go/no-go decision points.

No parts advance past a failed gate. Conditional passes are exceptions, not the norm.

---

## G1 — Incoming Gate

### Purpose

Verify that parts received from the manufacturing partner meet specifications and are properly documented before entering Rev A inventory or processing.

### When to Run

Immediately after incoming inspection (`/reva-turbo:reva-turbo-inspect`) is complete.

### Checklist

| # | Check | Critical? | Description |
|---|-------|-----------|-------------|
| 1 | Incoming inspection complete | Yes | `/reva-turbo:reva-turbo-inspect` report exists and is finalized |
| 2 | Inspection disposition is ACCEPT | Yes | Disposition must be ACCEPT (not HOLD or REJECT) |
| 3 | Critical dimensions verified | Yes | All [CRITICAL] tagged dimensions measured and in tolerance |
| 4 | Material certification received | Yes | CoC received, material grade matches spec |
| 5 | Quantity correct | Yes | Received qty matches PO (within +/- 5% or contract terms) |
| 6 | No open NCRs | Yes | No unresolved NCRs against this shipment |
| 7 | Partner QC report reviewed | No | Partner's own QC report reviewed and cross-checked |
| 8 | Packing list accurate | No | Packing list matches what was received |
| 9 | Parts properly stored | No | Parts in correct location, properly protected |
| 10 | Drawing revision matches | No | Parts made to the correct drawing revision |

### Pass Criteria

- All critical checks (1-6) must PASS.
- Non-critical checks (7-10) should PASS or have documented justification for N/A.
- Any critical check FAIL = Gate FAIL.

---

## G2 — In-Process Gate

### Purpose

Verify quality during any Rev A processing (rework, secondary operations, sub-assembly, finishing).

### When to Run

After Rev A completes any value-add processing. Skip if parts go directly from G1 to G3 (inspect-and-forward model).

### Checklist

| # | Check | Critical? | Description |
|---|-------|-----------|-------------|
| 1 | G1 passed | Yes | G1 gate record exists with PASS decision |
| 2 | Work order documented | Yes | Work order or routing exists and was followed |
| 3 | First piece approved | Yes | First piece checked and approved before full run (if applicable) |
| 4 | In-process dims checked | Yes | Dimensional checks per routing/work order |
| 5 | Process parameters in control | Yes | Temperature, speed, pressure, etc. within spec |
| 6 | No handling damage | No | Parts free of damage from Rev A processing |
| 7 | Traceability maintained | No | Lot/batch numbers tracked through processing |
| 8 | Rework documented | No | If rework performed, documentation and re-inspection complete |

### Pass Criteria

- All critical checks (1-5) must PASS.
- Non-critical checks (6-8) should PASS or N/A.
- If check 3 is N/A (no first piece needed), document why.

---

## G3 — Final Gate

### Purpose

Final quality verification before parts are prepared for customer shipment. This is the last quality checkpoint.

### When to Run

After all processing is complete and before packaging/shipping preparation begins.

### Checklist

| # | Check | Critical? | Description |
|---|-------|-----------|-------------|
| 1 | All prior gates passed | Yes | G1 (and G2 if applicable) records show PASS |
| 2 | Final dimensional inspection | Yes | Complete dimensional inspection or verification |
| 3 | Visual inspection passed | Yes | No cosmetic defects, correct finish/color |
| 4 | Functional check passed | Yes | Assembly, fit, function verified (if applicable) |
| 5 | Customer requirements verified | Yes | All customer-specific requirements checked |
| 6 | CoC prepared | Yes | Certificate of Conformance drafted with correct data |
| 7 | All NCRs resolved | Yes | No open NCRs — all closed or dispositioned |
| 8 | Test reports complete | No | Any required test reports (material, dimensional, functional) |
| 9 | Matches approved sample | No | Parts match customer-approved sample (if applicable) |
| 10 | Customer labeling met | No | Customer-specific labeling requirements satisfied |

### Pass Criteria

- All critical checks (1-7) must PASS.
- Non-critical checks (8-10) should PASS or N/A.
- CoC must be accurate and ready for inclusion in shipment.

---

## G4 — Pre-Ship Gate

### Purpose

Final verification before parts leave the Rev A dock. Focus on packaging, documentation, and shipping readiness.

### When to Run

After packaging is complete, before carrier pickup or drop-off.

### Checklist

| # | Check | Critical? | Description |
|---|-------|-----------|-------------|
| 1 | G3 passed | Yes | G3 gate record shows PASS |
| 2 | Correct quantity packed | Yes | Count verified against PO and packing list |
| 3 | Packaging adequate | Yes | Parts protected against transit damage |
| 4 | Customer packaging requirements | Yes | Customer-specific packaging requirements met (if any) |
| 5 | Labels correct | Yes | Part number, qty, PO, Rev A info, customer info |
| 6 | Packing list included | Yes | Accurate packing list in shipment |
| 7 | CoC / reports included | Yes | All required documentation in shipment |
| 8 | Shipping docs prepared | No | BOL, commercial invoice, customs docs (if international) |
| 9 | Carrier confirmed | No | Carrier booked, pickup scheduled |
| 10 | Customer notified | No | Customer aware of pending shipment |

### Pass Criteria

- All critical checks (1-7) must PASS.
- Non-critical checks (8-10) should PASS or N/A.
- All documentation must be physically included in or attached to the shipment.

---

## Gate Sequence Requirements

| Current Gate | Prerequisites |
|-------------|---------------|
| G1 | Incoming inspection complete |
| G2 | G1 PASS |
| G3 | G1 PASS + G2 PASS (or G2 N/A if no Rev A processing) |
| G4 | G3 PASS |

A gate cannot be run if its prerequisite gates have not passed. The only exception is if G2 is not applicable (parts go directly from receiving to shipping with no Rev A processing), in which case G2 is skipped and G3 references G1 directly.
