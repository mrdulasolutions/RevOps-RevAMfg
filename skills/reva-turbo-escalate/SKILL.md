---
name: reva-turbo-escalate
preamble-tier: 2
version: 1.0.0
description: |
  Escalation workflow for Rev A Manufacturing. Manages the escalation matrix
  (PM -> Senior PM -> Donovan Weber) with defined triggers: quality issues,
  delays >2 weeks, customer complaints, partner score <C, payment issues.
  Ensures proper documentation and resolution tracking.
compatibility: Claude Code, Claude desktop, Claude CoWork
allowed-tools:
  - Bash
  - Read
  - Write
  - Edit
  - Glob
  - Grep
  - AskUserQuestion
---

## Preamble (run first)

```bash
mkdir -p ~/.reva-turbo/analytics
echo '{"skill":"reva-turbo-escalate","ts":"'$(date -u +%Y-%m-%dT%H:%M:%SZ)'"}' >> ~/.reva-turbo/analytics/skill-usage.jsonl 2>/dev/null || true
```

## Purpose

Manage the escalation process when issues exceed the PM's authority or standard procedures. Ensures issues are routed to the right level of leadership with proper documentation, tracked to resolution, and logged in the audit trail.

## Flow

### Step 1: Escalation Trigger Assessment

Determine if escalation is warranted. Reference `references/escalation-matrix.md` for trigger definitions.

**Automatic escalation triggers:**
1. **Quality issue** — NCR with severity Major or Reject
2. **Delay > 2 weeks** — Order delayed 15+ calendar days from plan
3. **Customer complaint** — Formal complaint received from customer
4. **Partner score < C** — Manufacturing partner drops below C grade
5. **Payment issue** — Customer payment overdue > 30 days or payment dispute

> Escalation assessment for {{REFERENCE_ID}} ({{CUSTOMER_COMPANY}}):
>
> Trigger: {{TRIGGER_TYPE}}
> Severity: {{SEVERITY}}
> Current Status: {{CURRENT_STATUS}}
>
> Escalation matrix recommends: **{{ESCALATION_LEVEL}}**
>
> A) Proceed with escalation
> B) Provide more context before escalating
> C) Handle at current level (document justification)

If C, require justification and log the decision not to escalate.

### Step 2: Escalation Routing

Reference `references/escalation-matrix.md` for the routing chain:

| Level | Recipient | When |
|-------|-----------|------|
| Level 1 | Senior PM | First escalation for any trigger |
| Level 2 | Donovan Weber (President) | Unresolved after 48 hours at Level 1, or critical triggers |
| Critical | Donovan Weber (immediate) | Customer loss risk, safety issue, legal exposure |

### Step 3: Documentation

Reference `references/documentation-requirements.md` for what must be included. Every escalation must document:

1. **What happened** — Factual description of the issue
2. **Impact** — Effect on customer, timeline, revenue, relationship
3. **Root cause** — Known or suspected cause
4. **Actions taken so far** — What the PM has already done
5. **Recommendation** — PM's recommended resolution
6. **Timeline** — When resolution is needed

Generate the escalation note using `templates/Escalation Note.md`.

### Step 4: Log Escalation

```bash
mkdir -p ~/.reva-turbo/state
echo '{"ts":"'$(date -u +%Y-%m-%dT%H:%M:%SZ)'","event":"escalation","ref":"{{REFERENCE_ID}}","customer":"{{CUSTOMER_COMPANY}}","trigger":"{{TRIGGER_TYPE}}","level":"{{ESCALATION_LEVEL}}","escalated_to":"{{ESCALATED_TO}}","pm":"{{PM_NAME}}","status":"open","severity":"{{SEVERITY}}"}' >> ~/.reva-turbo/state/escalation-log.jsonl
```

Also log in the audit trail:

```bash
echo '{"ts":"'$(date -u +%Y-%m-%dT%H:%M:%SZ)'","type":"escalation","ref":"{{REFERENCE_ID}}","customer":"{{CUSTOMER_COMPANY}}","action":"Escalated to {{ESCALATED_TO}}: {{TRIGGER_TYPE}}","justification":"","pm":"{{PM_NAME}}","skill":"reva-turbo-escalate"}' >> ~/.reva-turbo/state/audit-trail.jsonl
```

### Step 5: Resolution Tracking

Track the escalation until resolved:

> Escalation {{ESCALATION_ID}} is open.
> Escalated to: {{ESCALATED_TO}}
> Days open: {{DAYS_OPEN}}
>
> A) Log a resolution
> B) Escalate to next level
> C) Add an update/note
> D) Check status

When resolved:

```bash
echo '{"ts":"'$(date -u +%Y-%m-%dT%H:%M:%SZ)'","event":"escalation_resolved","ref":"{{REFERENCE_ID}}","resolution":"{{RESOLUTION}}","resolved_by":"{{RESOLVED_BY}}","days_to_resolve":{{DAYS_TO_RESOLVE}}}' >> ~/.reva-turbo/state/escalation-log.jsonl
```

### Step 6: Post-Resolution

After resolution:
1. Notify the PM of the resolution
2. Update the order state if applicable
3. Document lessons learned
4. Update partner scorecard if partner-related

## Report Naming

Save escalation notes as:
```
REVA-TURBO-Escalation-{YYYY-MM-DD}-{Reference}.md
```

## Template References

- `prompts/escalation-system.md` — System prompt for escalation logic
- `prompts/escalation-user-template.md` — User interaction template
- `references/escalation-matrix.md` — Escalation routing and triggers
- `references/documentation-requirements.md` — Documentation standards
- `templates/Escalation Note.md` — Escalation note template
