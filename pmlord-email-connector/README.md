# pmlord-email-connector

Email parsing and routing skill for the PMLORD engine.

## What It Does

Connects to Rev A Manufacturing email inboxes and processes incoming messages:

1. Reads emails from Hostinger (revamfg.com), Gmail, or generic inbox MCP tools
2. Classifies each email (RFQ, order update, partner communication, quality issue, etc.)
3. Extracts actionable data (PO numbers, tracking numbers, quantities, dates)
4. Routes classified emails to the appropriate PMLORD skill for processing

## Supported Email Sources

- **Hostinger Email** — Primary revamfg.com inbox (via hostinger-email MCP)
- **Gmail** — Gmail accounts (via Gmail MCP)
- **Generic Inbox** — Any MCP-connected inbox
- **Direct Paste** — PM can paste email content directly

## Usage

```
/pmlord-email-connector
```

Or ask PMLORD to check email for new RFQs or order updates.

## Files

| File | Purpose |
|------|---------|
| `SKILL.md` | Skill instructions and flow |
| `skill.yaml` | Skill manifest |
| `prompts/email-parsing-system.md` | Classification and extraction logic |
| `references/email-routing.md` | Routing rules and patterns |

## Data

Email routing history is stored at `~/.pmlord/state/email-routing-log.jsonl`.
