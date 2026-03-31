# reva-turbo-quality-gate

Quality gate checks at defined stages of the Rev A Manufacturing workflow.

## What It Does

- Runs structured gate checklists at four stages: incoming, in-process, final, and pre-ship
- Each gate has specific pass criteria tailored to that stage
- Three possible decisions: PASS, CONDITIONAL PASS, or FAIL
- Conditional passes require documented conditions, deadlines, and Senior PM approval
- Failed gates trigger NCR creation or escalation
- Full audit trail of all gate decisions

## Usage

```
/reva-turbo-quality-gate
```

Or via the engine orchestrator when context matches "quality gate", "release", "hold", or "gate check".

## Four Gates

| Gate | Stage | Key Focus |
|------|-------|-----------|
| G1 | Incoming | Inspection results, documentation, quantities |
| G2 | In-Process | Process quality, routing compliance, traceability |
| G3 | Final | Customer requirements, certifications, NCR closure |
| G4 | Pre-Ship | Packaging, labeling, shipping documents |

## Files

| File | Purpose |
|------|---------|
| `SKILL.md` | Skill instructions and flow |
| `skill.yaml` | Skill metadata |
| `prompts/quality-gate-system.md` | System prompt for gate checks |
| `prompts/quality-gate-user-template.md` | User input collection template |
| `references/gate-definitions.md` | Criteria for each gate stage |
| `references/hold-release-criteria.md` | When to hold vs. release |
| `templates/Quality Gate Checklist.md` | Output template |

## Output

`REVA-TURBO-GATE-{G#}-{YYYY-MM-DD}-{PartName}.docx`
