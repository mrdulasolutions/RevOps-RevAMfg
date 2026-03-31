# reva-turbo-partner-scorecard

Evaluate manufacturing partner performance and assign A-F letter grades.

## What It Does

- Scores partners across four weighted categories: quality (35%), delivery (30%), cost (20%), communication (15%)
- Calculates defect rates, on-time delivery rates, and other KPIs from PM-provided data
- Assigns letter grades A through F with clear criteria
- Identifies strengths and weaknesses
- Recommends actions based on grade (from "increase volume" to "begin replacement")
- Tracks scores over time for trend analysis

## Usage

```
/reva-turbo-partner-scorecard
```

Or via the engine orchestrator when context matches "partner score", "evaluate supplier", or "partner performance".

## Files

| File | Purpose |
|------|---------|
| `SKILL.md` | Skill instructions and flow |
| `skill.yaml` | Skill metadata |
| `prompts/scorecard-system.md` | System prompt for scorecard generation |
| `prompts/scorecard-user-template.md` | User input collection template |
| `references/scoring-criteria.md` | Detailed scoring criteria by category |
| `references/benchmark-targets.md` | Target metrics and benchmarks |
| `templates/Partner Scorecard.md` | Output template |

## Output

`REVA-TURBO-SCORE-{YYYY-MM-DD}-{PartnerName}.docx`
