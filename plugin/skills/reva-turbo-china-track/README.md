# reva-turbo-china-track

Track manufacturing progress with Chinese manufacturing partners through a 10-milestone system.

## What It Does

- Tracks orders through 10 defined milestones (specs confirmed through shipped)
- Sets baseline schedules based on part type, quantity, and partner history
- Detects delays and assigns standardized delay codes
- Schedules quality checkpoints (FAI, in-process, final QC, pre-ship)
- Generates progress reports with timeline and delay analysis
- Suggests escalation when delays are critical

## Usage

```
/reva-turbo-china-track
```

Or via the engine orchestrator when context matches "track manufacturing", "where is my order", or "progress update".

## 10 Milestones

1. Specs confirmed
2. Tooling started
3. Tooling complete / First article
4. First article approved
5. Production started
6. Production 50%
7. Production complete
8. QC passed
9. Packed / ready to ship
10. Shipped

## Files

| File | Purpose |
|------|---------|
| `SKILL.md` | Skill instructions and flow |
| `skill.yaml` | Skill metadata |
| `prompts/tracking-system.md` | System prompt for tracking |
| `prompts/tracking-user-template.md` | User input collection template |
| `references/milestone-definitions.md` | 10 milestones with expected durations |
| `references/delay-codes.md` | Standardized delay reason codes |
| `references/quality-checkpoints.md` | Inspection scheduling guidance |
| `templates/Manufacturing Progress Report.md` | Output template |

## Output

`REVA-TURBO-TRACK-{YYYY-MM-DD}-{PartName}.docx`
