---
name: reva-turbo-comms-preferences
preamble-tier: 2
version: 1.0.0
description: |
  Manage communication channel and frequency preferences per PM, per customer,
  and per alert type. Consumed by reva-turbo-pulse, reva-turbo-reminder, and
  reva-turbo-customer-comms to route messages to the right channel at the right time.
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
mkdir -p ~/.reva-turbo/analytics ~/.reva-turbo/config
echo '{"skill":"reva-turbo-comms-preferences","ts":"'$(date -u +%Y-%m-%dT%H:%M:%SZ)'"}' >> ~/.reva-turbo/analytics/skill-usage.jsonl 2>/dev/null || true
```

## Purpose

Manage communication channel and frequency preferences for Rev A Manufacturing PM workflow. Preferences are defined at three levels: PM-level defaults, per-customer overrides, and per-alert-type rules. These preferences are read by reva-turbo-pulse, reva-turbo-reminder, and reva-turbo-customer-comms to route messages to the correct channel at the right time — and to respect quiet hours and response SLA expectations.

## Preferences Schema

Stored at `~/.reva-turbo/config/comms-preferences.yaml`:

```yaml
pm_preferences:
  default_channel: email          # email | slack | imessage
  escalation_channel: imessage    # channel for urgent / compliance alerts
  daily_digest: true              # receive daily pipeline digest
  quiet_hours: "20:00-08:00"     # local time — no non-urgent alerts during this window

customer_preferences:
  acme-corp:                      # customer-slug (from customer profile)
    preferred_channel: email
    response_sla_hours: 24        # expected response time from customer
    language: en                  # en | es | zh | other
    cc_list:
      - procurement@acme-corp.com
  shenzhen-dynamics:
    preferred_channel: email
    response_sla_hours: 48
    language: en
    cc_list: []

alert_preferences:
  compliance_block: imessage      # EAR/ITAR block — always urgent, always immediate
  quality_fail: email+slack       # Quality gate failure — email + slack
  order_overdue: slack            # Order past SLA — slack
  quote_followup: email           # Quote follow-up reminder — email
  partner_delay: slack            # China partner delay flag — slack
  cron_failure: imessage          # Cron task failure — urgent
  ncr_opened: email+slack         # NCR opened — email + slack
  pricing_conflict: imessage      # Sync pricing conflict — urgent
  milestone_alert: slack          # Manufacturing milestone alert — slack
  daily_digest: email             # Daily pipeline digest — email
```

**Channel values:**
- `email` — send via configured email provider (reva-turbo-email-connector)
- `slack` — send via Slack MCP (reva-turbo-pulse)
- `imessage` — send via iMessage MCP (reva-turbo-pulse) — for urgent/escalation
- `email+slack` — send to both channels
- `none` — disable this alert type

## Flow

### Step 1 — Parse Command

- `view` → Step 2
- `set-pm` → Step 3
- `set-customer <customer-slug>` → Step 4
- `set-alert <alert-type> <channel>` → Step 5
- No argument → show current preferences (Step 2)

### Step 2 — View Preferences (`view`)

```bash
cat ~/.reva-turbo/config/comms-preferences.yaml 2>/dev/null || echo "No preferences file found. Run 'set-pm' to configure."
```

Present formatted preferences:

> **REVA-TURBO Communications Preferences**
>
> **PM Defaults:**
> Default channel: {{DEFAULT_CHANNEL}}
> Escalation channel: {{ESCALATION_CHANNEL}}
> Daily digest: {{DAILY_DIGEST}}
> Quiet hours: {{QUIET_HOURS}} (local time — no non-urgent alerts)
>
> **Alert Routing:**
> | Alert Type | Channel |
> |-----------|---------|
> | Compliance block | {{CHANNEL}} |
> | Quality fail | {{CHANNEL}} |
> | Order overdue | {{CHANNEL}} |
> | Quote follow-up | {{CHANNEL}} |
> | NCR opened | {{CHANNEL}} |
> | Cron failure | {{CHANNEL}} |
> | Daily digest | {{CHANNEL}} |
>
> **Customer Preferences ({{COUNT}} configured):**
> | Customer | Channel | SLA | Language | CC List |
> |---------|---------|-----|----------|---------|
> | {{CUSTOMER}} | {{CHANNEL}} | {{SLA}}h | {{LANG}} | {{CC}} |

### Step 3 — Set PM Preferences (`set-pm`)

Ask PM interactively:

1. **Default channel** — Where should routine alerts go? (email / slack / imessage)
2. **Escalation channel** — Where should urgent alerts go? (recommend imessage for immediate visibility)
3. **Daily digest** — Receive a daily pipeline summary? (yes/no)
4. **Quiet hours** — Set quiet hours when non-urgent alerts are held? (e.g. "20:00-08:00" local time)

Write to `~/.reva-turbo/config/comms-preferences.yaml` under `pm_preferences`.

```bash
# Initialize or update pm_preferences section
_PREFS_FILE="$HOME/.reva-turbo/config/comms-preferences.yaml"
[ -f "$_PREFS_FILE" ] || touch "$_PREFS_FILE"
```

Confirm to PM: "PM preferences saved. Default channel: {{CHANNEL}}. Escalation channel: {{ESCALATION}}. Quiet hours: {{QUIET}}."

### Step 4 — Set Customer Preferences (`set-customer <customer-slug>`)

Ask PM for:
1. **Preferred channel** — How does this customer prefer to receive communications?
2. **Response SLA hours** — How many hours should Rev A wait before following up on an unanswered email?
3. **Language** — Primary language for customer communications
4. **CC list** — Any additional recipients to CC on customer emails (comma-separated)

Write to `~/.reva-turbo/config/comms-preferences.yaml` under `customer_preferences.<slug>`.

Confirm: "Customer preferences saved for {{CUSTOMER_NAME}}."

### Step 5 — Set Alert Preference (`set-alert <alert-type> <channel>`)

Valid alert types:
- `compliance_block`, `quality_fail`, `order_overdue`, `quote_followup`, `partner_delay`, `cron_failure`, `ncr_opened`, `pricing_conflict`, `milestone_alert`, `daily_digest`

Valid channels: `email`, `slack`, `imessage`, `email+slack`, `none`

**Protected rule:** `compliance_block` and `cron_failure` cannot be set to `none`. If PM attempts this, warn:

> Compliance block alerts and cron failure alerts cannot be disabled. Choose a channel (email / slack / imessage / email+slack).

Write the setting and confirm: "Alert preference updated: {{ALERT_TYPE}} → {{CHANNEL}}."

## State File

`~/.reva-turbo/config/comms-preferences.yaml` — preferences file (read on every alert dispatch by reva-turbo-pulse, reva-turbo-reminder, reva-turbo-customer-comms).

## Rules

1. **Preferences are read at dispatch time.** Skills do not cache preferences — they read the YAML on every send.
2. **Quiet hours are respected.** reva-turbo-pulse checks quiet hours before dispatching non-urgent alerts. Urgent alerts (compliance_block, cron_failure, pricing_conflict) always bypass quiet hours.
3. **Customer preferences override PM defaults** for customer-facing communications.
4. **Alert preferences override customer preferences** for internal/system alerts.
5. **compliance_block and cron_failure cannot be set to `none`** — these alerts are always delivered.
6. **HITL is not required** for preference configuration — preferences are purely configuration data.

## Lifecycle

**Read by:** reva-turbo-pulse (all alert dispatches), reva-turbo-reminder (due reminder delivery), reva-turbo-customer-comms (customer email routing and CC logic)

**Written by:** PM via this skill, reva-turbo-setup (initial preference configuration during onboarding)
