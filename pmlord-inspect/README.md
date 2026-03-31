# pmlord-inspect

Incoming inspection workflow for parts received from manufacturing partners.

## What It Does

- Guides PMs through a structured incoming inspection process
- Checks received parts against original manufacturing specs
- Covers visual, dimensional, material, and functional inspections
- Determines sample sizes based on AQL tables
- Assigns disposition: ACCEPT, REJECT, or HOLD
- Generates inspection reports with full findings documentation
- Triggers downstream workflows (NCR for rejects, quality gate for accepts)

## Usage

```
/pmlord-inspect
```

Or via the engine orchestrator when context matches "inspect", "receiving", "check quality", or "incoming".

## Flow

1. Identify shipment (part number, PO, qty, condition)
2. Locate original specs for comparison
3. Visual inspection (surface, finish, defects, labeling)
4. Dimensional inspection (critical and general dims)
5. Material verification (CoC, hardness, test reports)
6. Functional check (assembly, fit, thread engagement)
7. Determine disposition (human-in-the-loop confirmation)
8. Generate inspection report
9. Suggest next action based on disposition

## Files

| File | Purpose |
|------|---------|
| `SKILL.md` | Skill instructions and flow |
| `skill.yaml` | Skill metadata |
| `prompts/inspection-system.md` | System prompt for inspection |
| `prompts/inspection-user-template.md` | User input collection template |
| `references/inspection-procedures.md` | Standard inspection procedures |
| `references/measurement-standards.md` | Measurement methods and tools |
| `references/accept-reject-criteria.md` | Disposition criteria by defect type |
| `templates/Inspection Report.md` | Output template |

## Output

`PMLORD-INSP-{YYYY-MM-DD}-{PartName}.docx`
