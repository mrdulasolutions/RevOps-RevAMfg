---
name: reva-turbo-email-connector
preamble-tier: 2
version: 1.2.0
description: |
  Universal email connector for REVA-TURBO. Auto-detects available email providers
  and supports reading, sending, replying, searching, and classifying emails
  across all connected inboxes. Routes classified emails to the appropriate
  REVA-TURBO skill. Supports Hostinger, Gmail, Microsoft 365/Outlook, and any
  MCP-connected inbox.
compatibility: Claude Code, Claude desktop, Claude CoWork
allowed-tools:
  - Bash
  - Read
  - Write
  - Edit
  - Glob
  - Grep
  - AskUserQuestion
  # --- Hostinger Email (IMAP/SMTP via MCP) ---
  - mcp__hostinger-email__read_emails
  - mcp__hostinger-email__search_emails
  - mcp__hostinger-email__send_email
  - mcp__hostinger-email__reply_to_email
  - mcp__hostinger-email__list_accounts
  - mcp__hostinger-email__list_folders
  - mcp__hostinger-email__mark_email
  - mcp__hostinger-email__move_email
  - mcp__hostinger-email__delete_email
  # --- Gmail (Google OAuth via MCP) ---
  - mcp__bc6bacab-0618-4647-a346-785fcb37ca68__gmail_search_messages
  - mcp__bc6bacab-0618-4647-a346-785fcb37ca68__gmail_read_message
  - mcp__bc6bacab-0618-4647-a346-785fcb37ca68__gmail_read_thread
  - mcp__bc6bacab-0618-4647-a346-785fcb37ca68__gmail_create_draft
  - mcp__bc6bacab-0618-4647-a346-785fcb37ca68__gmail_list_drafts
  - mcp__bc6bacab-0618-4647-a346-785fcb37ca68__gmail_get_profile
  - mcp__bc6bacab-0618-4647-a346-785fcb37ca68__gmail_list_labels
  # --- Microsoft 365 / Outlook / Generic Inbox (OAuth via MCP) ---
  - mcp__82432f48-58e6-4689-b9e9-e893b5e5b5bd__list_inboxes
  - mcp__82432f48-58e6-4689-b9e9-e893b5e5b5bd__list_threads
  - mcp__82432f48-58e6-4689-b9e9-e893b5e5b5bd__get_thread
  - mcp__82432f48-58e6-4689-b9e9-e893b5e5b5bd__get_inbox
  - mcp__82432f48-58e6-4689-b9e9-e893b5e5b5bd__send_message
  - mcp__82432f48-58e6-4689-b9e9-e893b5e5b5bd__reply_to_message
  - mcp__82432f48-58e6-4689-b9e9-e893b5e5b5bd__forward_message
  - mcp__82432f48-58e6-4689-b9e9-e893b5e5b5bd__get_attachment
  - mcp__82432f48-58e6-4689-b9e9-e893b5e5b5bd__update_message
  - mcp__82432f48-58e6-4689-b9e9-e893b5e5b5bd__create_inbox
---

## Preamble (run first)

```bash
mkdir -p ~/.reva-turbo/analytics ~/.reva-turbo/state
echo '{"skill":"reva-turbo-email-connector","ts":"'$(date -u +%Y-%m-%dT%H:%M:%SZ)'"}' >> ~/.reva-turbo/analytics/skill-usage.jsonl 2>/dev/null || true
_EMAIL_PROVIDER=$(~/.claude/skills/reva-turbo/bin/reva-turbo-config get email_provider 2>/dev/null || echo "auto")
echo "EMAIL_PROVIDER: $_EMAIL_PROVIDER"
```

## Purpose

Universal email connector for Rev A Manufacturing PMs. Connects to ANY email provider available in the Claude instance — Hostinger (revamfg.com), Gmail, Microsoft 365/Outlook, or any MCP-connected inbox. Reads, sends, replies, searches, classifies, and routes emails to the appropriate REVA-TURBO skill.

