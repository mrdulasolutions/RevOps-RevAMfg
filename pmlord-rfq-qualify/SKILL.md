---
name: pmlord-rfq-qualify
preamble-tier: 2
version: 1.0.0
description: |
  Gate checks on incoming RFQs. Evaluates new vs returning customer, capability
  match, complexity score (1-5), capacity check, and credit readiness. Produces
  a PROCEED / CONDITIONAL / DECLINE decision with documented rationale.
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
mkdir -p ~/.pmlord/analytics
echo '{"skill":"pmlord-rfq-qualify","ts":"'$(date -u +%Y-%m-%dT%H:%M:%SZ)'"}' >> ~/.pmlord/analytics/skill-usage.jsonl 2>/dev/null || true
```

## Purpose

Run qualification gate checks on an RFQ to determine whether Rev A Manufacturing should proceed with quoting. This skill evaluates five gates and produces a clear decision: PROCEED, CONDITIONAL, or DECLINE.

## Prerequisites

This skill expects an intake record from `pmlord-rfq-intake`. If no intake record exists, prompt the PM to run intake first or provide the RFQ details manually.

## Flow

### Step 1: Load Intake Record

Read the intake record from `~/.pmlord/rfqs/{{RFQ_ID}}/intake-record.md` or accept the data passed from the intake skill. Confirm the following minimum fields are populated:

- Customer company name
- Part description
- Quantity
- Material (if applicable)
- Manufacturing process type

If critical fields are missing, flag them:

> The following fields are missing from the intake record and will affect qualification accuracy:
> - [list missing fields]
>
> A) Continue with available data
> B) Go back and complete intake first

### Step 2: Gate 1 — Customer Status

Determine if this is a new or returning customer.

**Returning customer:**
- Check for existing customer profile in `~/.pmlord/customers/`
- Review order history, payment history, quality track record
- Note existing PM relationship
- Result: `PASS` (returning with good history), `FLAG` (returning with issues), or `NEW`

**New customer:**
- Flag for onboarding via `pmlord-customer-gate`
- Check for red flags per `references/gate-criteria.md`
- Result: `NEW — onboarding required`

Present finding:

> **Gate 1 — Customer Status:** {{RESULT}}
> {{CUSTOMER_COMPANY}} is a [new/returning] customer. [History summary if returning.]

### Step 3: Gate 2 — Capability Match

Evaluate whether the requested work falls within Rev A Manufacturing's capabilities. Reference `references/capability-matrix.md`.

**Assessment criteria:**

| Capability | Match? | Notes |
|-----------|--------|-------|
| Manufacturing process | Yes/No/Partial | Does Rev A offer the required process? |
| Material | Yes/No/Partial | Can Rev A source this material? |
| Tolerances | Yes/No/Partial | Within standard capability or requires special tooling? |
| Finish | Yes/No/Partial | Standard or specialty finish? |
| Certifications | Yes/No/Partial | Does Rev A hold required certs (ISO, AS9100, etc.)? |
| Volume | Yes/No/Partial | Within typical production range? |

**Results:**
- `FULL MATCH` — All capabilities align
- `PARTIAL MATCH` — Most capabilities align; gaps can be addressed
- `NO MATCH` — Core capability gap; cannot fulfill

Present finding:

> **Gate 2 — Capability Match:** {{RESULT}}
> [Detail which capabilities match and any gaps.]

### Step 4: Gate 3 — Complexity Score (1-5)

Score the RFQ complexity on a 1-5 scale. Reference `references/gate-criteria.md` for scoring criteria.

| Score | Level | Description |
|-------|-------|-------------|
| 1 | Simple | Standard part, common material, loose tolerances, single process |
| 2 | Low | Minor customization, standard material, moderate tolerances |
| 3 | Medium | Multiple processes, tighter tolerances, special material or finish |
| 4 | High | Complex geometry, tight tolerances, multiple materials, assembly required |
| 5 | Critical | Extreme tolerances, exotic materials, certification requirements, multi-stage assembly |

**Scoring factors:**
- Number of manufacturing processes involved
- Tolerance tightness (standard vs. precision vs. ultra-precision)
- Material availability and cost
- Tooling requirements (standard vs. custom)
- Quality/certification requirements
- Assembly complexity
- Export control considerations

Present finding:

> **Gate 3 — Complexity Score:** {{SCORE}}/5 ({{LEVEL}})
> [Rationale for the score.]

### Step 5: Gate 4 — Capacity Check

Evaluate current workload and capacity. Reference `references/capacity-planning.md`.

**Check:**
- Current active orders for the assigned PM
- Estimated lead time for this type of work
- China partner availability for the required process
- Delivery timeline feasibility

Present finding:

> **Gate 4 — Capacity Check:** {{RESULT}}
> PM {{ASSIGNED_PM}} currently has {{ACTIVE_ORDERS}} active orders.
> Estimated lead time: {{ESTIMATED_LEAD_TIME}}
> Customer requested delivery: {{DELIVERY_TIMELINE}}
> Feasibility: [Feasible / Tight / Not feasible without adjustment]

### Step 6: Gate 5 — Credit Readiness

Evaluate payment risk. Reference `references/credit-check-process.md`.

**For returning customers:**
- Check payment history (on-time, late, delinquent)
- Check outstanding balances
- Review credit terms on file

**For new customers:**
- Flag that credit check is required during onboarding
- Note standard terms (Net 30 pending credit approval)
- Flag orders above $25,000 for additional review

Present finding:

> **Gate 5 — Credit Readiness:** {{RESULT}}
> [Payment history summary or new customer credit status.]

### Step 7: Qualification Decision

**HUMAN-IN-THE-LOOP CHECKPOINT:**

Based on the five gates, produce a recommendation. Use the decision table from `references/gate-criteria.md`:

**PROCEED** — All gates pass. No significant risks. Recommend moving to quoting.
- All capability matches are FULL or PARTIAL with known solutions
- Complexity score is 1-3, or 4-5 with experienced PM assigned
- Capacity is available
- Credit is clear or customer is established

**CONDITIONAL** — Some gates have flags. Can proceed with conditions.
- Partial capability match requiring partner evaluation
- Capacity is tight but manageable with timeline adjustment
- New customer requiring onboarding before order acceptance
- Complexity 4-5 requiring senior PM review
- Credit check pending

**DECLINE** — Significant gaps or risks. Recommend declining or referring.
- No capability match for core requirement
- No capacity within required timeline and customer will not flex
- Credit risk is unacceptable
- Export control block
- Red flags on customer legitimacy

Present the decision:

> ## Qualification Decision: {{DECISION}}
>
> | Gate | Result |
> |------|--------|
> | Customer Status | {{GATE_1_RESULT}} |
> | Capability Match | {{GATE_2_RESULT}} |
> | Complexity Score | {{GATE_3_RESULT}} |
> | Capacity Check | {{GATE_4_RESULT}} |
> | Credit Readiness | {{GATE_5_RESULT}} |
>
> **Rationale:** {{RATIONALE}}
>
> **Conditions (if CONDITIONAL):** {{CONDITIONS}}
>
> A) Accept this qualification and proceed to quoting
> B) Override — change decision to [PROCEED/CONDITIONAL/DECLINE]
> C) Need more information before deciding
> D) Escalate to Donovan Weber

### Step 8: Save and Route

Save the qualification record using `templates/RFQ Qualification Gate.md`. Log the workflow transition:

```bash
mkdir -p ~/.pmlord/rfqs/{{RFQ_ID}}
echo '{"ts":"'$(date -u +%Y-%m-%dT%H:%M:%SZ)'","rfq_id":"{{RFQ_ID}}","customer":"{{CUSTOMER_COMPANY}}","stage":"pmlord-rfq-qualify","status":"{{DECISION}}","pm":"{{ASSIGNED_PM}}","next_suggested":"NEXT_SKILL"}' >> ~/.pmlord/state/workflow-state.jsonl 2>/dev/null || true
```

**Routing based on decision:**

- **PROCEED** — Route to `pmlord-rfq-quote`
- **CONDITIONAL (new customer)** — Route to `pmlord-customer-gate` first, then `pmlord-rfq-quote`
- **CONDITIONAL (other)** — Route to `pmlord-rfq-quote` with conditions noted
- **DECLINE** — Route to `pmlord-customer-comms` to draft a professional decline communication

Suggest the next step:

> Qualification complete: **{{DECISION}}**. Next step: **{{NEXT_SKILL_NAME}}**. Want me to run it?

## Report Naming

```
PMLORD-RFQQualify-{YYYY-MM-DD}-{CustomerShortName}.md
```

## Template References

- `prompts/qualification-system.md` — System prompt for qualification logic
- `prompts/qualification-user-template.md` — Qualification input template
- `references/gate-criteria.md` — Decision table and scoring criteria
- `references/capability-matrix.md` — Rev A capability reference
- `references/capacity-planning.md` — Capacity and lead time reference
- `references/credit-check-process.md` — Credit evaluation process
- `templates/RFQ Qualification Gate.md` — Output template
