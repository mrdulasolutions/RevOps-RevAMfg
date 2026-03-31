# reva-turbo-change-order

Mid-stream change management skill for the REVA-TURBO engine.

## What It Does

When a customer requests a change to an in-progress order, this skill:

1. Captures the change request with full context from the existing order
2. Calculates impact across 6 dimensions (cost, lead time, tooling, quality, partner, logistics)
3. Presents a complete impact summary for PM decision
4. Drafts customer communication with revised pricing/timeline
5. Notifies the manufacturing partner with updated specs
6. Cascades approved changes through all downstream REVA-TURBO skills
7. Maintains full audit trail with revision control

## Change Types Supported

| Change | Cost | Time | Tooling | Quality | Partner | Logistics |
|--------|------|------|---------|---------|---------|-----------|
| Quantity increase | Yes | Maybe | Maybe | No | Yes | Yes |
| Quantity decrease | Yes | No | No | No | Yes | Yes |
| Material change | Yes | Yes | Maybe | Yes | Yes | Maybe |
| Tolerance tightened | Yes | Maybe | Maybe | Yes | Yes | No |
| Finish change | Yes | Maybe | No | Yes | Yes | No |
| Design revision | Yes | Yes | Yes | Yes | Yes | Maybe |
| Date moved earlier | Maybe | Yes | No | No | Yes | Yes |
| Date moved later | No | No | No | No | Yes | Maybe |
| Add operation | Yes | Yes | Maybe | Yes | Yes | No |
| Remove operation | Yes | Maybe | No | Yes | Yes | No |

## Change Fee Policy

- Before manufacturing starts: no change fee
- During tooling: tooling modification cost
- During production: change fee + scrap cost
- After QC passed: full restart cost
- Maximum 3 change orders before requiring full re-quote

## Change Order Numbering

`CO-{ORDER_ID}-{SEQ}` (e.g., CO-ORD-2026-0142-01)

## Usage

```
/reva-turbo-change-order
```

Or via quick command: `change ORD-2026-0142 quantity 5000`

## Files

| File | Purpose |
|------|---------|
| `SKILL.md` | Skill instructions and flow |
| `skill.yaml` | Skill manifest |
| `prompts/change-order-system.md` | Impact analysis methodology and communication tone |
| `prompts/change-order-user-template.md` | Change request input variables |
| `references/impact-matrix.md` | Change type to impact dimension mapping |
| `references/change-policies.md` | Business rules for change fees and limits |
| `templates/Change Order.md` | Full change order document template |
| `templates/Change Impact Summary.md` | Quick PM decision summary |
