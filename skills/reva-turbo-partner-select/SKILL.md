---
name: reva-turbo-partner-select
preamble-tier: 2
version: 1.0.0
description: |
  Match order specifications to manufacturing partner capabilities. Score and
  rank qualified partners for a specific RFQ/order. Document selection rationale.
  HITL confirmation before partner is assigned. Sits between rfq-quote and
  china-package in the lifecycle.
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
echo '{"skill":"reva-turbo-partner-select","ts":"'$(date -u +%Y-%m-%dT%H:%M:%SZ)'"}' >> ~/.reva-turbo/analytics/skill-usage.jsonl 2>/dev/null || true
```

## Purpose

Match an order's specifications to manufacturing partner capabilities, score and rank all qualified partners, and present a recommendation to the PM for confirmation. Partner selection is a hard HITL gate — no partner is assigned without explicit PM approval. This skill sits between reva-turbo-rfq-quote and reva-turbo-china-package in the workflow lifecycle.

## Flow

### Step 1 — Load Order Requirements

Read the current order context:

```bash
# Load current context
cat ~/.reva-turbo/state/current-context.json 2>/dev/null || echo "No active context."

# Load workflow state for this order
_ORDER_ID="{{ORDER_ID}}"
grep "\"rfq_id\":\"$_ORDER_ID\"" ~/.reva-turbo/state/workflow-state.jsonl 2>/dev/null | tail -5

# Load partner roster
cat ~/.reva-turbo/config/partners.yaml 2>/dev/null || echo "No partners.yaml found — run /reva-turbo:reva-turbo-setup to configure partners."
```

Collect order requirements (from context or ask PM):

| Field | Source | Required |
|-------|--------|----------|
| Order ID / RFQ ID | Context | Yes |
| Part description | Context | Yes |
| Manufacturing process required | Context / ask | Yes (e.g. CNC, injection molding, die casting, sheet metal, PCB) |
| Material | Context | Yes |
| Quantity | Context | Yes |
| Tolerance class | Context | Yes (standard / precision / ultra-precision) |
| Surface finish | Context | Yes |
| Assembly required? | Context / ask | Yes (Y/N) |
| Required delivery date | Context | Yes |
| Customer type | Context | Yes (new / returning) |

If any required field is missing, ask the PM before proceeding.

### Step 2 — Capability Matching and Scoring

Score each partner in partners.yaml on a 100-point scale across five dimensions. **Eliminate** any partner with an F rating or an active quality hold before scoring.

#### Scoring Dimensions

**1. Capability Match (30 points)**

Does the partner support the required manufacturing process?

| Match Level | Score |
|-------------|-------|
| Primary process — partner specializes in this exact process | 28–30 |
| Secondary capability — partner can do it but it's not their core | 15–22 |
| Marginal — possible but would require subcontracting | 5–12 |
| No capability | 0 (eliminate) |

**2. Quality Rating (25 points)**

Based on partner's current scorecard rating:

| Rating | Score |
|--------|-------|
| A | 25 |
| B | 20 |
| C | 10 — present to PM as caution flag |
| D | 5 |
| F | 0 — eliminate automatically |

**3. Capacity / Lead Time (20 points)**

Can the partner meet the required delivery date?

| Lead Time Margin | Score |
|-----------------|-------|
| On-time with ≥2 weeks buffer | 18–20 |
| On-time with 1–2 weeks buffer | 13–17 |
| On-time, tight (< 1 week buffer) | 7–12 |
| Cannot meet delivery date | 0–6 |

**4. IP Protection (15 points)**

Does the partner have IP agreements in place?

| Agreement | Score |
|-----------|-------|
| NNN Agreement (Non-disclosure, Non-use, Non-circumvention) | 15 |
| NDA only | 10 |
| Limited / informal agreement | 5 |
| No IP protection | 0 |

**5. Historical Performance (10 points)**

Based on data from reva-turbo-partner-scorecard:

| Performance | Score |
|-------------|-------|
| On-time ≥95%, defect rate <1% | 9–10 |
| On-time 85–94%, defect rate <3% | 6–8 |
| On-time 70–84%, defect rate <5% | 3–5 |
| On-time <70% or defect rate ≥5% | 0–2 |

**Flags:**
- Any partner with a C quality rating: include in table but flag with "(Caution — C rating)"
- Any partner with an active quality hold: eliminate, note reason

### Step 3 — Rank and Present

Sort all eligible partners by total score (highest first). Present a ranked table to the PM:

> **Partner Selection — {{ORDER_ID}} — {{PART_DESCRIPTION}}**
>
> Order specs: {{PROCESS}} | {{MATERIAL}} | Qty {{QUANTITY}} | Delivery {{DELIVERY_DATE}}
>
> | Rank | Partner | Location | Score | Cap | Qual | Lead | IP | History | Notes |
> |------|---------|----------|-------|-----|------|------|----|---------|-------|
> | 1 | {{PARTNER_1}} | {{LOCATION}} | {{SCORE}} | {{CAP}} | {{QUAL}} | {{LEAD}} | {{IP}} | {{HIST}} | {{NOTES}} |
> | 2 | {{PARTNER_2}} | {{LOCATION}} | {{SCORE}} | {{CAP}} | {{QUAL}} | {{LEAD}} | {{IP}} | {{HIST}} | {{NOTES}} |
> | 3 | {{PARTNER_3}} | {{LOCATION}} | {{SCORE}} | {{CAP}} | {{QUAL}} | {{LEAD}} | {{IP}} | {{HIST}} | {{NOTES}} |
>
> Column key: Cap=Capability(30) | Qual=Quality(25) | Lead=Lead Time(20) | IP=IP Protection(15) | History(10)
>
> Partners eliminated: {{ELIMINATED_LIST}} (reasons: {{ELIMINATION_REASONS}})

If fewer than 3 partners score above 50, note this and present only those that qualify.

### Step 4 — HITL Checkpoint (REQUIRED — Cannot Auto-Select)

**This checkpoint is mandatory and cannot be bypassed.** No partner is assigned without PM confirmation.

Present to PM via AskUserQuestion:

> **Partner Selection for {{ORDER_ID}}**
>
> Recommended: {{TOP_PARTNER}} (Score: {{TOP_SCORE}}/100)
>
> Rationale: {{3-SENTENCE RATIONALE — WHY THIS PARTNER IS BEST FIT}}
>
> A) Approve recommended partner — {{TOP_PARTNER}}
> B) Select a different ranked partner (specify rank or name)
> C) Add a partner not on the list (manual entry)
> D) Defer selection — I need more information before deciding

If PM selects B: Ask which ranked partner they prefer; record that selection.
If PM selects C: Collect partner details manually (name, location, process, rating, IP status); proceed with that partner.
If PM selects D: Log a pending state and exit. No partner is assigned yet.

### Step 5 — Log Selection

After PM confirms:

```bash
_TS=$(date -u +%Y-%m-%dT%H:%M:%SZ)
_ORDER="{{ORDER_ID}}"
_PARTNER="{{SELECTED_PARTNER}}"
_SCORE="{{SCORE}}"
_RATIONALE="{{RATIONALE}}"
_PM="{{PM_NAME}}"
_ALTS="{{ALTERNATIVES_CONSIDERED}}"

