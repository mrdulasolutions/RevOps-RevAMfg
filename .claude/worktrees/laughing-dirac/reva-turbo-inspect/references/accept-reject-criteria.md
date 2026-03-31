# Accept / Reject / Hold Criteria

## Disposition Definitions

| Disposition | Definition | Action |
|------------|-----------|--------|
| **ACCEPT** | Parts meet all specification requirements. No deviations found. | Release to stock or customer shipment. |
| **REJECT** | Parts have critical non-conformances that cannot be resolved. | Quarantine parts. Issue NCR. Determine rework/scrap/RTV. |
| **HOLD** | Parts have minor deviations or missing documentation requiring review. | Quarantine parts. Escalate to Senior PM for engineering disposition. |

## Criteria by Defect Type

### Dimensional Defects

| Condition | Disposition | Notes |
|-----------|------------|-------|
| All dims within tolerance | ACCEPT | |
| Critical dim out of tolerance | REJECT | Automatic — no exceptions without engineering deviation |
| Non-critical dim out of tolerance (within 1.5x tolerance) | HOLD | May be acceptable with deviation approval |
| Non-critical dim out of tolerance (beyond 1.5x) | REJECT | |
| Dimension borderline (within measurement uncertainty) | HOLD | Remeasure with higher-precision tool |

### Surface / Finish Defects

| Condition | Disposition | Notes |
|-----------|------------|-------|
| Surface finish meets spec | ACCEPT | |
| Surface roughness slightly out of spec (within 25%) | HOLD | May accept for non-critical surfaces |
| Surface roughness significantly out of spec | REJECT | |
| Cosmetic scratch on non-functional surface | HOLD | Depends on customer requirements |
| Scratch on functional/sealing surface | REJECT | |
| Finish color off-spec | HOLD | Verify against customer requirements |
| Finish adhesion failure | REJECT | |
| Orange peel, runs, sags in coating | HOLD | Severity dependent |

### Material Defects

| Condition | Disposition | Notes |
|-----------|------------|-------|
| Material matches spec, cert provided | ACCEPT | |
| Material matches spec, no cert | HOLD | Request cert from partner before release |
| Material does not match spec | REJECT | |
| Hardness out of spec | REJECT | Unless engineering approves deviation |
| Material contamination | REJECT | |
| Corrosion present | REJECT | Unless cosmetic only and removable |

### Functional Defects

| Condition | Disposition | Notes |
|-----------|------------|-------|
| Assembly/fit check passes | ACCEPT | |
| Minor fit issue (adjustable) | HOLD | Engineering review needed |
| Does not assemble | REJECT | |
| Thread gauge fails (go or no-go) | REJECT | |
| Functional test fails | REJECT | |

### Quantity Defects

| Condition | Disposition | Notes |
|-----------|------------|-------|
| Quantity matches PO (+/- 0%) | ACCEPT (qty) | |
| Quantity short (1-5% under) | ACCEPT with note | Notify PM, request balance shipment |
| Quantity short (> 5% under) | HOLD | PM decides: accept partial or require full qty |
| Quantity over (within 10%) | ACCEPT | Accept overage or return extras |
| Quantity over (> 10%) | HOLD | PM decides: accept or return |

### Documentation Defects

| Condition | Disposition | Notes |
|-----------|------------|-------|
| All documentation present and correct | ACCEPT | |
| Missing CoC | HOLD | Request from partner, do not release without it |
| Missing packing list | ACCEPT with note | Note in inspection report |
| Incorrect documentation (wrong part/PO) | HOLD | Clarify with partner |

## Multiple Defects

When multiple defects are found:

1. The most severe disposition applies to the entire lot.
2. If any single defect results in REJECT, the lot disposition is REJECT.
3. Multiple HOLD items may escalate to REJECT at PM discretion.
4. Document ALL defects regardless of individual severity.

## Deviation Approval Authority

| Deviation Type | Approval Authority |
|---------------|-------------------|
| Non-critical dim within 1.5x tolerance | Senior PM (Ray Yeh or Harley Scott) |
| Surface finish minor deviation | Senior PM |
| Missing documentation | PM (any) |
| Critical dimension deviation | Senior PM + customer approval |
| Material substitution | Donovan Weber + customer approval |
| Functional deviation | Senior PM + customer approval |

## Quarantine Procedures

Parts with HOLD or REJECT disposition must be:

1. Physically separated from accepted stock.
2. Labeled with a HOLD or REJECT tag (include part number, PO, date, reason).
3. Recorded in the inspection log.
4. Not moved to customer shipment staging area.
5. Reviewed within 5 business days (HOLD) or actioned within 10 business days (REJECT).
