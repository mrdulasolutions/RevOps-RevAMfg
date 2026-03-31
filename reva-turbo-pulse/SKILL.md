---
name: reva-turbo-pulse
preamble-tier: 1
version: 1.0.0
description: |
  Real-time alert feed and PM nervous system. Push notifications via Slack,
  iMessage, email when exceptions occur. Smart filtering surfaces only
  action-required items. Daily digest and weekly pulse reports keep PMs
  ahead of problems instead of reacting to them.
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
echo '{"skill":"reva-turbo-pulse","ts":"'$(date -u +%Y-%m-%dT%H:%M:%SZ)'"}' >> ~/.reva-turbo/analytics/skill-usage.jsonl 2>/dev/null || true
```

## Purpose

Pulse is the PM's nervous system. It continuously monitors REVA-TURBO's state files for exception conditions and delivers targeted alerts through the PM's preferred channels. Unlike a dashboard that requires the PM to look, Pulse pushes information to the PM when they need to act.

Smart filtering ensures Pulse is not noisy. Routine milestones go to the daily digest. Warnings batch into the next check-in window. Critical alerts push immediately via Slack and iMessage. The PM trusts Pulse because it only speaks up when something matters.

## Flow

### Step 1 — Channel Setup

Configure alert delivery channels. Ask the PM:

> **Pulse Alert Channel Setup**
>
> Where should critical alerts go? (Select all that apply)
>
> A) Slack (requires Slack MCP connection)
> B) iMessage (requires iMessage MCP connection)
> C) Email — Hostinger (requires Hostinger email MCP)
> D) Email — Gmail (requires Gmail MCP)
> E) In-system only (alerts stored in REVA-TURBO, visible on next interaction)
>
> Which is your primary channel? (The one you check most reliably)

Save configuration:

```bash
mkdir -p ~/.reva-turbo/state
echo '{"ts":"'$(date -u +%Y-%m-%dT%H:%M:%SZ)'","pm":"{{PM_NAME}}","channels":{"slack":{{SLACK_ENABLED}},"imessage":{{IMESSAGE_ENABLED}},"hostinger_email":{{HOSTINGER_ENABLED}},"gmail":{{GMAIL_ENABLED}},"in_system":true},"primary_channel":"{{PRIMARY_CHANNEL}}","slack_channel":"{{SLACK_CHANNEL_ID}}","pm_phone":"{{PM_PHONE}}","pm_email":"{{PM_EMAIL}}"}' >> ~/.reva-turbo/state/pulse-config.jsonl 2>/dev/null || true
```

Reference: `references/channel-config.md` for channel-specific MCP tool details.

### Step 2 — Alert Rule Configuration

Configure which alerts the PM wants and at what priority. Present the alert catalog from `references/alert-definitions.md`:

> **Alert Configuration**
>
> I have 14 alert types configured. The defaults are:
>
> **CRITICAL (immediate push):**
> - Delay detected (milestone >3 days overdue)
> - NCR issued
> - Payment overdue (>30 days)
> - Escalation triggered
> - Customer complaint received
> - Quality gate failed
>
> **WARNING (next check-in):**
> - Quote expiring (<3 days)
> - Quote no response (>5 business days)
> - Partner score dropped below C
> - Capacity warning (>15 active orders)
>
> **INFO (daily digest only):**
> - Delivery approaching (<3 days)
> - Inspection due today
> - New RFQ received
> - Order milestone completed
>
> Want to customize any of these? Or accept the defaults?
>
> A) Accept defaults
> B) Customize priorities
> C) Add custom alert rules

If B, walk through each alert type and let the PM adjust priority level.

Save alert configuration:

```bash
echo '{"ts":"'$(date -u +%Y-%m-%dT%H:%M:%SZ)'","pm":"{{PM_NAME}}","alert_config":"{{ALERT_CONFIG_JSON}}"}' >> ~/.reva-turbo/state/pulse-alert-config.jsonl 2>/dev/null || true
```

### Step 3 — Alert Detection Scan

Scan REVA-TURBO state files for alert-triggering conditions:

**Data sources to scan:**

| Source | File | What to look for |
|--------|------|-----------------|
| Workflow state | `~/.reva-turbo/state/workflow-state.jsonl` | Stale stages (no progress >3 days) |
| Active orders | `~/.reva-turbo/state/active-orders.jsonl` | Overdue milestones, approaching deadlines |
| Active RFQs | `~/.reva-turbo/state/active-rfqs.jsonl` | Expiring quotes, no-response RFQs |
| NCR log | `~/.reva-turbo/state/ncr-log.jsonl` | New NCRs, unresolved NCRs |
| Partner scorecards | `~/.reva-turbo/state/partner-scores.jsonl` | Score drops, low scores |
| Inspection schedule | `~/.reva-turbo/state/inspection-schedule.jsonl` | Upcoming inspections |
| Invoice tracker | `~/.reva-turbo/state/invoices.jsonl` | Overdue payments |
| Escalation log | `~/.reva-turbo/state/escalations.jsonl` | Active escalations |
| Skill usage | `~/.reva-turbo/analytics/skill-usage.jsonl` | PM workload (count active entities) |

For each data source, evaluate against the alert definitions in `references/alert-definitions.md`. When an alert condition is met, create an alert record:

```bash
echo '{"ts":"'$(date -u +%Y-%m-%dT%H:%M:%SZ)'","alert_id":"PULSE-{{ALERT_SEQ}}","alert_type":"{{ALERT_TYPE}}","priority":"{{PRIORITY}}","entity_id":"{{ENTITY_ID}}","entity_type":"{{ENTITY_TYPE}}","message":"{{ALERT_MESSAGE}}","pm":"{{PM_NAME}}","status":"pending","channels_targeted":["{{CHANNELS}}"],"action_required":"{{ACTION_DESCRIPTION}}"}' >> ~/.reva-turbo/state/pulse-alerts.jsonl 2>/dev/null || true
```

### Step 4 — Smart Filtering

Before delivering alerts, apply filtering rules from `references/filtering-rules.md`:

1. **Deduplication** — If the same alert type for the same entity was fired in the last 24 hours and is still unresolved, suppress the duplicate. Increment a `repeat_count` on the original alert instead.

2. **Grouping** — If multiple alerts fire for related entities (same customer, same partner, same order), group them into a single notification:
   > "3 alerts for Partner XYZ: delay on Order A, delay on Order B, score dropped to C"

3. **Off-hours suppression** — If the PM has configured quiet hours (e.g., 10pm-7am local time), hold WARNING and INFO alerts until the next active window. CRITICAL alerts still push immediately.

4. **Snooze check** — If the PM has snoozed an alert, check if the snooze has expired. If not, suppress. If expired, re-alert.

5. **Escalation on unacknowledged** — If a CRITICAL alert goes unacknowledged for >2 hours, escalate: re-send via all configured channels. If still unacknowledged after 4 hours, flag for backup PM routing.

### Step 5 — Alert Routing and Delivery

Route filtered alerts to the correct channels based on priority and PM configuration:

**CRITICAL alerts:**
1. Send via Slack: `mcp__3dc7fb47__slack_send_message` to the configured channel
2. Send via iMessage: `mcp__Read_and_Send_iMessages__send_imessage` to PM's phone
3. Log delivery confirmation

**WARNING alerts:**
1. Queue for next check-in window
2. If PM interacts with REVA-TURBO before check-in: present warnings at start of session
3. If no interaction by check-in time: send via email

**INFO alerts:**
1. Store for daily digest
2. Do not push individually

Reference: `references/channel-config.md` for MCP tool invocation details.

### Step 6 — Alert Actions

When presenting an alert to the PM, provide clear action options:

> **ALERT: {{ALERT_TYPE}}** [{{PRIORITY}}]
>
> {{ALERT_MESSAGE}}
>
> **Entity:** {{ENTITY_ID}} ({{ENTITY_TYPE}})
> **Detected:** {{ALERT_TIMESTAMP}}
>
> Actions:
> A) Acknowledge — I see it, will handle it
> B) Snooze — Remind me in: 1 hour / 4 hours / 1 day
> C) Escalate — Route to senior PM / management
> D) Act now — Take me to the relevant skill ({{RELEVANT_SKILL}})

Log the PM's response:

```bash
echo '{"ts":"'$(date -u +%Y-%m-%dT%H:%M:%SZ)'","alert_id":"{{ALERT_ID}}","action":"{{PM_ACTION}}","pm":"{{PM_NAME}}","snooze_until":"{{SNOOZE_UNTIL}}"}' >> ~/.reva-turbo/state/pulse-actions.jsonl 2>/dev/null || true
```

### Step 7 — Daily Digest

Generate a morning digest every day (or on first PM interaction of the day). Use the template from `templates/Daily Digest.md`:

**Digest includes:**
- Overnight alerts (any CRITICAL alerts that fired while PM was offline)
- Pending items requiring action (unacknowledged alerts, snoozed alerts expiring today)
- Today's deadlines (quotes expiring, deliveries expected, inspections due)
- Active order summary (count by stage, any at-risk orders)
- Yesterday's completions (orders that advanced, quotes sent, deliveries confirmed)

Present at the start of the PM's first interaction:

> **Good morning. Here is your daily pulse.**
>
> {{DAILY_DIGEST_CONTENT}}
>
> Want to drill into any of these? Or proceed with today's priorities?

Log digest delivery:

```bash
echo '{"ts":"'$(date -u +%Y-%m-%dT%H:%M:%SZ)'","digest_type":"daily","pm":"{{PM_NAME}}","alerts_included":{{ALERT_COUNT}},"pending_actions":{{PENDING_COUNT}},"deadlines_today":{{DEADLINE_COUNT}}}' >> ~/.reva-turbo/state/pulse-digests.jsonl 2>/dev/null || true
```

### Step 8 — Weekly Pulse

Generate a weekly summary every Monday morning (or on demand). Use the template from `templates/Weekly Pulse.md`:

**Weekly pulse includes:**
- Total alerts fired this week by priority level
- Alert resolution times (average time from alert to PM action)
- Pattern detection: recurring alerts, persistent issues, improving/worsening trends
- PM workload trend (active orders over the week)
- Top alert sources (which entities/partners/customers generated the most alerts)
- Recommendations: "Partner ABC triggered 4 delay alerts this week. Consider reviewing their scorecard."

> **Weekly Pulse Report — Week of {{WEEK_START_DATE}}**
>
> {{WEEKLY_PULSE_CONTENT}}
>
> Key insight: {{TOP_INSIGHT}}
>
> Want a deeper dive on any area?

```bash
echo '{"ts":"'$(date -u +%Y-%m-%dT%H:%M:%SZ)'","digest_type":"weekly","pm":"{{PM_NAME}}","week_start":"{{WEEK_START_DATE}}","total_alerts":{{TOTAL_ALERTS}},"critical":{{CRITICAL_COUNT}},"warning":{{WARNING_COUNT}},"info":{{INFO_COUNT}},"avg_resolution_minutes":{{AVG_RESOLUTION}}}' >> ~/.reva-turbo/state/pulse-digests.jsonl 2>/dev/null || true
```

## Template References

- `prompts/pulse-system.md` — Alert generation rules and priority classification
- `references/alert-definitions.md` — Complete alert catalog
- `references/channel-config.md` — Channel configuration and MCP tools
- `references/filtering-rules.md` — Deduplication, grouping, snooze, off-hours
- `templates/Daily Digest.md` — Morning digest template
- `templates/Weekly Pulse.md` — Weekly summary template
- `bin/pulse-check.sh` — Alert detection scan script
