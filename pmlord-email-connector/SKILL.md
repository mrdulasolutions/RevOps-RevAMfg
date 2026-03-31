---
name: pmlord-email-connector
preamble-tier: 2
version: 1.0.0
description: |
  Parse emails for RFQs and order updates. Connects to Hostinger Email,
  Gmail, or generic inbox MCP tools to read incoming emails, classify them,
  extract actionable data, and route to the appropriate PMLORD skill.
compatibility: Claude Code, Claude desktop, Claude CoWork
allowed-tools:
  - Bash
  - Read
  - Write
  - Edit
  - Glob
  - Grep
  - AskUserQuestion
  - mcp__hostinger-email__read_emails
  - mcp__hostinger-email__search_emails
  - mcp__hostinger-email__list_accounts
  - mcp__hostinger-email__list_folders
  - mcp__bc6bacab-0618-4647-a346-785fcb37ca68__gmail_search_messages
  - mcp__bc6bacab-0618-4647-a346-785fcb37ca68__gmail_read_message
  - mcp__82432f48-58e6-4689-b9e9-e893b5e5b5bd__list_threads
  - mcp__82432f48-58e6-4689-b9e9-e893b5e5b5bd__get_thread
---

## Preamble (run first)

```bash
mkdir -p ~/.pmlord/analytics
echo '{"skill":"pmlord-email-connector","ts":"'$(date -u +%Y-%m-%dT%H:%M:%SZ)'"}' >> ~/.pmlord/analytics/skill-usage.jsonl 2>/dev/null || true
```

## Purpose

Connect to email inboxes used by Rev A Manufacturing PMs. Read incoming emails, classify them by type (RFQ, order update, partner communication, customer inquiry, etc.), extract actionable data, and route to the appropriate PMLORD skill for processing.

## Flow

### Step 1: Email Source Selection

Determine which email source to use:

> Which email inbox should I check?
> A) Hostinger Email (revamfg.com)
> B) Gmail
> C) Generic inbox (MCP)
> D) Paste email content directly

### Step 2: Email Retrieval

#### Hostinger Email
```
Use mcp__hostinger-email__search_emails or mcp__hostinger-email__read_emails
to fetch recent unprocessed emails.
```

#### Gmail
```
Use mcp__bc6bacab-0618-4647-a346-785fcb37ca68__gmail_search_messages
to search for relevant emails.
```

#### Generic Inbox
```
Use mcp__82432f48-58e6-4689-b9e9-e893b5e5b5bd__list_threads
to list recent threads.
```

### Step 3: Email Classification

Reference `prompts/email-parsing-system.md` for classification rules. Classify each email:

| Category | Keywords/Patterns | Route To |
|----------|------------------|----------|
| RFQ / Quote Request | "quote", "RFQ", "pricing", "request for quote" | pmlord-rfq-intake |
| Order Update | "PO", "order status", "shipment", "tracking" | pmlord-order-track |
| Partner Update | From known partner domain, mfg status | pmlord-order-track |
| Quality Issue | "defect", "NCR", "quality", "complaint" | pmlord-ncr / pmlord-escalate |
| Shipping Update | "tracking", "delivery", "customs", "AWB", "B/L" | pmlord-logistics |
| Customer Inquiry | General question, follow-up | pmlord-customer-comms |
| Payment | "invoice", "payment", "overdue" | pmlord-order-track |
| Spam / Irrelevant | Marketing, unrelated | Skip |

### Step 4: Data Extraction

For each classified email, extract relevant data using `prompts/email-parsing-system.md`:

- **Sender** — Name, email, company
- **Subject** — Email subject line
- **Date** — When the email was sent
- **Key Data** — Part numbers, quantities, PO numbers, tracking numbers, dates
- **Attachments** — Note any attachments (drawings, specs, POs, invoices)
- **Urgency** — Inferred urgency level

### Step 5: Routing Confirmation

**HUMAN-IN-THE-LOOP CHECKPOINT:**

> **Email Classification Results:**
>
> {{EMAIL_COUNT}} emails processed:
>
> | # | From | Subject | Category | Route To |
> |---|------|---------|----------|----------|
> | {{EMAIL_ROW_1}} |
> | {{EMAIL_ROW_2}} |
> | {{EMAIL_ROW_3}} |
>
> A) Process all as classified
> B) Reclassify a specific email
> C) Skip all
> D) Show email details

### Step 6: Route to Skills

For each confirmed email, invoke the target PMLORD skill with the extracted data. Log the routing:

```bash
echo '{"ts":"'$(date -u +%Y-%m-%dT%H:%M:%SZ)'","source":"{{EMAIL_SOURCE}}","from":"{{SENDER}}","subject":"{{SUBJECT}}","category":"{{CATEGORY}}","routed_to":"{{TARGET_SKILL}}","pm":"{{PM_NAME}}"}' >> ~/.pmlord/state/email-routing-log.jsonl
```

## Rules

1. **Never auto-process without PM confirmation.** Always present the classification for review.
2. **PII awareness.** Do not log full email bodies. Log sender, subject, category, and routing only.
3. **Attachment awareness.** Note attachments but do not process them automatically. Flag drawings and POs for PM review.
4. **Deduplication.** Check email-routing-log.jsonl to avoid processing the same email twice.
5. **Err toward RFQ.** If an email could be an RFQ or a general inquiry, classify as RFQ to ensure it gets proper intake processing.

## Template References

- `prompts/email-parsing-system.md` — System prompt for email classification and extraction
- `references/email-routing.md` — Email routing rules and patterns
