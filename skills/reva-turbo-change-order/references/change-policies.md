# Change Order Policies

Business rules governing change orders at Rev A Manufacturing.

---

## Change Fee Schedule

The change fee depends on the production stage when the change is requested.

### Stage-Based Fees

| Stage When Change Requested | Change Fee | Scrap Cost | Notes |
|----------------------------|-----------|-----------|-------|
| **RFQ / Quoting** | None | None | Not yet an order. Revise the quote freely. |
| **PO Received, not yet placed** | None | None | Change before production starts. Update specs and re-confirm PO. |
| **Order placed, tooling not started** | None | None | Notify partner of updated specs before tooling begins. |
| **Tooling in progress** | Cost of tooling modification | Tooling material if restart needed | If tooling is >50% complete and incompatible with change, full tooling restart. |
| **Tooling complete, awaiting production** | Tooling modification cost (if tooling affected) | None | If change doesn't affect tooling (e.g., quantity change), no fee. |
| **First article / sampling** | Setup cost + first article cost | Sample units | May need new first article approval. |
| **Production in progress** | Change fee: $500-$2,000 (setup + downtime) | Cost of completed non-conforming units | Partner assesses actual scrap quantity. |
| **Production complete, QC in progress** | Full production restart cost | All completed units if spec changed | Essentially starting over. Consider whether change is worth it. |
| **QC passed, ready to ship** | Full restart cost + original inspection cost | All units | Highest cost stage for changes. |
| **Shipped / in transit** | Full restart + return logistics cost | All units + round-trip shipping | Only for critical changes. Usually better to process as a new order. |

### Change Fee Calculation

```
Change Fee = Base Fee + Tooling Impact + Scrap Cost + Expedite Premium

Where:
  Base Fee = stage-based fee from table above
  Tooling Impact = partner's quoted tooling modification cost
  Scrap Cost = (completed units * unit production cost) if units are non-conforming
  Expedite Premium = 15-30% of remaining production cost if timeline compressed
```

---

## Who Pays?

| Change Initiated By | Cost Responsibility |
|---------------------|-------------------|
| **Customer** | Customer pays all change fees, scrap costs, and expedite premiums |
| **Rev A (internal)** | Rev A absorbs the cost. Do not charge customer. |
| **Partner (manufacturing error)** | Partner absorbs the cost. Deduct from partner payment. |
| **Partner (proactive suggestion)** | Rev A evaluates. If beneficial, absorb. If not, decline. |
| **Design error discovered** | Depends on who provided the design. Customer design = customer pays. Rev A review missed it = negotiate. |

---

## Change Order Limits

### Maximum Changes Per Order

| Rule | Threshold | Action |
|------|-----------|--------|
| Standard limit | 3 change orders per order | Warning at change order #3 |
| Hard limit | 4+ change orders | Require full re-quote |
| Exception | Critical safety/compliance changes | No limit (but escalate to Senior PM) |

**Rationale:** Orders with excessive changes signal scope instability. A full re-quote forces a reset and ensures pricing still makes sense.

### When 3 Change Orders Are Reached

> **Warning:** This order has reached 3 change orders. Per Rev A policy:
>
> - The current change order will be processed normally.
> - Any additional changes will require a full re-quote.
> - The PM should discuss with the customer whether the scope is stable.
> - Consider whether a fresh order with consolidated specs would be cleaner.

### Re-Quote Process

When a re-quote is triggered:
1. Consolidate all changes into a single updated spec
2. Generate a new quote with the consolidated spec
3. Cancel the original order (with reference to new quote)
4. Customer issues a new PO against the new quote
5. Start fresh tracking with the new order

---

## Timing Policies

| Policy | Rule |
|--------|------|
| Change request acknowledgment | Within 4 business hours of receipt |
| Impact analysis completion | Within 1 business day for standard, 4 hours for urgent |
| Customer communication | Same day as impact analysis completion |
| Partner notification | Within 4 hours of PM approval |
| Cascade updates | Immediately upon PM approval |

---

## Approval Authority

| Change Impact | Approval Authority |
|--------------|-------------------|
| Cost increase < $1,000 | PM |
| Cost increase $1,000 - $10,000 | PM + Senior PM review |
| Cost increase > $10,000 | PM + Senior PM + Donovan Weber |
| Timeline extension < 1 week | PM |
| Timeline extension 1-3 weeks | PM + Senior PM review |
| Timeline extension > 3 weeks | PM + Senior PM + customer re-confirmation |
| Tooling remake | PM + Senior PM review |
| Any change after QC passed | Senior PM required |
| Any change to a shipped order | Donovan Weber required |

---

## Documentation Requirements

Every change order must include:

1. **Change Order Number** (CO-{ORDER_ID}-{SEQ})
2. **Original values** (what it was before)
3. **New values** (what it will be after)
4. **Reason** (why the change was requested)
5. **Requested by** (customer, internal, or partner)
6. **Full impact analysis** (cost, time, tooling, quality, partner, logistics)
7. **PM decision** (approved, rejected, or approved with modifications)
8. **Customer communication** (copy of what was sent to customer)
9. **Partner notification** (copy of what was sent to partner, if applicable)
10. **Revision history** (updated revision level on all documents)

---

## Cancellation vs. Change

Sometimes a "change" is really a cancellation + new order:

| Situation | Recommendation |
|-----------|---------------|
| Change affects >80% of the spec | Treat as cancellation + new order |
| Change requires complete tooling remake | Evaluate cost of change vs. new order |
| 4th+ change order | Re-quote required (policy) |
| Customer wants to switch to different part entirely | Cancellation + new order |
| Change only after order is shipped | New order (return/rework is separate) |

### Cancellation Fee

If the change is processed as a cancellation:

| Stage | Cancellation Fee |
|-------|-----------------|
| Before manufacturing starts | None |
| Tooling in progress | Tooling cost incurred to date |
| Production in progress | Tooling + production cost incurred to date |
| Production complete | Full production cost |
| Shipped | Full cost + return shipping (if applicable) |
