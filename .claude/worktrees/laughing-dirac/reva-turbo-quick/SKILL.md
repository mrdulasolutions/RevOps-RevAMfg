---
name: reva-turbo-quick
preamble-tier: 1
version: 1.0.0
description: |
  One-shot speed commands for Rev A Manufacturing PMs. Natural language input
  is parsed for intent and entities, context is loaded from customer profiles,
  order history, and saved preferences, and all fields are pre-filled for
  one-click confirmation. Eliminates multi-step wizards for common actions.
compatibility: Claude Code, Claude desktop, Claude CoWork
allowed-tools:
  - Bash
  - Read
  - Write
  - Edit
  - Glob
  - Grep
  - AskUserQuestion
---

## Preamble (run first)

```bash
mkdir -p ~/.reva-turbo/analytics
echo '{"skill":"reva-turbo-quick","ts":"'$(date -u +%Y-%m-%dT%H:%M:%SZ)'"}' >> ~/.reva-turbo/analytics/skill-usage.jsonl 2>/dev/null || true
```

## Purpose

Make REVA-TURBO faster than email. PM types a natural language command and REVA-TURBO pre-fills everything from context, history, and saved preferences. One-click confirm instead of re-entry. Eliminates the 5-step wizard for common actions.

## Flow

### Step 1 — Parse Natural Language Input

Accept free-form input from the PM. Extract:

1. **Intent** — Which quick action? (quote, reorder, track, status, send update, inspect, ncr, scorecard, escalate, dashboard, etc.)
2. **Entities** — Customer name/abbreviation, part number, PO number, quantity, material, partner, date, reason
3. **Modifiers** — Urgency (rush, ASAP), format (pdf, docx), destination (email, slack)

Reference `prompts/quick-system.md` for parsing rules, entity extraction patterns, and disambiguation logic.

**Entity resolution order:**
1. Exact match on ID (PO#, Part#)
2. Exact match on abbreviation (from `~/.reva-turbo/preferences.yaml`)
3. Fuzzy match on name (customer, partner)
4. Most recent context (last order, last customer worked with)

If ambiguous, ask the PM to clarify:

> I found multiple matches for "acme":
>
> 1. **Acme Corporation** — 3 open orders (last: ORD-2026-0142)
> 2. **Acme Precision LLC** — 1 open order (last: ORD-2026-0088)
>
> Which one did you mean?

### Step 2 — Context Loading

Once entities are resolved, load all relevant context:

| Source | Data Loaded |
|--------|-------------|
| Customer profile (`~/.reva-turbo/state/customers/`) | Company, contacts, preferred partner, history |
| Last quote (`~/.reva-turbo/state/quotes/`) | Pricing, materials, quantities, margins |
| Last order (`~/.reva-turbo/state/orders/`) | Specs, status, partner, milestones |
| Saved preferences (`~/.reva-turbo/preferences.yaml`) | Default partner, margin, material, finish |
| Command history (`~/.reva-turbo/state/quick-history.jsonl`) | Last 10 commands for re-run |

### Step 3 — Pre-fill and Present

Populate all action fields from loaded context. Show the PM what will happen:

> **Quick Action: Quote for Acme Corporation**
>
> | Field | Pre-filled Value | Source |
> |-------|-----------------|--------|
> | Customer | Acme Corporation | Input |
> | Contact | John Smith (john@acme.com) | Customer profile |
> | Part | Widget-A (Rev C) | Last quote |
> | Quantity | 5,000 | Input |
> | Material | Aluminum 6061-T6 | Saved preference |
> | Finish | Clear anodize | Saved preference |
> | Partner | Shenzhen MFG Co. | Customer preferred |
> | Margin | 25% | Saved preference |
> | Estimated Price | $12,500 | Calculated |
>
> **A) Confirm and execute**
> **B) Edit a field before executing**
> **C) Cancel**

**HUMAN-IN-THE-LOOP:** Always show pre-filled data for PM to confirm. One-click confirm, never re-entry.

### Step 4 — Execute Quick Action

On confirmation, route to the appropriate REVA-TURBO skill with all fields pre-populated:

