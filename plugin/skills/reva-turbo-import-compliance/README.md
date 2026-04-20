# reva-turbo-import-compliance — Import Compliance Gate

HTS classification, duty calculation, and customs documentation for goods arriving from China manufacturing partners. Powered by TradeInsights.ai API with manual classification fallback.

## Usage

```
/reva-turbo-import-compliance
```

Automatically triggered by the orchestrator after `reva-turbo-china-track` (goods shipped) and before `reva-turbo-logistics` (customs clearance).

## How It Works

1. **Detects TradeInsights.ai API** — checks for configured API key
2. **If not configured** — offers API setup or manual classification mode
3. **Collects shipment details** — products, materials, values, quantities
4. **HTS classification** — via TradeInsights API or manual reference tables
5. **Duty calculation** — MFN rate + Section 301 + AD/CVD + fees
6. **Documentation check** — verifies customs paperwork is complete
7. **Tariff mitigation** — identifies legal duty reduction opportunities
8. **PM decision gate** — PROCEED, HOLD, ESCALATE, or ADJUST

## TradeInsights.ai

| Feature | Details |
|---------|---------|
| Website | tradeinsights.ai |
| Integration | REST API with key-based auth |
| Capabilities | HTS classification, duty rates, tariff analysis, ruling search |
| Fallback | Built-in HTS reference tables for common manufactured parts |

## Pipeline Position

```
china-track (goods shipped) -> IMPORT COMPLIANCE -> logistics (customs entry) -> inspect
```

## Key Calculations

- MFN (Most Favored Nation) duty rate
- Section 301 tariffs (Lists 1-4A, China-specific)
- Anti-dumping / countervailing duties
- Merchandise Processing Fee (0.3464%)
- Harbor Maintenance Fee (0.125%, ocean only)

## Files

| File | Purpose |
|------|---------|
| `SKILL.md` | Full import compliance screening flow |
| `skill.yaml` | Manifest |
| `README.md` | This file |
| `prompts/import-system.md` | Classification methodology and customs guidance |
| `references/hts-common-codes.md` | Common HTS codes for manufactured parts |
| `references/section-301-lists.md` | Section 301 tariff list coverage |
| `references/adcvd-orders.md` | Anti-dumping/countervailing duty orders for China |
| `templates/Import Compliance Record.md` | Compliance record template |
| `bin/tradeinsights-check.sh` | API connectivity check script |
