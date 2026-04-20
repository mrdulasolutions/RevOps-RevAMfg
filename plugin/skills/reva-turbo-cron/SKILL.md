---
name: reva-turbo-cron
preamble-tier: 2
version: 2.0.0
description: |
  Scheduled recurring task engine for REVA-TURBO. Manages daily/weekly/monthly
  automated checks, alerts, and reports. Maintains a task registry in
  cron-schedule.json. Feeds reva-turbo-pulse (alerts), reva-turbo-report
  (weekly), reva-turbo-reminder (due reminders), and reva-turbo-partner-scorecard
  (weekly refresh).
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
mkdir -p ~/.reva-turbo/analytics ~/.reva-turbo/state
echo '{"skill":"reva-turbo-cron","ts":"'$(date -u +%Y-%m-%dT%H:%M:%SZ)'"}' >> ~/.reva-turbo/analytics/skill-usage.jsonl 2>/dev/null || true
```

## Purpose

Scheduled recurring task engine for REVA-TURBO. Manages daily, weekly, and monthly automated checks, alerts, and report generation. Each task is registered in `~/.reva-turbo/state/cron-schedule.json` with its schedule, enabled state, last run time, and last outcome. The cron engine is triggered by reva-turbo-autopilot or invoked directly by the PM via command.

## Task Registry

Eight built-in tasks are defined. All are stored in `~/.reva-turbo/state/cron-schedule.json`.

### Built-In Task Definitions

| Task ID | Schedule | Description | HITL Required |
|---------|----------|-------------|---------------|
| `daily-pipeline-check` | Daily 8:00 AM local | Read workflow-state.jsonl, find overdue items, fire pulse alerts for any stage past SLA | No — informational |
| `daily-reminder-sweep` | Daily 8:00 AM local | Read reminder-log.jsonl, fire any due reminders | No — informational |
| `weekly-partner-scorecard` | Monday 9:00 AM local | Run partner scorecard refresh for all active partners | No — informational |
| `weekly-report` | Friday 4:00 PM local | Generate weekly PM report via reva-turbo-report | **Yes — PM review before send** |
| `monthly-audit` | 1st of month 9:00 AM local | Run audit trail summary for prior month | No — informational |
| `quote-followup-check` | Daily 2:00 PM local | Scan for quotes sent >5 days ago with no response; fire reminder | **Yes — PM review before send** |
| `order-milestone-check` | Daily 9:00 AM local | Compare china-track milestones to expected dates; flag delays | No — informational |
| `duty-estimate-refresh` | Monday 9:00 AM local | Flag orders where Section 301 tariff changes may affect landed cost | No — informational |

### Cron Schedule JSON Schema

```json
{
  "tasks": [
    {
      "task_id": "daily-pipeline-check",
      "schedule": "0 8 * * *",
      "enabled": true,
      "last_run": null,
      "next_run": null,
      "last_outcome": null
    },
    {
      "task_id": "daily-reminder-sweep",
      "schedule": "0 8 * * *",
      "enabled": true,
      "last_run": null,
      "next_run": null,
      "last_outcome": null
    },
    {
      "task_id": "weekly-partner-scorecard",
      "schedule": "0 9 * * 1",
      "enabled": true,
      "last_run": null,
      "next_run": null,
      "last_outcome": null
    },
    {
      "task_id": "weekly-report",
      "schedule": "0 16 * * 5",
      "enabled": true,
      "last_run": null,
      "next_run": null,
      "last_outcome": null
    },
    {
      "task_id": "monthly-audit",
      "schedule": "0 9 1 * *",
      "enabled": true,
      "last_run": null,
      "next_run": null,
      "last_outcome": null
    },
    {
      "task_id": "quote-followup-check",
      "schedule": "0 14 * * *",
      "enabled": true,
      "last_run": null,
      "next_run": null,
      "last_outcome": null
    },
    {
      "task_id": "order-milestone-check",
      "schedule": "0 9 * * *",
      "enabled": true,
      "last_run": null,
      "next_run": null,
      "last_outcome": null
    },
    {
      "task_id": "duty-estimate-refresh",
      "schedule": "0 9 * * 1",
      "enabled": true,
      "last_run": null,
      "next_run": null,
      "last_outcome": null
    }
  ]
}
```

Initialize the schedule file if it does not exist:

```bash
_SCHED="$HOME/.reva-turbo/state/cron-schedule.json"
if [ ! -f "$_SCHED" ]; then
  cat > "$_SCHED" << 'SCHEDEOF'
{
  "tasks": [
    {"task_id":"daily-pipeline-check","schedule":"0 8 * * *","enabled":true,"last_run":null,"next_run":null,"last_outcome":null},
    {"task_id":"daily-reminder-sweep","schedule":"0 8 * * *","enabled":true,"last_run":null,"next_run":null,"last_outcome":null},
    {"task_id":"weekly-partner-scorecard","schedule":"0 9 * * 1","enabled":true,"last_run":null,"next_run":null,"last_outcome":null},
    {"task_id":"weekly-report","schedule":"0 16 * * 5","enabled":true,"last_run":null,"next_run":null,"last_outcome":null},
    {"task_id":"monthly-audit","schedule":"0 9 1 * *","enabled":true,"last_run":null,"next_run":null,"last_outcome":null},
    {"task_id":"quote-followup-check","schedule":"0 14 * * *","enabled":true,"last_run":null,"next_run":null,"last_outcome":null},
    {"task_id":"order-milestone-check","schedule":"0 9 * * *","enabled":true,"last_run":null,"next_run":null,"last_outcome":null},
    {"task_id":"duty-estimate-refresh","schedule":"0 9 * * 1","enabled":true,"last_run":null,"next_run":null,"last_outcome":null}
  ]
}
SCHEDEOF
  echo "Cron schedule initialized at $_SCHED"
