# Delay Management Procedures

## Delay Detection

Delays are detected when:

1. **Stage duration exceeds typical range** — Compare current time-in-stage against the typical duration from order-stages.md
2. **Partner reports delay** — Manufacturing partner communicates a schedule change
3. **Shipping disruption** — Carrier reports delay, customs hold, or exception
4. **Inspection failure** — NCR requires rework or replacement, adding time
5. **PM manual flag** — PM identifies a risk before it becomes a formal delay

## Delay Response Procedure

### Step 1: Classify Severity

| Days Behind Schedule | Severity | Code |
|---------------------|----------|------|
| 1-3 days | Minor | D1 |
| 4-7 days | Moderate | D2 |
| 8-14 days | Significant | D3 |
| 15+ days | Critical | D4 |

### Step 2: Calculate Impact

For every delay, calculate:

- **Revised completion date** for the current stage
- **Cascade effect** on all downstream stages
- **New projected customer delivery date**
- **Buffer consumed** (if any buffer existed between projected and promised dates)

### Step 3: Required Actions by Severity

#### D1 - Minor (1-3 days)
- Log the delay in order state
- Monitor daily
- No customer notification required
- No escalation required

#### D2 - Moderate (4-7 days)
- Log the delay in order state
- Notify PM lead (verbal or Slack)
- Consider proactive customer notification
- Document root cause
- Request corrective timeline from partner

#### D3 - Significant (8-14 days)
- Log the delay in order state
- Notify PM lead and Senior PM
- Customer notification required (draft using pmlord-customer-comms)
- Formal corrective action plan from partner
- Daily monitoring until resolved
- Update partner scorecard (negative event)

#### D4 - Critical (15+ days)
- Log the delay in order state
- **Mandatory escalation** via pmlord-escalate
- Escalation chain: PM -> Senior PM -> Donovan Weber
- Customer notification with revised timeline
- Evaluate alternative sourcing options
- Partner scorecard major negative event
- Consider expedited shipping to recover time

### Step 4: Recovery Options

| Option | When to Use | Cost Impact |
|--------|------------|-------------|
| Expedite manufacturing | D2+ at Mfg stages | Moderate |
| Air freight instead of sea | D3+ at Ship stage | High |
| Partial shipment | D2+ when partial is usable | Low |
| Alternative supplier | D4 only | High |
| Extended delivery date | D1-D2 with customer agreement | None |

### Step 5: Documentation

Every delay must be documented with:

1. **Root cause** — Why did the delay happen?
2. **Impact assessment** — What dates changed?
3. **Corrective action** — What was done to fix it?
4. **Preventive action** — How to prevent recurrence?
5. **Customer communication** — What was told to the customer?

## Delay Follow-Up Schedule

| Severity | Follow-Up Frequency | Until |
|----------|-------------------|-------|
| D1 | Every 2 days | Resolved |
| D2 | Daily | Resolved |
| D3 | Daily | Resolved + 3 days after |
| D4 | Twice daily | Resolved + 7 days after |