| Quick Action | Routes To | Pre-filled Fields |
|-------------|-----------|-------------------|
| `quote` | `/reva-turbo-rfq-quote` | Customer, part, qty, material, finish, partner, margin |
| `reorder` | `/reva-turbo-order-track` | All fields from previous order, updated dates |
| `track` | `/reva-turbo-china-track` | PO number, current milestones |
| `status` | `/reva-turbo-dashboard` | Customer filter applied |
| `send update` | `/reva-turbo-customer-comms` | Customer, order status, milestone data |
| `inspect` | `/reva-turbo-inspect` | PO number, specs, inspection checklist |
| `ncr` | `/reva-turbo-ncr` | PO number, part, partner, defect description |
| `scorecard` | `/reva-turbo-partner-scorecard` | Partner name, performance data |
| `escalate` | `/reva-turbo-escalate` | PO number, order context, reason |
| `dashboard` | `/reva-turbo-dashboard` | PM workload view |
| `profile` | `/reva-turbo-customer-profile` | Customer name, all profile data |
| `remind` | `/reva-turbo-reminder` | Order, date, message |
| `report` | `/reva-turbo-report` | Report type, customer/order scope |
| `package` | `/reva-turbo-china-package` | Order, partner, shipping specs |
| `logistics` | `/reva-turbo-logistics` | Order, shipping method, destination |
| `qualify` | `/reva-turbo-rfq-qualify` | RFQ data, customer, capabilities match |
| `gate` | `/reva-turbo-quality-gate` | Order, stage, checklist |
| `audit` | `/reva-turbo-audit-trail` | Reference ID, date range |
| `profit` | `/reva-turbo-profit` | Order or customer scope |
| `pulse` | `/reva-turbo-pulse` | Dashboard scope |

Reference `references/quick-actions.md` for the full catalog with syntax and examples.

### Step 5 — Log Command

```bash
mkdir -p ~/.reva-turbo/state
echo '{"ts":"'$(date -u +%Y-%m-%dT%H:%M:%SZ)'","action":"{{ACTION}}","input":"{{RAW_INPUT}}","entities":{"customer":"{{CUSTOMER}}","order":"{{ORDER_ID}}","part":"{{PART}}","partner":"{{PARTNER}}"},"result":"{{RESULT}}","pm":"{{PM_NAME}}"}' >> ~/.reva-turbo/state/quick-history.jsonl
```

Keep the last 50 commands. The PM can re-run any of the last 10:

> **Recent commands:**
>
> 1. `quote acme 5000 widget-a` — 2 hours ago
> 2. `track ORD-2026-0142` — yesterday
> 3. `status acme` — yesterday
> 4. `scorecard shenzhen` — 3 days ago
>
> Enter a number to re-run, or type a new command.

### Step 6 — Saved Preferences

Load preferences from `~/.reva-turbo/preferences.yaml`. Reference `references/preferences-schema.md` for the full schema.

If the PM says "set default partner to Shenzhen MFG" or "my default margin is 30%":

```bash
# Update preferences (handled by skill logic, not raw bash)
```

> Updated your default partner to **Shenzhen MFG Co.**
> This will be used for all future quick actions unless overridden.

### Step 7 — Abbreviations

PM can set shortcuts:

- "set alias acme = Acme Corporation"
- "set alias ray = Ray Yeh"
- "set alias widget = Widget-A Rev C"

Abbreviations are stored in `~/.reva-turbo/preferences.yaml` under `abbreviations:` and resolved in Step 1.

### Step 8 — Error Handling

| Situation | Action |
|-----------|--------|
| No matching action | Show closest matches + full action list |
| Missing required entity | Ask for the specific missing field only |
| No context found | Proceed with empty fields, note what's missing |
| Ambiguous entity | Show disambiguation menu (Step 1) |
| Stale context (>30 days old) | Warn PM: "Last quote is from 45 days ago. Prices may have changed." |

## Report Naming

Quick actions do not generate standalone reports. They route to other skills which handle their own naming.

## State Tracking

Command history: `~/.reva-turbo/state/quick-history.jsonl`
Preferences: `~/.reva-turbo/preferences.yaml`

## References

- `prompts/quick-system.md` — Natural language parsing rules and entity extraction
- `prompts/quick-user-template.md` — Quick action input variables
- `references/quick-actions.md` — Complete catalog of all quick actions
- `references/preferences-schema.md` — Saved preferences structure