fi
cat "$_SCHED"
```

## Flow

### Step 1 — Parse Command

Determine what action to take:

- `/reva-turbo:reva-turbo-cron list` → show all tasks (Step 2)
- `/reva-turbo:reva-turbo-cron run <task_id>` → manually trigger task (Step 3)
- `/reva-turbo:reva-turbo-cron enable <task_id>` → enable a task (Step 4)
- `/reva-turbo:reva-turbo-cron disable <task_id>` → disable a task (Step 4)
- `/reva-turbo:reva-turbo-cron status` → show engine health (Step 5)
- No argument or triggered by autopilot → evaluate due tasks and run them (Step 3)

### Step 2 — List Tasks

Display all tasks from cron-schedule.json in a readable table:

```bash
cat ~/.reva-turbo/state/cron-schedule.json 2>/dev/null || echo "No schedule found — run cron to initialize."
tail -20 ~/.reva-turbo/state/cron-log.jsonl 2>/dev/null || echo "No cron log yet."
```

Present to PM:

> **REVA-TURBO Cron Task Registry**
>
> | Task ID | Schedule | Enabled | Last Run | Next Run | Last Outcome |
> |---------|----------|---------|----------|----------|--------------|
> | daily-pipeline-check | 0 8 * * * (daily 8am) | ✓ | {{LAST_RUN}} | {{NEXT_RUN}} | {{OUTCOME}} |
> | daily-reminder-sweep | 0 8 * * * (daily 8am) | ✓ | ... | ... | ... |
> | weekly-partner-scorecard | 0 9 * * 1 (Mon 9am) | ✓ | ... | ... | ... |
> | weekly-report | 0 16 * * 5 (Fri 4pm) | ✓ | ... | ... | ... |
> | monthly-audit | 0 9 1 * * (1st of month) | ✓ | ... | ... | ... |
> | quote-followup-check | 0 14 * * * (daily 2pm) | ✓ | ... | ... | ... |
> | order-milestone-check | 0 9 * * * (daily 9am) | ✓ | ... | ... | ... |
> | duty-estimate-refresh | 0 9 * * 1 (Mon 9am) | ✓ | ... | ... | ... |

### Step 3 — Task Execution

**Before running any task:**

1. Load cron-schedule.json and find the task record.
2. Check `last_run` — if the task has already run within the current scheduled window (same day for daily, same week for weekly, same month for monthly), skip it with a log entry noting "already_run_this_window".
3. Check `enabled` — if `false`, skip with a log entry noting "disabled".

**Execution logic per task:**

#### `daily-pipeline-check`
```bash
# Read workflow state and identify overdue items
_STATE=$(cat ~/.reva-turbo/state/workflow-state.jsonl 2>/dev/null | tail -200)
_TODAY=$(date -u +%Y-%m-%d)
echo "Pipeline check: $_TODAY"
```
- Parse workflow-state.jsonl for all active orders.
- For each order, compare current stage against SLA thresholds (default: rfq-qualify ≤2 days, export-compliance ≤3 days, rfq-quote ≤3 days, china-package ≤2 days, china-track per partner lead time, import-compliance ≤2 days, logistics ≤1 day, order-track ≤1 day).
- For any stage past SLA, invoke reva-turbo-pulse to fire an overdue alert.
- **HITL:** Not required — informational alerts only.

#### `daily-reminder-sweep`
```bash
_REMINDERS=$(cat ~/.reva-turbo/state/reminder-log.jsonl 2>/dev/null | grep '"status":"pending"')
echo "Pending reminders: $(echo "$_REMINDERS" | wc -l | tr -d ' ')"
```
- Parse reminder-log.jsonl for all entries with `status: pending` and `due_date <= today`.
- For each due reminder, invoke reva-turbo-reminder to fire the reminder alert.
- **HITL:** Not required — reminder content was set by PM at creation time.

#### `weekly-partner-scorecard`
- Invoke reva-turbo-partner-scorecard in refresh mode for all active partners.
- Produces a scorecard summary; logs results to partner-history.jsonl.
- **HITL:** Not required — scorecard is informational.

#### `weekly-report`
- Invoke reva-turbo-report to generate the weekly PM summary.
- **HITL CHECKPOINT — REQUIRED:**

> **Weekly Report Ready for Review**
>
> The weekly PM report has been generated for the week ending {{FRIDAY_DATE}}.
> Review the draft before it is distributed.
>
> A) Approve and send
> B) Edit and then send
> C) Save as draft only — I'll send it manually

Do NOT send until PM confirms option A or B.

#### `monthly-audit`
- Invoke reva-turbo-audit-trail to generate a summary for the prior calendar month.
- Output saved to `~/.reva-turbo/state/audit-monthly-{{YYYY-MM}}.jsonl`.
- **HITL:** Not required — audit summary is informational.

#### `quote-followup-check`
```bash
_TODAY_EPOCH=$(date +%s)
_CUTOFF_EPOCH=$(( _TODAY_EPOCH - 432000 ))  # 5 days in seconds
cat ~/.reva-turbo/state/workflow-state.jsonl 2>/dev/null | grep '"stage":"rfq-quote"' | grep '"status":"sent"'
```
- Parse workflow-state.jsonl for quotes in `stage: rfq-quote` with `status: sent`.
- Calculate days since sent. If > 5 days and no acceptance logged, flag for follow-up.
- **HITL CHECKPOINT — REQUIRED:**

> **Quote Follow-Up Required**
>
> The following quotes have been pending > 5 days with no customer response:
>
> | Order | Customer | Quote Date | Days Pending |
> |-------|----------|------------|--------------|
> | {{ORDER_ID}} | {{CUSTOMER}} | {{QUOTE_DATE}} | {{DAYS}} |
>
> A) Draft follow-up email now (routes to reva-turbo-customer-comms)
> B) Mark as acknowledged — I'll follow up manually
> C) Close quote — customer passed

Do NOT send follow-up until PM confirms option A.

#### `order-milestone-check`
- Parse workflow-state.jsonl and china-track milestone records.
- Compare actual milestone dates against expected dates from the china-package record.
- For any milestone delayed >2 days, invoke reva-turbo-pulse with a delay alert.
- **HITL:** Not required — informational alerts only.

#### `duty-estimate-refresh`
- Parse all active orders in import-compliance stage or later.
- Cross-reference HTS codes with any recent Section 301 tariff list updates noted in `~/.reva-turbo/config/tariff-alerts.yaml`.
- For any order where duty rate may have changed, flag to PM via reva-turbo-pulse.
- **HITL:** Not required — informational flag only. PM reviews affected orders manually.

**After every task execution — success:**

```bash
_TS=$(date -u +%Y-%m-%dT%H:%M:%SZ)
echo '{"ts":"'"$_TS"'","task":"{{TASK_ID}}","status":"success","outcome":"{{OUTCOME_SUMMARY}}","pm":"autopilot"}' >> ~/.reva-turbo/state/cron-log.jsonl
```

Update `last_run` and `last_outcome` in cron-schedule.json.

**After every task execution — failure:**

```bash
_TS=$(date -u +%Y-%m-%dT%H:%M:%SZ)
echo '{"ts":"'"$_TS"'","task":"{{TASK_ID}}","status":"error","error":"{{ERROR_DETAIL}}","pm":"autopilot"}' >> ~/.reva-turbo/state/cron-log.jsonl
```

On failure:
- Log the error detail to cron-log.jsonl.
- Invoke reva-turbo-pulse to fire a cron-failure alert to the PM.
- Do NOT retry automatically — human review is required before next attempt.
- Update `last_outcome` to `"error: {{ERROR_DETAIL}}"` in cron-schedule.json.

### Step 4 — Enable / Disable Task

To enable a task:

```bash
# Read cron-schedule.json, update the target task's "enabled" field to true, write back
_TASK="{{TASK_ID}}"
python3 -c "
import json, sys
with open('$HOME/.reva-turbo/state/cron-schedule.json') as f:
    d = json.load(f)
