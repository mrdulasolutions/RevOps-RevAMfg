# reva-turbo-repackage

Repackaging workflow skill for the REVA-TURBO engine.

## What It Does

Manages the repackaging process at Rev A Manufacturing for orders routed through the inspect-and-forward path:

1. Creates repackaging work orders after inspection passes
2. Determines packaging type and inner protection requirements
3. Ensures all labeling requirements are met (product, shipping, origin, regulatory)
4. Tracks completion and advances the order to the shipping stage

## Usage

```
/reva-turbo-repackage
```

Or triggered automatically by reva-turbo-order-track when an inspect-and-forward order reaches Stage 09.

## Inputs

- PO number and order details
- Inspection pass confirmation
- Customer packaging requirements
- Labeling specifications

## Outputs

- Repackaging work orders
- Order state updates
- Stage advancement to shipping-ready

## Files

| File | Purpose |
|------|---------|
| `SKILL.md` | Skill instructions and flow |
| `skill.yaml` | Skill manifest |
| `prompts/repackage-system.md` | System prompt for repackaging logic |
| `prompts/repackage-user-template.md` | User interaction template |
| `references/repackaging-procedures.md` | Standard procedures |
| `references/labeling-requirements.md` | Labeling standards |
| `templates/Repackaging Work Order.md` | Work order template |

## Next Step

After repackaging completes, the skill suggests setting up domestic shipping via `reva-turbo-logistics`.