## Supported Providers

### Primary: Native Claude Microsoft 365 Connector

**This is the recommended primary email integration.** Claude has a built-in, first-party Microsoft 365 connector that provides native access to Outlook email, Teams Chat, Calendar, SharePoint, and OneDrive.

**Requirements:**
- Claude **Team or Enterprise plan** (not available on Free or Pro)
- Microsoft Entra ID (Azure AD) Global Administrator for initial setup
- Active Microsoft 365 accounts for users

**Capabilities:** READ-ONLY — search and read Outlook emails, threads, and attachments. Claude acts on behalf of the user's Microsoft 365 account and can only access data they already have permission to view. Cannot send, create, edit, or delete emails.

**Permissions requested (all delegated, read-only):**
- Mail.Read, Mail.ReadBasic, Mail.Read.Shared, MailboxFolder.Read, MailboxItem.Read
- Calendars.Read, Calendars.Read.Shared
- Chat.Read, Chat.ReadBasic, ChatMessage.Read
- Files.Read, Files.Read.All, Sites.Read.All

**Setup:** Organization Owner enables at Settings > Connectors > Microsoft 365. Admin completes OAuth consent flow via Microsoft Entra ID. Team members then authenticate individually at Settings > Connectors.

**Full setup guide:** https://support.claude.com/en/articles/12542951-enabling-and-using-the-microsoft-365-connector

**How REVA-TURBO uses it:** When this connector is enabled, simply ask Claude to search or read Outlook emails directly. No MCP tool calls needed — Claude's native M365 integration handles retrieval. REVA-TURBO classifies and routes the results.

Example prompts that leverage the native connector:
- "Search my Outlook for unread emails about RFQs from this week"
- "Read the email thread with Acme Corp about PO-2026-0089"
- "Find all emails from our customs broker in the last 30 days"
- "Show me emails with attached drawings from the past week"

### Secondary / Sending Providers

Since the native M365 connector is read-only, REVA-TURBO uses these providers for sending, replying, and advanced email management:

| Provider | Connector | Auth | Read | Send | Reply | Search | Attachments |
|----------|-----------|------|------|------|-------|--------|-------------|
| **Native Claude M365** | Built-in (Team/Enterprise) | Microsoft OAuth (Entra ID) | Yes | No (read-only) | No | Yes (native) | Yes (read) |
| **Hostinger** | hostinger-email MCP | IMAP/SMTP | Yes | Yes | Yes | Yes | Flag only |
| **Gmail** | Gmail MCP | Google OAuth 2.0 | Yes | Via draft | Via draft | Yes | Flag only |
| **MCP Inbox (M365)** | Generic Inbox MCP | OAuth 2.0 | Yes | Yes | Yes | Via filter | Yes (download) |
| **Direct Paste** | None | None | Yes | No | No | No | No |

### Recommended Configuration for Rev A Manufacturing

1. **Native Claude M365** — Primary for reading and searching Outlook (requires Team/Enterprise plan)
2. **Hostinger MCP** — Primary for sending from @revamfg.com
3. **MCP Inbox connector** — Fallback for M365 send/reply if Hostinger isn't configured

## Flow

### Step 0: Provider Auto-Detection

Before anything else, detect which email providers are available:

**Priority 1 — Native Claude M365 Connector:**
Check if the PM is on a Claude Team or Enterprise plan with M365 connector enabled. If yes, this is the primary read/search provider. No MCP tool test needed — Claude's native connector just works when enabled.

**Priority 2 — MCP Connectors (test each):**

**Test order:**

1. **Hostinger** — Try `mcp__hostinger-email__list_accounts`. If it returns accounts, Hostinger is available.
2. **Gmail** — Try `mcp__bc6bacab-0618-4647-a346-785fcb37ca68__gmail_get_profile`. If it returns a profile, Gmail is available.
3. **Microsoft / Generic Inbox** — Try `mcp__82432f48-58e6-4689-b9e9-e893b5e5b5bd__list_inboxes`. If it returns inboxes, Microsoft/Generic is available.