for t in d['tasks']:
    if t['task_id'] == '$_TASK':
        t['enabled'] = True
with open('$HOME/.reva-turbo/state/cron-schedule.json', 'w') as f:
    json.dump(d, f, indent=2)
print('Task', '$_TASK', 'enabled.')
" 2>/dev/null || echo "Manual edit required: set enabled:true for $_TASK in ~/.reva-turbo/state/cron-schedule.json"
```

To disable: same logic but set `"enabled": false`.

Confirm to PM: "Task `{{TASK_ID}}` is now {{enabled/disabled}}."

### Step 5 — Engine Health Status

```bash
echo "=== REVA-TURBO Cron Status ==="
echo "Schedule file:"
ls -la ~/.reva-turbo/state/cron-schedule.json 2>/dev/null || echo "Not found — run cron to initialize"
echo ""
echo "Recent cron log (last 10):"
tail -10 ~/.reva-turbo/state/cron-log.jsonl 2>/dev/null || echo "No log entries yet"
echo ""
echo "Recent failures:"
grep '"status":"error"' ~/.reva-turbo/state/cron-log.jsonl 2>/dev/null | tail -5 || echo "None"
```

Present summary:

> **REVA-TURBO Cron Engine Health**
>
> Schedule file: {{EXISTS / MISSING}}
> Total tasks: 8
> Enabled tasks: {{N}}
> Last run: {{LAST_TASK}} at {{LAST_RUN_TS}}
> Recent failures: {{FAILURE_COUNT}} — {{FAILURE_TASKS}}
>
> All systems: {{OK / ATTENTION REQUIRED}}

## HITL Rules

| Task | HITL Required | Why |
|------|---------------|-----|
| daily-pipeline-check | No | Informational alert — no PM action taken automatically |
| daily-reminder-sweep | No | Reminder content was PM-approved at creation |
| weekly-partner-scorecard | No | Informational scorecard refresh |
| weekly-report | **Yes** | Customer-facing distribution — PM must review content |
| monthly-audit | No | Internal audit summary only |
| quote-followup-check | **Yes** | Customer communication — PM must approve message |
| order-milestone-check | No | Informational delay alerts only |
| duty-estimate-refresh | No | Informational tariff flag only |

## State Files

| File | Purpose |
|------|---------|
| `~/.reva-turbo/state/cron-schedule.json` | Task registry — schedule, enabled state, last/next run, last outcome |
| `~/.reva-turbo/state/cron-log.jsonl` | Execution log — one entry per task run (success or failure) |

## Lifecycle

**Triggered by:** reva-turbo-autopilot (on schedule) or PM via `/reva-turbo:reva-turbo-cron` command.

**Feeds:**
- reva-turbo-pulse — overdue alerts, milestone delays, cron failures, tariff flags
- reva-turbo-report — weekly report generation (weekly-report task)
- reva-turbo-reminder — due reminder firing (daily-reminder-sweep task)
- reva-turbo-partner-scorecard — weekly scorecard refresh (weekly-partner-scorecard task)
- reva-turbo-customer-comms — quote follow-up drafts (quote-followup-check task, HITL gated)
- reva-turbo-audit-trail — monthly audit summary (monthly-audit task)
