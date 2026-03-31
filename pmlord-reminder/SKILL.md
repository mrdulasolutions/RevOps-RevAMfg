---
name: pmlord-reminder
preamble-tier: 2
version: 1.0.0
description: |
  PM reminder system for Rev A Manufacturing. Triggers time-based reminders:
  quote no-response (3 days), quote expiration (T-5), delivery approaching
  (T-7/3/1), inspection due, NCR corrective action due, post-delivery
  satisfaction check (T+3).
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
mkdir -p ~/.pmlord/analytics
echo '{"skill":"pmlord-reminder","ts":"'$(date -u +%Y-%m-%dT%H:%M:%SZ)'"}' >> ~/.pmlord/analytics/skill-usage.jsonl 2>/dev/null || true
```

## Purpose

Provide proactive, time-based reminders to PMs so nothing falls through the cracks. Each reminder type has a defined trigger window relative to a key date. The system scans active orders, RFQs, NCRs, and other state data to identify reminders that should fire today.

## Flow

### Step 1: Reminder Scan

When invoked (typically by pmlord-cron daily), scan all state files for reminders due today:

```bash
# Scan RFQ state for quote follow-ups
cat ~/.pmlord/state/workflow-state.jsonl 2>/dev/null | grep '"stage":"pmlord-rfq-quote"' | tail -50

# Scan order state for delivery dates
cat ~/.pmlord/state/workflow-state.jsonl 2>/dev/null | grep '"status":"active"' | tail -100

# Scan NCR state for corrective action deadlines
cat ~/.pmlord/state/ncr-log.jsonl 2>/dev/null | grep '"status":"open"' | tail -20

# Check existing reminders
cat ~/.pmlord/state/reminder-log.jsonl 2>/dev/null | tail -50
```

### Step 2: Evaluate Triggers

Reference `references/reminder-triggers.md` for all trigger definitions. For each active item, calculate:

1. Days since the trigger event (for look-back triggers like quote no-response)
2. Days until the target event (for look-ahead triggers like delivery approaching)
3. Whether a reminder has already been sent for this trigger window

### Step 3: Present Reminders

> **PMLORD Reminders for Today ({{TODAY}}):**
>
> {{REMINDER_COUNT}} reminders due:
>
> {{REMINDER_LIST}}
>
> A) Acknowledge all and take action
> B) Show details for a specific reminder
> C) Snooze a reminder (add 1 day)
> D) Dismiss a reminder (with reason)

### Step 4: Process Each Reminder

For each acknowledged reminder:
1. Present the specific action needed
2. Offer to invoke the relevant PMLORD skill (e.g., pmlord-customer-comms for follow-up)
3. Log the reminder as processed

```bash
echo '{"ts":"'$(date -u +%Y-%m-%dT%H:%M:%SZ)'","trigger":"{{TRIGGER_TYPE}}","ref":"{{REFERENCE_ID}}","customer":"{{CUSTOMER_COMPANY}}","action":"{{ACTION_TAKEN}}","pm":"{{PM_NAME}}","status":"{{STATUS}}"}' >> ~/.pmlord/state/reminder-log.jsonl
```

### Step 5: Snooze / Dismiss

If a reminder is snoozed:
```bash
echo '{"ts":"'$(date -u +%Y-%m-%dT%H:%M:%SZ)'","trigger":"{{TRIGGER_TYPE}}","ref":"{{REFERENCE_ID}}","action":"snoozed","snooze_until":"{{SNOOZE_DATE}}","pm":"{{PM_NAME}}"}' >> ~/.pmlord/state/reminder-log.jsonl
```

If dismissed:
```bash
echo '{"ts":"'$(date -u +%Y-%m-%dT%H:%M:%SZ)'","trigger":"{{TRIGGER_TYPE}}","ref":"{{REFERENCE_ID}}","action":"dismissed","reason":"{{DISMISS_REASON}}","pm":"{{PM_NAME}}"}' >> ~/.pmlord/state/reminder-log.jsonl
```

## Rules

1. **Do not spam.** Only fire each reminder once per trigger window. Check the reminder log before firing.
2. **PM confirmation.** Always present reminders for acknowledgment. Never auto-send communications.
3. **Priority ordering.** Show reminders in priority order: delivery T-1 before T-7, NCR deadlines before quote follow-ups.
4. **Snooze limit.** A reminder can be snoozed up to 3 times. After that, it requires dismissal with a documented reason.

## Template References

- `references/reminder-triggers.md` — Complete trigger definitions and timing