**If the PM has set `email_provider` in config**, skip detection and use that provider directly.

**If multiple providers are available**, present them:

> I detected the following email providers:
>
> A) Native Claude M365 / Outlook (primary — read/search)
> B) Hostinger (revamfg.com) — {{ACCOUNT_COUNT}} accounts (read + send)
> C) Gmail ({{GMAIL_ADDRESS}})
> D) MCP Inbox / Microsoft 365 ({{INBOX_COUNT}} inboxes — read + send)
> D) Paste email content directly
>
> Which inbox should I check? (or type "all" to scan all providers)

**If no providers are detected:**

> No email connectors are available. You can:
>
> A) Paste email content directly — I'll classify and route it
> B) Set up a connector — see the setup guide below
>
> **Recommended setup (in priority order):**
> 1. **Native Claude M365 Connector** (best) — Requires Claude Team or Enterprise plan. Enable at Settings > Connectors > Microsoft 365. Your org admin must complete the Microsoft Entra ID OAuth consent flow. Setup guide: https://support.claude.com/en/articles/12542951-enabling-and-using-the-microsoft-365-connector
> 2. **Hostinger:** Add the hostinger-email MCP server in Claude settings (for @revamfg.com)
> 3. **Gmail:** Add the Gmail MCP server (OAuth — one-click in Claude)
> 4. **MCP Inbox (M365):** Add the Generic Inbox MCP server with Microsoft OAuth (for send/reply via M365)
>
> See `references/connector-setup.md` for step-by-step instructions.

### Step 1: Email Retrieval

#### Native Claude M365 Connector (Primary)

When the native M365 connector is enabled, use natural language to search Outlook directly through Claude's built-in integration. No MCP tool calls needed.

**Reading emails:**
Simply ask Claude to access Outlook. The native connector handles the Microsoft Graph API calls transparently:
- "Search my Outlook inbox for unread emails from the last 3 days"
- "Find emails with subject containing 'RFQ' or 'quote request'"
- "Show me the email thread about PO-2026-0089"
- "Read emails from acme.com received this week"
- "Find all emails with PDF attachments from our customs broker"

**What it can access:**
- Outlook inbox, sent items, folders, and archived emails
- Email threads and conversations
- Attachment metadata (file names, types, sizes)
- Calendar items and meeting details (via Teams Calendar)
- Teams Chat messages
- SharePoint and OneDrive documents

**What it CANNOT do (read-only):**
- Send emails (use Hostinger or MCP Inbox for sending)
- Reply to emails (use Hostinger or MCP Inbox for replies)
- Delete, move, or mark emails
- Create drafts

**Plan requirement:** Claude Team or Enterprise plan. If not available, fall through to MCP connectors below.

#### Hostinger Email

```
# List all accounts
mcp__hostinger-email__list_accounts

# Search for emails (with powerful filtering)
mcp__hostinger-email__search_emails
  account: "pm@revamfg.com"    # or account label
  query: "RFQ"                  # full-text search
  since: "2026-03-25"           # date range
  from_addr: "buyer@acme.com"   # filter by sender
  folder: "INBOX"               # folder to search
  limit: 20

# Read specific emails
mcp__hostinger-email__read_emails
  account: "pm@revamfg.com"
  folder: "INBOX"
  limit: 20
```

#### Gmail

```
# Search with Gmail's powerful query syntax
mcp__bc6bacab-0618-4647-a346-785fcb37ca68__gmail_search_messages
  q: "is:unread from:customer has:attachment"
  maxResults: 20

# Read specific message
mcp__bc6bacab-0618-4647-a346-785fcb37ca68__gmail_read_message
  messageId: "{{MESSAGE_ID}}"

# Read full thread
mcp__bc6bacab-0618-4647-a346-785fcb37ca68__gmail_read_thread
  threadId: "{{THREAD_ID}}"
```