echo '{"ts":"'"$_TS"'","type":"partner_selected","order_id":"'"$_ORDER"'","partner":"'"$_PARTNER"'","score":'"$_SCORE"',"rationale":"'"$_RATIONALE"'","pm":"'"$_PM"'","alternatives_considered":'"$_ALTS"'}' >> ~/.reva-turbo/state/workflow-state.jsonl

# Audit trail
echo '{"ts":"'"$_TS"'","type":"decision","ref":"'"$_ORDER"'","action":"partner_selected","detail":"'"$_PARTNER"' (score:'"$_SCORE"')","justification":"'"$_RATIONALE"'","pm":"'"$_PM"'","skill":"reva-turbo-partner-select"}' >> ~/.reva-turbo/state/audit-trail.jsonl
```

Confirm to PM:

> **Partner Selected: {{PARTNER_NAME}}**
>
> Score: {{SCORE}}/100
> Rationale: {{RATIONALE}}
> Logged to workflow state and audit trail.
>
> Next step: Build the manufacturing package. Run `/reva-turbo:reva-turbo-china-package`?

## Rules

1. **Hard HITL gate.** No partner assignment without explicit PM confirmation at Step 4.
2. **Eliminate F-rated partners.** Any partner with an F quality rating is removed before scoring — do not present to PM.
3. **Eliminate quality holds.** Any partner with an active quality hold is eliminated with reason noted.
4. **Flag C-rated partners.** C-rated partners appear in the table but are clearly flagged as cautionary. PM decides.
5. **Document rationale.** Every selection must include a 3-sentence written rationale in the log.
6. **Alternatives are logged.** All partners considered (including eliminated ones) are recorded in the workflow state.

## Report Naming

If PM requests a partner selection report:
```
REVA-TURBO-PartnerSelect-{YYYY-MM-DD}-{ORDER_ID}.md
```

## Lifecycle

**Previous skill:** reva-turbo-rfq-quote (partner selection follows quote generation, after customer accepts)
**Next skill:** reva-turbo-china-package (build manufacturing package for selected partner)

**Feeds:**
- reva-turbo-china-package — receives selected_partner, partner_score, selection_rationale
- reva-turbo-audit-trail — logs partner selection decision
- reva-turbo-workflow-state — records partner assignment in workflow state

## State Tracking

| File | Data |
|------|------|
| `~/.reva-turbo/state/workflow-state.jsonl` | Partner selection event with full scoring data |
| `~/.reva-turbo/state/audit-trail.jsonl` | PM decision audit entry |
| `~/.reva-turbo/config/partners.yaml` | Partner roster (read-only in this skill) |
