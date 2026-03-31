# reva-turbo-ncr

Non-Conformance Report (NCR) workflow for documenting defects and driving corrective action.

## What It Does

- Assigns unique NCR numbers and documents non-conformances
- Guides root cause analysis using 5-Why, Fishbone/Ishikawa, or full 8D
- Defines containment actions to prevent affected parts from reaching customers
- Determines disposition: rework, scrap, use-as-is (with deviation), or RTV
- Creates CAPA (Corrective and Preventive Action) plans with owners and due dates
- Calculates cost impact of the non-conformance
- Triggers partner scorecard updates and escalation when needed

## Usage

```
/reva-turbo-ncr
```

Or via the engine orchestrator when context matches "defect", "non-conformance", "NCR", or "quality problem".

## Flow

1. NCR identification (assign number, collect order details)
2. Defect description (what, expected, found, severity)
3. Containment actions (quarantine, check other orders)
4. Root cause analysis (5-Why, fishbone, or 8D based on severity)
5. Disposition (rework / scrap / use-as-is / RTV with human approval)
6. CAPA definition (corrective, preventive, verification)
7. Cost impact calculation
8. Generate NCR report
9. Post-NCR actions (scorecard update, partner communication, escalation)

## Files

| File | Purpose |
|------|---------|
| `SKILL.md` | Skill instructions and flow |
| `skill.yaml` | Skill metadata |
| `prompts/ncr-system.md` | System prompt for NCR generation |
| `prompts/ncr-user-template.md` | User input collection template |
| `references/root-cause-methods.md` | 5-Why, Fishbone, 8D methods |
| `references/disposition-options.md` | Rework, scrap, use-as-is, RTV details |
| `references/corrective-action.md` | CAPA framework |
| `templates/Non-Conformance Report.md` | Output template |

## Output

`REVA-TURBO-NCR-{YYYY-MM-DD}-{PartName}.docx`