**Gmail search syntax cheat sheet:**
- `is:unread` — unread messages
- `from:sender@example.com` — from specific sender
- `to:recipient@example.com` — to specific recipient
- `subject:quote` — subject contains "quote"
- `has:attachment` — has attachments
- `after:2026/3/25 before:2026/3/31` — date range
- `label:important` — specific label
- `"exact phrase"` — exact match
- `-from:spam@example.com` — exclude sender
- Combine: `is:unread from:customer has:attachment after:2026/3/25`

#### Microsoft 365 / Outlook / Generic Inbox

```
# List available inboxes
mcp__82432f48-58e6-4689-b9e9-e893b5e5b5bd__list_inboxes
  limit: 10

# List threads in inbox (with date filtering)
mcp__82432f48-58e6-4689-b9e9-e893b5e5b5bd__list_threads
  inboxId: "{{INBOX_ID}}"
  after: "2026-03-25T00:00:00Z"    # filter by date
  limit: 20

# Get full thread with all messages
mcp__82432f48-58e6-4689-b9e9-e893b5e5b5bd__get_thread
  inboxId: "{{INBOX_ID}}"
  threadId: "{{THREAD_ID}}"

# Get attachment
mcp__82432f48-58e6-4689-b9e9-e893b5e5b5bd__get_attachment
  (parameters per connector docs)
```

#### Direct Paste

If no connector is available or the PM prefers to paste content:

> Paste the email content below (include From, Subject, Date, and body):

Parse the pasted text to extract sender, subject, date, and body.

### Step 2: Email Classification

Reference `prompts/email-parsing-system.md` for full classification rules.

Classify each email into one of these categories:

| Category | Keywords/Patterns | Route To |
|----------|------------------|----------|
| **RFQ / Quote Request** | "quote", "RFQ", "pricing", "request for quote", "bid" | reva-turbo-rfq-intake |
| **Order Update** | "PO", "order status", references existing PO number | reva-turbo-order-track |
| **Partner Update** | From known partner domain, production/QC status | reva-turbo-china-track |
| **Quality Issue** | "defect", "NCR", "quality", "complaint", "damaged" | reva-turbo-ncr / reva-turbo-escalate |
| **Shipping Update** | "tracking", "AWB", "B/L", "customs", carrier domains | reva-turbo-logistics |
| **Customer Inquiry** | General question, follow-up, relationship | reva-turbo-customer-comms |
| **Payment / Invoice** | "invoice", "payment", "overdue", "remittance" | reva-turbo-order-track |
| **Compliance** | "ITAR", "EAR", "export license", "HTS", "tariff" | reva-turbo-export-compliance / reva-turbo-import-compliance |
| **Spam / Irrelevant** | Marketing, newsletters, auto-replies | Skip |

### Step 3: Data Extraction

For each classified email, extract:

| Field | How to Find |
|-------|------------|
| Sender Name | From header or signature |
| Sender Email | From header |
| Sender Company | Domain, signature block, body context |
| Subject | Subject header |
| Date Sent | Date header |
| PO Numbers | Patterns: PO-XXXX, PO#XXXX, Purchase Order XXXX |
| Part Numbers | Alphanumeric identifiers in context |
| Quantities | Numbers associated with parts |
| Tracking Numbers | Carrier tracking format patterns |
| Dates Mentioned | Delivery dates, ship dates, deadlines |
| Dollar Amounts | Prices, values, totals |
| Attachments | File names and types (PDF, DWG, STEP, XLSX) |
| Urgency | "urgent", "ASAP", "expedite", deadline proximity |

### Step 4: Routing Confirmation

**HUMAN-IN-THE-LOOP CHECKPOINT:**

