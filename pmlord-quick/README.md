# pmlord-quick

One-shot speed commands for the PMLORD engine.

## What It Does

Eliminates multi-step wizards by parsing natural language input into fully pre-filled actions:

1. Parses natural language input for intent and entities (customer, part, PO, partner)
2. Loads context from customer profiles, order history, and saved preferences
3. Pre-fills all fields and presents for one-click confirmation
4. Routes to the appropriate PMLORD skill with everything populated
5. Maintains command history for instant re-runs

## Quick Actions

| Command | What It Does |
|---------|-------------|
| `quote [customer] [qty] [part]` | Pre-fill quote from history + customer profile |
| `reorder [customer] [PO#]` | Duplicate previous order with updated dates |
| `track [PO#]` | Instant status pull from workflow state |
| `status [customer]` | All open orders for customer in one view |
| `send update [customer]` | Draft status update from current order data |
| `inspect [PO#]` | Pull specs and generate inspection checklist |
| `ncr [PO#] [defect]` | Pre-fill NCR from order + inspection data |
| `scorecard [partner]` | Instant partner score with trend |
| `escalate [PO#] [reason]` | Pre-fill escalation from order context |
| `dashboard` | Instant PM workload view |
| `profile [customer]` | Load customer profile |
| `remind [order] [date] [msg]` | Set a reminder |
| `report [type] [scope]` | Generate a report |
| `logistics [PO#]` | Check shipping status |
| `qualify [RFQ]` | Quick-qualify an RFQ |
| `profit [order/customer]` | Profit analysis |
| `pulse` | System health pulse |

## Features

- **Abbreviations** — Set shortcuts ("acme" = "Acme Corporation")
- **Saved preferences** — Default partner, margin, material, finish
- **Command history** — Last 10 commands available for re-run
- **Smart disambiguation** — Fuzzy matching with clarification when needed

## Usage

```
/pmlord-quick
```

Then type any natural language command.

## Files

| File | Purpose |
|------|---------|
| `SKILL.md` | Skill instructions and flow |
| `skill.yaml` | Skill manifest |
| `prompts/quick-system.md` | NLP parsing rules and entity extraction |
| `prompts/quick-user-template.md` | Quick action input variables |
| `references/quick-actions.md` | Complete catalog of all quick actions |
| `references/preferences-schema.md` | Saved preferences structure |
