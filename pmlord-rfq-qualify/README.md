# pmlord-rfq-qualify

RFQ qualification gate check skill for the PMLORD engine.

## What It Does

Runs five gate checks on an incoming RFQ to determine whether Rev A Manufacturing should proceed with quoting:

1. **Customer Status** -- New vs returning, history review
2. **Capability Match** -- Process, material, tolerance, finish, cert alignment
3. **Complexity Score** -- 1-5 scale based on technical requirements
4. **Capacity Check** -- PM workload, partner availability, timeline feasibility
5. **Credit Readiness** -- Payment history or new customer credit requirements

Produces a decision: PROCEED, CONDITIONAL, or DECLINE with documented rationale.

## Usage

```
/pmlord-rfq-qualify
```

Typically runs after `pmlord-rfq-intake` completes. The PMLORD engine auto-suggests this skill after intake.

## Inputs

- RFQ intake record (from `pmlord-rfq-intake` or manual entry)
- PM confirmation at the decision checkpoint

## Outputs

- Qualification gate record saved to `~/.pmlord/rfqs/{RFQ_ID}/qualification-gate.md`
- Workflow state logged to `~/.pmlord/state/workflow-state.jsonl`

## Files

| File | Purpose |
|------|---------|
| `SKILL.md` | Skill instructions and flow |
| `skill.yaml` | Skill manifest |
| `prompts/qualification-system.md` | System prompt for qualification logic |
| `prompts/qualification-user-template.md` | Qualification input template |
| `references/gate-criteria.md` | Decision table and scoring criteria |
| `references/capability-matrix.md` | Rev A capability reference |
| `references/capacity-planning.md` | Capacity and lead time reference |
| `references/credit-check-process.md` | Credit evaluation process |
| `templates/RFQ Qualification Gate.md` | Structured output template |

## Decision Routing

| Decision | Next Skill |
|----------|-----------|
| PROCEED | `pmlord-rfq-quote` |
| CONDITIONAL (new customer) | `pmlord-customer-gate` then `pmlord-rfq-quote` |
| CONDITIONAL (other) | `pmlord-rfq-quote` with conditions |
| DECLINE | `pmlord-customer-comms` (decline communication) |