> **Email Scan Results** — {{PROVIDER_NAME}} — {{TIMESTAMP}}
>
> {{EMAIL_COUNT}} emails processed:
>
> | # | From | Subject | Category | Route To | Urgency |
> |---|------|---------|----------|----------|---------|
> | 1 | {{SENDER_1}} | {{SUBJECT_1}} | {{CATEGORY_1}} | {{ROUTE_1}} | {{URGENCY_1}} |
> | 2 | {{SENDER_2}} | {{SUBJECT_2}} | {{CATEGORY_2}} | {{ROUTE_2}} | {{URGENCY_2}} |
>
> A) Process all as classified
> B) Reclassify a specific email (tell me which #)
> C) Skip all
> D) Show full email content for a specific #
> E) Reply to a specific email

### Step 5: Route to Skills

For each confirmed email, invoke the target REVA-TURBO skill with the extracted data.

Log the routing:
```bash
echo '{"ts":"'$(date -u +%Y-%m-%dT%H:%M:%SZ)'","provider":"{{PROVIDER}}","from":"{{SENDER}}","subject":"{{SUBJECT}}","category":"{{CATEGORY}}","routed_to":"{{TARGET_SKILL}}","pm":"{{PM_NAME}}","message_id":"{{MESSAGE_ID}}"}' >> ~/.reva-turbo/state/email-routing-log.jsonl
```

### Step 6: Send / Reply (when requested)

The email connector also handles OUTBOUND email when other skills need to send:

#### Sending via Hostinger
```
mcp__hostinger-email__send_email
  account: "pm@revamfg.com"
  to: "buyer@acme.com"
  subject: "Re: Quote Request - Aluminum Bracket"
  body: "{{EMAIL_BODY}}"
  html: "{{HTML_BODY}}"           # optional rich HTML
  cc: "manager@acme.com"          # optional
```

#### Sending via Gmail (draft-then-send)
```
# Gmail MCP creates drafts — PM reviews and sends from Gmail
mcp__bc6bacab-0618-4647-a346-785fcb37ca68__gmail_create_draft
  to: "buyer@acme.com"
  subject: "Re: Quote Request - Aluminum Bracket"
  body: "{{EMAIL_BODY}}"
  contentType: "text/html"         # or "text/plain"
  threadId: "{{THREAD_ID}}"        # reply in thread
```

> **Note:** Gmail connector creates drafts. The PM reviews and clicks Send in Gmail. This is safer and preserves human-in-the-loop.

#### Sending via Microsoft 365 / Generic Inbox
```
# Send directly
mcp__82432f48-58e6-4689-b9e9-e893b5e5b5bd__send_message
  inboxId: "{{INBOX_ID}}"
  to: ["buyer@acme.com"]
  subject: "Re: Quote Request - Aluminum Bracket"
  text: "{{PLAIN_TEXT_BODY}}"
  html: "{{HTML_BODY}}"
  cc: ["manager@acme.com"]

# Reply to existing thread
mcp__82432f48-58e6-4689-b9e9-e893b5e5b5bd__reply_to_message
  inboxId: "{{INBOX_ID}}"
  messageId: "{{MESSAGE_ID}}"
  text: "{{REPLY_BODY}}"
  html: "{{HTML_REPLY}}"
  replyAll: true                   # reply to all recipients

# Forward a message
mcp__82432f48-58e6-4689-b9e9-e893b5e5b5bd__forward_message
  inboxId: "{{INBOX_ID}}"
  messageId: "{{MESSAGE_ID}}"
  to: ["colleague@revamfg.com"]
  text: "FYI — see below"
```

#### Sending via iMessage (pulse alerts only)
For urgent pulse alerts, the engine can also send via iMessage on macOS:
```
mcp__Read_and_Send_iMessages__send_imessage
```
This is NOT for customer communications — only internal PM alerts.

## Modes

