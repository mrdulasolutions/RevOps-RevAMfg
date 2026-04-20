# reva-turbo-email-connector

**Universal Email Connector for REVA-TURBO**

Connects to any email provider available in the Claude instance. Auto-detects connected inboxes, reads and classifies incoming emails, routes them to the appropriate REVA-TURBO skill, and handles outbound sending/replying.

## Supported Providers

| Provider | Auth | Read | Send | Reply | Search | Attachments |
|----------|------|------|------|-------|--------|-------------|
| **Hostinger** | IMAP/SMTP | Yes | Yes | Yes | Full-text + filters | Flag |
| **Gmail** | Google OAuth 2.0 | Yes | Via draft | Via draft | Gmail query syntax | Flag |
| **Microsoft 365 / Outlook** | Microsoft OAuth 2.0 | Yes | Direct | Direct + reply-all | Date + label filter | Download |
| **Any MCP Inbox** | Per connector | Yes | Yes | Yes | Per connector | Per connector |
| **Direct Paste** | None | Paste | No | No | No | No |

## Usage

```
/reva-turbo-email-connector              # Scan inbox (auto-detect provider)
/reva-turbo-email-connector mode:send    # Send email via configured provider
/reva-turbo-email-connector mode:reply   # Reply to a thread
/reva-turbo-email-connector mode:search  # Search across all connected inboxes
/reva-turbo-email-connector mode:setup   # Set up a new email provider
```

Or ask REVA-TURBO naturally:
- "Check my email for new RFQs"
- "Send the quote to buyer@acme.com"
- "Reply to the shipping update from DHL"
- "Search for emails from Acme Corp about PO-2026-0089"

## How It Works

1. **Auto-detect** which email providers are connected (tests each MCP connector)
2. **Retrieve** emails from the selected provider
3. **Classify** each email: RFQ, order update, partner update, quality issue, shipping, compliance, etc.
4. **Present** classification table to PM for review (human-in-the-loop)
5. **Route** confirmed emails to the appropriate REVA-TURBO skill
6. **Log** all routing decisions to `~/.reva-turbo/state/email-routing-log.jsonl`

## Modes

| Mode | Description |
|------|-------------|
| `scan` | Default — scan inbox, classify, and route emails |
| `send` | Send an email (used by reva-turbo-customer-comms and other skills) |
| `reply` | Reply to a specific email thread |
| `search` | Search across all connected inboxes |
| `setup` | Guide through connecting a new email provider |

## Multi-Provider Support

REVA-TURBO can connect to multiple email providers simultaneously. When scanning:
- **Single provider:** Scans that inbox
- **Multiple providers:** PM selects which to scan, or "all" for unified scan
- **Auto mode:** Detects all available providers each time

Configure in `~/.reva-turbo/connector-config.yaml` (via `/reva-turbo:reva-turbo-setup section:3`).

## Files

| File | Purpose |
|------|---------|
| `SKILL.md` | Full connector instructions — detection, retrieval, classification, sending |
| `skill.yaml` | Skill manifest |
| `prompts/email-parsing-system.md` | Classification rules and data extraction logic |
| `references/email-routing.md` | Routing decision tree, known domains, dedup strategy |
| `references/connector-setup.md` | Step-by-step setup for Hostinger, Gmail, Microsoft 365 |

## Setup Guides

- **Hostinger:** Add hostinger-email MCP server with IMAP/SMTP credentials
- **Gmail:** Add Gmail MCP server — OAuth one-click authorization
- **Microsoft 365:** Add Generic Inbox MCP server with Microsoft OAuth (Azure AD app registration for enterprise)

See `references/connector-setup.md` for full instructions.

## Data

| File | Purpose |
|------|---------|
| `~/.reva-turbo/state/email-routing-log.jsonl` | Routing history (sender, subject, category, skill, timestamp) |
| `~/.reva-turbo/connector-config.yaml` | Provider configuration (set via reva-turbo-setup) |
