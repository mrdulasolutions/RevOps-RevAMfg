---
name: pmlord-cron
preamble-tier: 2
version: 1.0.0
description: |
  Scheduled task management for the PMLORD engine. Defines and manages
  recurring tasks: daily order status checks, weekly partner follow-ups (Monday),
  weekly PM summary (Friday), monthly scorecards, and quarterly reviews.
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
echo '{"skill":"pmlord-cron","ts":"'$(date -u +%Y-%m-%dT%H:%M:%SZ)'"}' >> ~/.pmlord/analytics/skill-usage.jsonl 2>/dev/null || true
```

## Purpose

Manage scheduled and recurring tasks for the PMLORD engine. Define what needs to run, when it runs, and track execution history. This skill acts as the scheduler that triggers other PMLORD skills on a defined cadence.

## Flow

### Step 1: Scheduler Action

> What scheduler action do you need?
> A) Run today's scheduled tasks
> B) View the full schedule
> C) Check what ran recently
> D) Run a specific scheduled task manually
> E) View upcoming tasks for the next 7 days

### Step 2: Schedule Evaluation

Reference `references/schedule-definitions.md` for all scheduled tasks. Evaluate what should run based on the current date and day of week:

```bash
# Check current date and day
date -u +"%Y-%m-%d %A"

# Check last run times
cat ~/.pmlord/state/cron-log.jsonl 2>/dev/null | tail -20
```

### Step 3: Task Execution

For each scheduled task that is due:

1. Verify it has not already run today (check cron-log.jsonl)
2. Present the task to the PM for confirmation
3. Invoke the appropriate PMLORD skill
4. Log the execution

**HUMAN-IN-THE-LOOP CHECKPOINT:**

> **Scheduled Tasks for Today ({{TODAY}}):**
>
> {{TASK_LIST}}
>
> A) Run all due tasks
> B) Select specific tasks to run
> C) Skip all — I will run them later
> D) Show me what each task does

### Step 4: Log Execution

After each task runs:

```bash
echo '{"ts":"'$(date -u +%Y-%m-%dT%H:%M:%SZ)'","task":"{{TASK_ID}}","skill":"{{TRIGGERED_SKILL}}","status":"{{STATUS}}","pm":"{{PM_NAME}}"}' >> ~/.pmlord/state/cron-log.jsonl
```

### Step 5: Missed Task Detection

Check for tasks that should have run but were missed:

```bash
# Compare schedule against cron-log to find gaps
cat ~/.pmlord/state/cron-log.jsonl 2>/dev/null | grep "$(date -u +%Y-%m)" | tail -50
```

If missed tasks are detected:

> **Missed Tasks Detected:**
> {{MISSED_TASK_LIST}}
>
> A) Run missed tasks now
> B) Skip — acknowledge and move on
> C) Show me details

## Schedule Summary

| Task | Cadence | Day | Skill Triggered |
|------|---------|-----|----------------|
| Daily Order Status Check | Daily | Every day | pmlord-order-track |
| Weekly Partner Follow-Up | Weekly | Monday | pmlord-partner-scorecard |
| Weekly PM Summary | Weekly | Friday | pmlord-report |
| Monthly Partner Scorecards | Monthly | 1st business day | pmlord-partner-scorecard |
| Monthly Performance Report | Monthly | 1st business day | pmlord-report |
| Quarterly Business Review | Quarterly | 1st week of Q | pmlord-report |

## Report Naming

N/A — this skill triggers other skills that produce their own outputs.

## Template References

- `prompts/scheduling-system.md` — System prompt for scheduling logic
- `references/schedule-definitions.md` — Complete schedule definitions
