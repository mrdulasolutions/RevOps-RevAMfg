# Hold vs. Release Criteria

## Overview

When a quality gate results in CONDITIONAL PASS or when specific conditions require a hold, use these criteria to determine whether parts should be held or released.

---

## HOLD Conditions

Parts must be placed on HOLD when any of the following conditions exist:

### Mandatory Hold

| Condition | Gate(s) | Action Required |
|-----------|---------|----------------|
| Critical dimension out of tolerance | G1, G2, G3 | NCR required. Do not release until dispositioned. |
| Material certification missing | G1 | Request CoC from partner. Do not release until received and verified. |
| Wrong material | G1, G2 | NCR required. Likely REJECT. |
| Open NCR with no disposition | G1, G3 | Resolve NCR before release. |
| Customer approval pending (use-as-is deviation) | G3 | Hold until customer responds. |
| Functional test failure | G3 | NCR required. Do not release. |
| Quantity discrepancy > 5% | G1, G4 | PM review required. |
| Customer complaint on prior shipment | G3, G4 | Senior PM review of corrective action effectiveness. |

### Discretionary Hold

| Condition | Gate(s) | PM Decision |
|-----------|---------|-------------|
| Non-critical dimension marginal (within spec but near limit) | G1, G3 | PM may release with note or hold for Senior PM review |
| Cosmetic issue (scratch, discoloration) on non-critical surface | G1, G3 | PM evaluates against customer requirements |
| Minor documentation gap (missing packing list) | G1 | PM may accept and note, or hold for documentation |
| First order from new partner | G1 | PM may elect extra scrutiny |
| Customer has tight quality history | G3, G4 | PM may add extra checks |

---

## RELEASE Conditions

Parts can be released (PASS) when:

| Condition | Verification |
|-----------|-------------|
| All critical gate checks PASS | Checklist complete |
| No open NCRs | NCR log checked |
| All prior gates passed | Gate log verified |
| Documentation complete | CoC, test reports, packing list present |
| Customer-specific requirements met | Requirements checklist reviewed |
| Quantity correct | Count verified |
| Packaging adequate | Visual verification |

---

## CONDITIONAL RELEASE

Parts can be conditionally released (CONDITIONAL PASS) when:

1. All critical checks pass.
2. Minor issues exist but do not affect form, fit, or function.
3. Senior PM approves the conditional release.
4. Conditions are documented with deadlines.

### Conditional Release Requirements

| Field | Required |
|-------|----------|
| Condition description | What must be resolved |
| Owner | Who is responsible for resolving |
| Deadline | When must it be resolved |
| Consequence | What happens if not resolved (revert to FAIL, recall, etc.) |
| Senior PM approval | Name and date |

### Examples of Conditional Releases

| Condition | Acceptable Conditional Release |
|-----------|-------------------------------|
| CoC being mailed separately | Release parts, condition: CoC received within 5 business days |
| Packing list has typo | Release parts, condition: corrected packing list sent to customer within 2 days |
| Non-critical dim borderline (in spec but close to limit) | Release with note to customer, condition: partner adjusts process for next order |
| Test report pending (non-safety) | Release parts, condition: test report provided within 10 business days |

### Unacceptable Conditional Releases

| Condition | Why Not Conditional |
|-----------|-------------------|
| Critical dimension out of spec | Must be resolved before release — no exceptions |
| Wrong material | Material non-conformance requires full disposition |
| Functional test failure | Cannot ship parts that do not function |
| Safety-related defect | Zero tolerance — must be fully resolved |
| Missing customer-required certification | Customer contract requirement — cannot waive |

---

## Hold Management

### Hold Duration Limits

| Hold Type | Max Duration | Escalation |
|-----------|-------------|------------|
| Documentation hold (missing CoC, packing list) | 5 business days | Senior PM |
| Engineering review hold | 10 business days | Donovan Weber |
| Customer approval hold | 15 business days | Senior PM contacts customer |
| NCR disposition hold | 10 business days | Senior PM |

### Hold Tracking

Holds are tracked in the quality gate log. Parts on hold must be:

1. Physically separated and labeled "HOLD — [Gate #] — [Date]".
2. Reviewed at each weekly PM meeting.
3. Escalated if hold duration exceeds limits above.
4. Released only by the PM who initiated the hold or a Senior PM.

### Releasing a Hold

To release a held lot:

1. Confirm the hold condition has been resolved.
2. Re-run the failed/conditional gate checks.
3. Document the resolution in the gate record.
4. Update the gate decision to PASS or maintain CONDITIONAL PASS with new conditions.
5. Update `~/.pmlord/state/quality-gates.jsonl`.
