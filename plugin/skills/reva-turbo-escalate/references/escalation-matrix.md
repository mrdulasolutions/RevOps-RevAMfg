# Escalation Matrix

## Trigger Definitions

### 1. Quality Issue

| Condition | Escalation Level |
|-----------|-----------------|
| NCR Severity: Minor | No escalation (PM handles) |
| NCR Severity: Major | Level 1 (Senior PM) |
| NCR Severity: Reject | Level 1 (Senior PM) |
| Repeat NCR (same root cause, 3+ occurrences) | Level 2 (Donovan Weber) |
| Safety-related quality issue | Critical (Donovan Weber, immediate) |

### 2. Delay

| Condition | Escalation Level |
|-----------|-----------------|
| Delay 1-7 days | No escalation (PM manages) |
| Delay 8-14 days | PM discretion, recommend Level 1 |
| Delay 15+ days | Level 1 (Senior PM) — mandatory |
| Delay 30+ days | Level 2 (Donovan Weber) |
| Delay with customer contractual penalty risk | Level 2 (Donovan Weber) |

### 3. Customer Complaint

| Condition | Escalation Level |
|-----------|-----------------|
| Informal feedback (verbal) | No escalation (PM documents) |
| Formal written complaint | Level 1 (Senior PM) |
| Threat to end relationship | Level 2 (Donovan Weber) |
| Legal threat or demand letter | Critical (Donovan Weber, immediate) |
| Social media / public complaint | Critical (Donovan Weber, immediate) |

### 4. Partner Score

| Condition | Escalation Level |
|-----------|-----------------|
| Partner drops to B- | No escalation (PM monitors) |
| Partner drops to C or C+ | Level 1 (Senior PM) |
| Partner drops to C- or below | Level 2 (Donovan Weber) |
| Partner becomes non-responsive | Level 1 (Senior PM) |
| Partner ceases operations | Critical (Donovan Weber, immediate) |

### 5. Payment Issue

| Condition | Escalation Level |
|-----------|-----------------|
| Payment overdue 1-15 days | No escalation (PM follows up) |
| Payment overdue 16-30 days | Level 1 (Senior PM) |
| Payment overdue 31+ days | Level 2 (Donovan Weber) |
| Payment dispute filed | Level 1 (Senior PM) |
| Suspected fraud | Critical (Donovan Weber, immediate) |

## Routing Chain

```
Level 1: Senior PM
  - Response expected within 24 hours
  - Authority: Approve corrective actions up to $10K
  - Can resolve or escalate to Level 2

Level 2: Donovan Weber (President)
  - Response expected within 4 hours (business hours)
  - Authority: All decisions, contract modifications, partner termination
  - Final decision authority

Critical: Donovan Weber (Immediate)
  - Response expected immediately (any hours)
  - Triggers: Safety, legal, customer loss risk, fraud
  - May involve legal counsel
```

## Escalation Timing

| Level | Initial Response | Resolution Target | Auto-Escalate If |
|-------|-----------------|-------------------|------------------|
| Level 1 | 24 hours | 5 business days | No response in 48 hours |
| Level 2 | 4 hours | 3 business days | No response in 24 hours |
| Critical | Immediate | ASAP | N/A |

## De-Escalation

An escalation can be de-escalated (moved back to PM level) when:
1. The triggering condition is resolved
2. The escalation recipient approves de-escalation
3. A documented resolution plan is in place

De-escalation must be logged in the audit trail.
