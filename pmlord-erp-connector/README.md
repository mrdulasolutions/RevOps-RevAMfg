# pmlord-erp-connector

ERP and inventory integration skill for the PMLORD engine.

## What It Does

Connects PMLORD to ERP and inventory management systems to provide:

1. Manufacturing capacity data (partner availability and utilization)
2. Material availability checks
3. Cost breakdowns (material, labor, overhead, tooling)
4. Production schedule information
5. Inventory levels and availability

## Flexible Backend

The connector is designed to work with whatever system Rev A Manufacturing uses:

- **No ERP:** Manual data entry with structured prompts
- **CSV/Excel:** Import from exported files
- **JSON:** Import from data files
- **API:** Direct connection to SAP, NetSuite, QuickBooks, or custom systems

## Usage

```
/pmlord-erp-connector
```

Or triggered by other PMLORD skills when capacity, cost, or inventory data is needed.

## Files

| File | Purpose |
|------|---------|
| `SKILL.md` | Skill instructions and flow |
| `skill.yaml` | Skill manifest |
| `references/erp-integration-patterns.md` | Integration approaches for various ERP systems |

## Configuration

ERP type is stored in `~/.pmlord/config/erp-config.json`. Data cached at `~/.pmlord/erp-data/`.
