# pmlord-logistics

Shipping and logistics coordination skill for the PMLORD engine.

## What It Does

Manages all shipping logistics for Rev A Manufacturing orders including:

1. Routing decisions (direct-to-customer vs inspect-and-forward)
2. Shipping mode selection (air, sea, ground)
3. Carrier selection from approved carrier list
4. Customs documentation preparation for China imports
5. Shipment tracking and exception handling

## Usage

```
/pmlord-logistics
```

Or ask PMLORD to set up shipping for a specific PO number.

## Inputs

- PO number and order details
- Routing preference or decision factors
- Shipping urgency and mode preference
- Cargo dimensions and weight

## Outputs

- Shipping coordination documents
- Customs documentation checklists
- Shipment tracking log entries at `~/.pmlord/shipments/shipment-log.jsonl`

## Files

| File | Purpose |
|------|---------|
| `SKILL.md` | Skill instructions and flow |
| `skill.yaml` | Skill manifest |
| `prompts/logistics-system.md` | System prompt for logistics logic |
| `prompts/logistics-user-template.md` | User interaction template |
| `references/shipping-modes.md` | Air/sea/ground mode details |
| `references/customs-docs.md` | Customs documentation requirements |
| `references/routing-logic.md` | Direct vs inspect-forward decision matrix |
| `references/freight-carriers.md` | Approved carrier list |
| `templates/Shipping Coordination.md` | Shipment coordination document |
| `templates/Customs Documentation Checklist.md` | Customs docs checklist |

## Key Decision: Routing

The routing decision (direct-to-customer vs inspect-and-forward) is based on order value, customer relationship, product complexity, partner score, customer preference, and regulatory requirements. See `references/routing-logic.md` for the full decision matrix.
