# Pulse Filtering Rules

Smart filtering ensures Pulse is useful, not noisy. These rules run after alert detection and before delivery.

## 1. Deduplication

**Rule:** If the same alert type for the same entity was fired within the last 24 hours and is still unresolved (not acknowledged, not resolved), suppress the new alert and increment the `repeat_count` on the original.

**Exception:** If the alert severity has changed (e.g., delay grew from 3 days to 7 days), fire a new alert with updated details and reference the original alert_id.

**Implementation:**
1. Before creating a new alert, query `pulse-alerts.jsonl` for:
   - Same `alert_type`
   - Same `entity_id`
   - `ts` within the last 24 hours
   - `status` is "pending" or "acknowledged" (not "resolved")
2. If found: update the existing alert's `repeat_count` and `ts`. Do not create a new alert.
3. If not found or severity changed: create a new alert.

**Dedup window by priority:**
| Priority | Dedup Window |
|----------|-------------|
| CRITICAL | 4 hours (re-alert sooner since these are urgent) |
| WARNING | 24 hours |
| INFO | 24 hours |

## 2. Alert Grouping

**Rule:** When multiple alerts fire simultaneously for related entities, group them into a single notification to reduce noise.

**Grouping dimensions:**
| Dimension | Example | Grouped Message |
|-----------|---------|----------------|
| Same partner | 3 delays from Partner ABC | "Partner ABC: 3 orders delayed (ORD-001, ORD-002, ORD-003). Avg delay: 4 days." |
| Same customer | 2 quotes expiring for Acme Corp | "Acme Corp: 2 quotes expiring in <3 days (RFQ-010, RFQ-011)." |
| Same alert type | 4 inspections due today | "4 inspections due today: ORD-005, ORD-008, ORD-012, ORD-015." |
| Same order | NCR + delay on same order | "Order ORD-020: NCR issued AND 5 days overdue. Needs immediate attention." |

**Grouping logic:**
1. After all alerts are generated for a scan cycle, group by partner, then by customer, then by alert type.
2. If a group has 2+ alerts, merge into a single grouped notification.
3. The grouped notification uses the highest priority from any member alert.
4. Individual alert records are still created in the JSONL log (grouping is for delivery only).

## 3. Snooze Behavior

**Rule:** When a PM snoozes an alert, suppress it until the snooze period expires.

**Snooze options:**
| Option | Duration | Use case |
|--------|----------|----------|
| 1 hour | 60 minutes | "I know about this, will handle it shortly" |
| 4 hours | 240 minutes | "Will deal with it this afternoon" |
| 1 day | 24 hours | "Not urgent today, remind me tomorrow" |
| Until resolved | Indefinite | "I have a plan, stop reminding me" (CRITICAL alerts cannot be snoozed indefinitely) |

**Snooze rules:**
- CRITICAL alerts can be snoozed for max 4 hours. After that, they re-fire.
- WARNING alerts can be snoozed for max 1 day. After that, they re-fire.
- INFO alerts can be snoozed indefinitely or until the next digest.
- When a snoozed alert re-fires, it includes a note: "This alert was snoozed at {{SNOOZE_TIME}} and has re-fired."
- If the underlying condition has resolved during the snooze period, the alert is auto-resolved instead of re-firing.

**Implementation:**
1. When PM snoozes: set `snoozed_until` on the alert record.
2. On each scan: check snoozed alerts. If `snoozed_until` is past, re-evaluate the condition.
3. If condition still exists: re-fire with incremented repeat_count.
4. If condition resolved: set `status: "resolved"` and `resolved_at` timestamp.

## 4. Off-Hours Suppression

**Rule:** During configured quiet hours, hold non-critical alerts until the next active window.

**Default quiet hours:** 10:00 PM to 7:00 AM local time (configurable by PM).

**Behavior by priority during quiet hours:**
| Priority | Quiet Hours Behavior |
|----------|---------------------|
| CRITICAL | Deliver immediately (quiet hours do not apply) |
| WARNING | Hold until 7:00 AM, then deliver with morning digest |
| INFO | Hold until 7:00 AM, include in daily digest |

**Configuration:**
```json
{
  "quiet_hours_enabled": true,
  "quiet_start": "22:00",
  "quiet_end": "07:00",
  "timezone": "America/Chicago",
  "weekend_all_quiet": false,
  "weekend_critical_only": true
}
```

**Weekend behavior (configurable):**
- `weekend_all_quiet: true` — All alerts held until Monday (except CRITICAL)
- `weekend_critical_only: true` — Only CRITICAL alerts push on weekends. WARNING and INFO held for Monday.
- Both false: weekends treated like weekdays

## 5. Escalation on Unacknowledged Alerts

**Rule:** CRITICAL alerts that go unacknowledged trigger escalation.

**Escalation timeline:**
| Elapsed Time | Action |
|-------------|--------|
| 0 min | Alert fires via configured channels |
| 30 min | If not acknowledged: re-send via ALL configured channels (not just primary) |
| 2 hours | If still not acknowledged: flag alert as "UNACK_ESCALATION" and attempt backup PM routing |
| 4 hours | If still not acknowledged: generate an escalation record via reva-turbo-escalate |

**Backup PM routing:**
- If a backup PM is configured in `pulse-config.jsonl`, route the alert to them at the 2-hour mark.
- If no backup PM configured, include a note in the escalation: "No backup PM configured. Consider setting one up via /reva-turbo-pulse configure."

**Implementation:**
1. Track `first_fired` timestamp on each CRITICAL alert.
2. On each scan, check all pending CRITICAL alerts against the escalation timeline.
3. Execute the appropriate escalation action based on elapsed time.
4. Log all escalation actions in `pulse-alerts.jsonl` with an `escalation_level` field.

## 6. Rate Limiting

**Rule:** Prevent alert storms from overwhelming the PM.

**Limits:**
| Channel | Max alerts per hour | Max alerts per day |
|---------|--------------------|--------------------|
| Slack | 20 | 100 |
| iMessage | 5 | 20 |
| Email | 10 | 50 |
| In-system | Unlimited | Unlimited |

**When rate limit is hit:**
1. Switch to grouped delivery: batch remaining alerts into a single message.
2. If grouping still exceeds the limit: hold and deliver as a special digest within 1 hour.
3. Log the rate limit event: the PM should know they are getting batched alerts because the system is seeing a lot of exceptions.

> "Rate limit reached: 22 alerts fired in the last hour. Delivering as a batched summary. This volume may indicate a systemic issue — consider reviewing your dashboard."
