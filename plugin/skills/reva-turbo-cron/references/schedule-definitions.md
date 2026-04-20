# Schedule Definitions

## Daily Tasks

### Daily Order Status Check
- **Task ID:** `daily-order-status`
- **Cadence:** Every business day
- **Time:** Morning (when PM starts REVA-TURBO)
- **Skill Triggered:** `reva-turbo-order-track`
- **Action:** Review all active orders, identify any that are overdue at their current stage, flag delays
- **Output:** Quick status summary with any red/yellow flags
- **Estimated Time:** 5-10 minutes

### Daily Reminder Processing
- **Task ID:** `daily-reminders`
- **Cadence:** Every business day
- **Time:** Morning
- **Skill Triggered:** `reva-turbo-reminder`
- **Action:** Check all active reminders and trigger any that are due today
- **Output:** List of reminders triggered and actions needed
- **Estimated Time:** 5 minutes

### Daily Escalation Check
- **Task ID:** `daily-escalation-check`
- **Cadence:** Every business day
- **Time:** Morning
- **Skill Triggered:** `reva-turbo-escalate`
- **Action:** Review open escalations, check response deadlines, flag overdue responses
- **Output:** Escalation status update
- **Estimated Time:** 3 minutes

## Weekly Tasks

### Monday: Partner Follow-Up
- **Task ID:** `weekly-partner-followup`
- **Cadence:** Every Monday
- **Skill Triggered:** `reva-turbo-partner-scorecard` (or `reva-turbo-customer-comms`)
- **Action:**
  1. Review all orders at manufacturing stages (04-05) — request status update from partners
  2. Review all orders at shipping stages (06) — check tracking status
  3. Follow up on any partner issues from prior week
- **Output:** List of follow-up emails/messages to send
- **Estimated Time:** 15-30 minutes

### Friday: Weekly PM Summary
- **Task ID:** `weekly-pm-summary`
- **Cadence:** Every Friday
- **Skill Triggered:** `reva-turbo-report`
- **Action:** Generate the Weekly PM Summary report covering Monday through Friday
- **Output:** Completed Weekly PM Summary report
- **Estimated Time:** 15-20 minutes

## Monthly Tasks

### Monthly Partner Scorecards
- **Task ID:** `monthly-partner-scorecards`
- **Cadence:** 1st business day of each month
- **Skill Triggered:** `reva-turbo-partner-scorecard`
- **Action:**
  1. Calculate updated scores for all active partners
  2. Generate individual partner scorecards
  3. Flag any partners with score changes (especially downgrades)
- **Output:** Updated partner scorecards
- **Estimated Time:** 20-30 minutes

### Monthly Performance Report
- **Task ID:** `monthly-performance-report`
- **Cadence:** 1st business day of each month
- **Skill Triggered:** `reva-turbo-report`
- **Action:** Generate the Monthly Performance Report for the prior month
- **Output:** Completed Monthly Performance report
- **Estimated Time:** 20-30 minutes

## Quarterly Tasks

### Quarterly Business Review
- **Task ID:** `quarterly-review`
- **Cadence:** 1st week of January, April, July, October
- **Skill Triggered:** `reva-turbo-report`
- **Action:** Generate the Quarterly Business Review for the prior quarter
- **Output:** Completed Quarterly Review report
- **Estimated Time:** 45-60 minutes

## Schedule Calendar

| Day | Tasks |
|-----|-------|
| Monday | Daily Order Status, Daily Reminders, Daily Escalation Check, Weekly Partner Follow-Up |
| Tuesday | Daily Order Status, Daily Reminders, Daily Escalation Check |
| Wednesday | Daily Order Status, Daily Reminders, Daily Escalation Check |
| Thursday | Daily Order Status, Daily Reminders, Daily Escalation Check |
| Friday | Daily Order Status, Daily Reminders, Daily Escalation Check, Weekly PM Summary |
| 1st Business Day | + Monthly Partner Scorecards, Monthly Performance Report |
| 1st Week of Quarter | + Quarterly Business Review |

## Execution Rules

1. **Skip weekends and holidays.** If a task is due on a non-business day, run on the next business day.
2. **Once per period.** Each task runs once per its cadence period. Do not run twice.
3. **Dependencies.** Monthly reports depend on monthly scorecards — run scorecards first.
4. **Catch-up.** If the PM missed a day, offer to run missed daily tasks. For weekly/monthly, always catch up.
5. **Log format:**
   ```json
   {"ts":"2026-03-30T14:00:00Z","task":"daily-order-status","skill":"reva-turbo-order-track","status":"completed","pm":"Ray Yeh"}
   ```