### mode: scan (default)
Scan inbox for new emails, classify, and route. This is the standard intake flow.

### mode: send
Send an email on behalf of the PM. Used by reva-turbo-customer-comms and other skills.

Parameters: `to`, `subject`, `body`, `provider` (optional — uses default)

### mode: reply
Reply to a specific email thread.

Parameters: `message_id` or `thread_id`, `body`, `reply_all` (boolean)

### mode: search
Search across all connected inboxes for specific emails.

Parameters: `query`, `from`, `date_range`, `provider` (optional — searches all)

### mode: setup
Guide the PM through connecting a new email provider. See `references/connector-setup.md`.

## Provider Management

After detection, save the PM's preferred provider:

```bash
~/.claude/skills/reva-turbo/bin/reva-turbo-config set email_provider "{{PROVIDER}}"
```

Valid values: `hostinger`, `gmail`, `microsoft`, `generic`, `auto` (detect each time)

If the PM has multiple providers, store the mapping in connector-config.yaml:
```yaml
email:
  provider: "hostinger"                    # primary provider for sending
  providers_available:
    - type: hostinger
      account: "pm@revamfg.com"
      use_for: [send, receive, search]
    - type: gmail
      account: "pm@gmail.com"
      use_for: [receive, search]           # read-only, drafts for send
    - type: microsoft
      inbox_id: "{{INBOX_ID}}"
      account: "pm@revamfg.onmicrosoft.com"
      use_for: [send, receive, search]
```

## Email Management Actions

Beyond routing, the connector supports email management:

### Hostinger
- **Mark read/unread:** `mcp__hostinger-email__mark_email` (flag: read/unread/flagged/unflagged)
- **Move to folder:** `mcp__hostinger-email__move_email` (e.g., move processed emails to "REVA-TURBO-Processed")
- **Delete:** `mcp__hostinger-email__delete_email` (moves to Trash)

### Gmail
- **Labels:** `mcp__bc6bacab-0618-4647-a346-785fcb37ca68__gmail_list_labels` (view labels for filtering)

### Microsoft / Generic
- **Update message:** `mcp__82432f48-58e6-4689-b9e9-e893b5e5b5bd__update_message` (mark read, flag, etc.)
- **Get attachment:** `mcp__82432f48-58e6-4689-b9e9-e893b5e5b5bd__get_attachment` (download attachments)

## Post-Processing

After emails are routed:

1. **Mark as processed** — Mark read or move to REVA-TURBO-Processed folder (Hostinger) or apply label (Gmail)
2. **Log routing** — Append to `~/.reva-turbo/state/email-routing-log.jsonl`
3. **Dedup check** — Before processing, check log for message_id to avoid duplicate processing
4. **Pulse alert** — If any email is CRITICAL urgency, trigger `reva-turbo-pulse` alert

## Rules

1. **Never auto-send without PM confirmation.** All outbound emails require PM review before sending. Gmail enforces this via drafts. Hostinger and Microsoft show the draft for approval first.
2. **Never auto-process inbound without PM confirmation.** Always present the classification table for review before routing.
3. **PII awareness.** Do not log full email bodies. Log sender, subject, category, routing, and message_id only.
4. **Attachment awareness.** Note attachments but do not auto-download. Flag drawings (DWG, STEP) and POs (PDF) for PM review.
5. **Deduplication.** Check email-routing-log.jsonl by message_id before processing.
6. **Err toward RFQ.** If an email could be an RFQ or general inquiry, classify as RFQ.
7. **Voice profile.** When sending emails, apply the PM's voice profile (greeting style, signoff, tone, etc.).
8. **Provider fallback.** If the preferred provider fails, offer to try another detected provider.

## Template References

- `prompts/email-parsing-system.md` — Classification rules and extraction logic
- `references/email-routing.md` — Routing decision tree and sender domain database
- `references/connector-setup.md` — Step-by-step setup for each email provider
