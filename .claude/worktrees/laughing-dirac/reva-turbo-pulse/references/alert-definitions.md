# Pulse Alert Definitions

Complete catalog of alert types, triggers, priorities, channels, and recommended actions.

## Alert Catalog

### CRITICAL Alerts

| ID | Alert | Trigger Condition | Default Priority | Channels | Recommended Action |
|----|-------|-------------------|-----------------|----------|-------------------|
| ALT-001 | DELAY_DETECTED | Any milestone is >3 calendar days past its expected completion date | CRITICAL | Slack + iMessage | Review the order in order-track. Contact the manufacturing partner. Update the customer if delivery date is affected. |
| ALT-002 | NCR_ISSUED | A new non-conformance report has been created (by inspect skill or manually) | CRITICAL | Slack | Review the NCR details. Determine disposition: rework, scrap, return to vendor, use-as-is, or customer concession. |
| ALT-003 | PAYMENT_OVERDUE | An invoice is >30 calendar days past its due date with no payment recorded | CRITICAL | Slack + Email | Escalate to Senior PM or finance. Contact customer's AP department. Consider hold on future orders. |
| ALT-004 | ESCALATION_TRIGGERED | Any escalation event logged by reva-turbo-escalate or auto-detected | CRITICAL | Slack + iMessage | Immediate PM attention. Review escalation details and determine response within 1 hour. |
| ALT-005 | CUSTOMER_COMPLAINT | A customer complaint is logged (via email, CRM, or manual entry) | CRITICAL | Slack + iMessage | Acknowledge to customer within 4 hours. Investigate root cause. Log in CRM. |
| ALT-006 | QUALITY_GATE_FAIL | A quality gate check (G1-G4) returned FAIL result | CRITICAL | Slack | Review inspection data. Create NCR if not already created. Determine root cause and corrective action. |

### WARNING Alerts

| ID | Alert | Trigger Condition | Default Priority | Channels | Recommended Action |
|----|-------|-------------------|-----------------|----------|-------------------|
| ALT-007 | QUOTE_EXPIRING | A sent quote has an expiration date within 3 calendar days and customer has not responded | WARNING | Email | Send a follow-up to the customer. Consider extending the quote if pricing is still valid. |
| ALT-008 | QUOTE_NO_RESPONSE | A sent quote has had no customer response for >5 business days | WARNING | Email | Send a follow-up inquiry. If no response after second follow-up, consider closing the RFQ. |
| ALT-009 | PARTNER_SCORE_DROP | A manufacturing partner's scorecard grade dropped below C (to D or F) | WARNING | Slack | Review the partner scorecard. Identify what caused the drop. Consider sourcing alternatives for upcoming orders. |
| ALT-010 | CAPACITY_WARNING | A PM has >15 active orders simultaneously | WARNING | Slack | Review workload distribution. Consider redistributing orders or escalating to management for resource support. |

### INFO Alerts

| ID | Alert | Trigger Condition | Default Priority | Channels | Recommended Action |
|----|-------|-------------------|-----------------|----------|-------------------|
| ALT-011 | DELIVERY_APPROACHING | A shipment is expected to arrive at the customer or Rev A within 3 calendar days | INFO | Email | Confirm logistics are ready. Verify receiving dock availability. Prepare inspection team if incoming to Rev A. |
| ALT-012 | INSPECTION_DUE | Goods are expected to arrive at Rev A today for incoming inspection | INFO | Slack | Prepare inspection area. Pull inspection criteria from the order. Ensure measuring equipment is calibrated. |
| ALT-013 | NEW_RFQ_RECEIVED | A new RFQ has been detected in email or entered via CRM | INFO | Slack | Process through reva-turbo-rfq-intake when ready. No urgency unless customer flagged it as rush. |
| ALT-014 | ORDER_MILESTONE | A routine milestone has been completed (no exception, on schedule) | INFO | Daily digest only | No action needed. Logged for awareness and weekly reporting. |

## Alert Data Schema

Each alert record in `~/.reva-turbo/state/pulse-alerts.jsonl` follows this schema:

```json
{
  "ts": "2026-03-30T14:22:00Z",
  "alert_id": "PULSE-00142",
  "alert_type": "DELAY_DETECTED",
  "alert_code": "ALT-001",
  "priority": "CRITICAL",
  "entity_id": "ORD-2026-0087",
  "entity_type": "order",
  "customer": "Acme Industrial",
  "partner": "Shenzhen Precision Mfg",
  "message": "Order ORD-2026-0087 milestone M6 (tooling complete) is 5 days overdue. Expected: 2026-03-25. Partner: Shenzhen Precision Mfg.",
  "pm": "Sarah",
  "status": "pending",
  "channels_targeted": ["slack", "imessage"],
  "channels_delivered": [],
  "action_required": "Contact partner for status update. Review impact on delivery date.",
  "relevant_skill": "reva-turbo-china-track",
  "repeat_count": 1,
  "first_fired": "2026-03-28T08:00:00Z",
  "snoozed_until": null,
  "acknowledged_at": null,
  "resolved_at": null
}
```

## Priority Promotion Rules

| Condition | Original Priority | Promoted To | Rationale |
|-----------|------------------|-------------|-----------|
| Unresolved >48 hours | WARNING | CRITICAL | Inaction on a warning means it needs escalation |
| Same INFO fires 3 consecutive days | INFO | WARNING | Persistent info signals require attention |
| Entity flagged as "rush" | Any | One level up | Rush orders deserve heightened monitoring |
| Customer is top-10 by revenue | WARNING | CRITICAL | High-value relationships get priority treatment |
| Partner score is D or F | INFO (milestone) | WARNING | Low-performing partners need closer monitoring |

## Custom Alert Rules

PMs can define custom alert rules beyond the standard catalog:

```json
{
  "custom_alert_name": "MATERIAL_CERT_MISSING",
  "trigger": "Order has shipped from partner but material certification document is not in the order folder",
  "priority": "WARNING",
  "channels": ["slack"],
  "action": "Request material cert from partner before goods clear receiving"
}
```

Custom rules are stored in `~/.reva-turbo/state/pulse-custom-rules.jsonl`.
