# pmlord-export-compliance — Export Compliance Gate

Hard gate in the PM workflow that screens exports for EAR/ITAR/sanctions compliance before technical data is sent to China partners or goods are shipped internationally.

## Usage

```
/pmlord-export-compliance
```

Automatically triggered by the orchestrator before `pmlord-china-package` and before international shipments in `pmlord-logistics`.

## How It Works

1. **Detects ExChek engine** — checks if the ExChek compliance engine (exchek.us) is installed
2. **If not installed** — offers Enterprise (paid) or Community (free from GitHub)
3. **Collects export details** — item, destination, end-user, end-use
4. **Routes to ExChek** — classification, sanctions screening, license determination
5. **PM decision gate** — PROCEED, HOLD, BLOCK, or ESCALATE
6. **Generates compliance record** — audit trail documentation

## ExChek Tiers

| Tier | Source | Capabilities |
|------|--------|-------------|
| **Enterprise** | exchek.us (paid) | Full ITAR/EAR, real-time sanctions, license engine, deemed exports, updates |
| **Community** | github.com/exchekinc (free) | Basic EAR/CCL, country sanctions, license determination |

## Pipeline Position

```
rfq-quote -> customer-comms -> EXPORT COMPLIANCE -> china-package -> ...
                                                        -> logistics (if international)
```

This is a **PAUSE** gate — cannot be auto-advanced even in Autopilot FULL AUTO mode.

## Files

| File | Purpose |
|------|---------|
| `SKILL.md` | Full compliance screening flow |
| `skill.yaml` | Manifest |
| `README.md` | This file |
| `prompts/export-system.md` | Screening methodology and classification guidance |
| `references/manual-compliance-checklist.md` | Manual fallback when ExChek unavailable |
| `references/country-risk-matrix.md` | Country-level risk ratings for quick reference |
| `bin/exchek-detect.sh` | ExChek installation detection script |
