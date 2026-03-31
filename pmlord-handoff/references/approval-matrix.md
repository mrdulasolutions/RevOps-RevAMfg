# Approval Matrix

Who approves what at Rev A Manufacturing. This matrix defines routing for all approval-required actions.

## Approval Authority Levels

| Level | Person | Role |
|-------|--------|------|
| L1 | Ray or Harley | Senior PM |
| L2 | Donovan Weber | Owner/CEO |

## Approval Requirements

| Action | Threshold | Approver | Response Time Target |
|--------|-----------|----------|---------------------|
| Quote send | >$50K | L1 (Senior PM) | 24 hours |
| Quote send | >$100K | L2 (Donovan Weber) | 48 hours |
| New customer first order | >$25K | L1 (Senior PM) | 24 hours |
| New customer first order | >$50K | L2 (Donovan Weber) | 48 hours |
| NCR disposition: use-as-is | Any value | L1 (Senior PM) | 24 hours |
| NCR disposition: rework | >$5K rework cost | L1 (Senior PM) | 24 hours |
| NCR disposition: scrap | >$5K scrap value | L1 (Senior PM) | 24 hours |
| NCR disposition: scrap | >$20K scrap value | L2 (Donovan Weber) | 48 hours |
| NCR disposition: RTV (return to vendor) | >$10K | L2 (Donovan Weber) | 48 hours |
| Price exception (below min margin 15%) | Any value | L2 (Donovan Weber) | 48 hours |
| Price exception (margin 15-18%) | Any value | L1 (Senior PM) | 24 hours |
| Partner change mid-order | Any value | L1 (Senior PM) | 24 hours |
| Change order cost increase | >$5K | L1 (Senior PM) | 24 hours |
| Change order cost increase | >$20K | L2 (Donovan Weber) | 48 hours |
| Customer credit/refund | >$2K | L1 (Senior PM) | 24 hours |
| Customer credit/refund | >$10K | L2 (Donovan Weber) | 48 hours |
| New partner onboarding | Any | L2 (Donovan Weber) | 1 week |
| Expedite authorization (air vs ocean) | >$2K cost delta | L1 (Senior PM) | 12 hours |
| Warranty claim acceptance | >$5K | L1 (Senior PM) | 24 hours |
| Warranty claim acceptance | >$15K | L2 (Donovan Weber) | 48 hours |

## Self-Approval Rules

- A PM cannot approve their own request. If the requesting PM is also the designated approver (e.g., Ray requesting approval for a $40K quote that requires Senior PM approval), escalate to the next level.
- Donovan Weber can self-approve (as Owner/CEO, there is no higher level). Self-approvals are still logged for audit purposes.

## Escalation for Unavailability

If the designated approver is unavailable (vacation, unreachable):

1. **L1 unavailable:** Route to the other Senior PM. If both L1s are unavailable, escalate to L2 (Donovan Weber).
2. **L2 unavailable:** The two Senior PMs (Ray and Harley) can jointly approve L2 items if both agree. Log as "joint L1 approval per L2 unavailability."
3. **All unavailable:** For time-critical items only, the requesting PM may proceed with the following constraints:
   - Document the decision and rationale
   - Notify all approvers as soon as they are available
   - Only for items that would cause customer harm or financial loss if delayed

## Approval Context Package

Every approval request must include:

1. **One-line summary:** "Approve $75K quote for Acme Corp CNC housing"
2. **Financial details:** Quote value, cost, margin %, customer tier
3. **PM recommendation:** Approve/reject with reasoning
4. **Risk assessment:** What happens if we proceed vs do not proceed
5. **Time constraint:** When does the customer need a response?
6. **Precedent:** Have we done similar deals before? What was the outcome?
7. **Supporting documents:** Quote package, NCR report, cost analysis, etc.

## Approval Decision Options

| Decision | Meaning | Next Step |
|----------|---------|-----------|
| Approve | Proceed as requested | Execute the action, log decision |
| Approve with conditions | Proceed with modifications | Modify per conditions, then execute |
| Reject | Do not proceed | PM must revise or abandon. Rejection reason required. |
| Request more info | Cannot decide with current information | PM provides additional details, re-submit |

## Audit Requirements

All approval decisions are logged to `~/.pmlord/state/approval-log.jsonl` with:

- Timestamp
- Request ID
- Action type
- Value/amount
- Requesting PM
- Approver
- Decision
- Conditions (if any)
- Rejection reason (if rejected)
- Time from request to decision (response time tracking)

Approval logs are immutable. To reverse a decision, create a new log entry referencing the original.
