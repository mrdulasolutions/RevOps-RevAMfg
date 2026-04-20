# Trust Override System

Overrides allow fine-grained control of trust levels beyond the system-wide default. They enable a PM to run at Level 3 for routine skills while staying at Level 1 for complex or safety-critical ones.

## Override Types

### 1. System-Wide Default

The base trust level for all skills and entities when no override applies.

**Location:** `~/.reva-turbo/state/trust-level.json`

```json
{
  "level": 2,
  "name": "assist",
  "set_by": "jane-doe",
  "set_at": "2026-03-15T14:30:00Z",
  "previous_level": 1,
  "reason": "trust-assessment"
}
```

### 2. Per-User Override

Individual PM trust levels for multi-user environments.

**Location:** `~/.reva-turbo/users/<pm-slug>/trust-level.json`

Same schema as system-wide. The `<pm-slug>` is a URL-safe version of the PM's name (e.g., `jane-doe`, `donovan-weber`).

```json
{
  "level": 3,
  "name": "operate",
  "set_by": "donovan-weber",
  "set_at": "2026-03-20T09:00:00Z",
  "previous_level": 2,
  "reason": "experienced PM, prefers autonomous operation"
}
```

### 3. Per-Skill Override

Override trust level for a specific skill, regardless of who is using it.

**Location:** `~/.reva-turbo/state/trust-overrides.jsonl` (append-only)

```json
{
  "ts": "2026-03-15T14:35:00Z",
  "type": "skill",
  "skill": "reva-turbo-export-compliance",
  "entity_type": null,
  "entity_id": null,
  "level": 1,
  "reason": "safety-critical, always want full visibility",
  "expires": null,
  "set_by": "jane-doe",
  "active": true
}
```

Common per-skill overrides:

| Skill | Typical Override | Reason |
|---|---|---|
| `reva-turbo-export-compliance` | Level 1 | Safety-critical, want to understand every decision |
| `reva-turbo-import-compliance` | Level 1 | Complex regulations, want full context |
| `reva-turbo-rfq-intake` | Level 3 | High volume, routine process |
| `reva-turbo-customer-comms` | Level 2 | Want to review communications but not draft from scratch |
| `reva-turbo-china-track` | Level 3 | Routine tracking, auto-update customers |
| `reva-turbo-report` | Level 3 | Auto-generate standard reports |

### 4. Per-Entity Override

Override trust level when working with a specific customer, partner, or order.

**Location:** `~/.reva-turbo/state/trust-overrides.jsonl` (append-only)

```json
{
  "ts": "2026-03-16T09:00:00Z",
  "type": "entity",
  "skill": null,
  "entity_type": "customer",
  "entity_id": "acme-corp",
  "level": 1,
  "reason": "new customer, need to learn their requirements",
  "expires": "2026-04-16T09:00:00Z",
  "set_by": "jane-doe",
  "active": true
}
```

Supported entity types:

| Entity Type | Entity ID Format | Example |
|---|---|---|
| `customer` | Slug of customer name | `acme-corp`, `newtech-industries` |
| `partner` | Slug of partner name | `shenzhen-mfg`, `dongguan-precision` |
| `order` | Order ID | `PO-2026-0031` |
| `rfq` | RFQ ID | `RFQ-2026-0047` |
| `part` | Part number | `XYZ-789` |

## Specificity Chain

When resolving the effective trust level, the engine checks from most specific to least specific:

```
1. Entity override (customer/partner/order/rfq/part)
2. Skill override (per-skill trust level)
3. User override (per-PM trust level)
4. System default (global trust level)
5. Hard default: Level 1 LEARN (if nothing is set)
```

**First match wins.** If a per-entity override exists for the current customer AND a per-skill override exists for the current skill, the entity override takes precedence.

### Resolution Example

System default: Level 3 OPERATE
Skill override: `reva-turbo-export-compliance` -> Level 1 LEARN
Entity override: customer `acme-corp` -> Level 2 ASSIST

| Scenario | Effective Level | Why |
|---|---|---|
| RFQ intake for Boeing | Level 3 | System default, no overrides match |
| Export compliance for Boeing | Level 1 | Skill override matches |
| RFQ intake for Acme Corp | Level 2 | Entity override matches |
| Export compliance for Acme Corp | Level 2 | Entity override (most specific) beats skill override |

## Override Expiry

Overrides can have an optional expiry date (TTL):

```json
{
  "expires": "2026-04-16T09:00:00Z"
}
```

- `null` = permanent override (until manually removed)
- ISO 8601 datetime = override expires at this time
- When expired, the override is ignored (next specificity level applies)
- Expired overrides are not deleted -- they remain in the JSONL log for audit purposes but are marked inactive

Common TTL patterns:

| Scenario | Suggested TTL |
|---|---|
| New customer learning period | 30 days |
| New partner evaluation | 60 days |
| Temporary caution after an error | 14 days |
| One-time complex order | Until order completion |
| Permanent safety override | No expiry |

## Managing Overrides

### Viewing Active Overrides

```bash
# Show all active, non-expired overrides
grep '"active":true' ~/.reva-turbo/state/trust-overrides.jsonl 2>/dev/null | while read line; do
  expires=$(echo "$line" | jq -r '.expires // "never"')
  if [ "$expires" = "never" ] || [ "$expires" = "null" ] || [ "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \< "$expires" ]; then
    echo "$line"
  fi
done
```

### Deactivating an Override

To deactivate an override, append a new entry with `"active": false`:

```json
{
  "ts": "2026-04-01T10:00:00Z",
  "type": "skill",
  "skill": "reva-turbo-export-compliance",
  "entity_type": null,
  "entity_id": null,
  "level": 1,
  "reason": "removing override, comfortable at system level now",
  "expires": null,
  "set_by": "jane-doe",
  "active": false
}
```

The resolution algorithm reads the JSONL file and uses the LAST entry for each unique (type, skill, entity_type, entity_id) combination.

### Listing Override History

The full JSONL log preserves all override changes for audit:

```bash
cat ~/.reva-turbo/state/trust-overrides.jsonl | jq -s 'sort_by(.ts)'
```

## Built-In Safety Overrides

These safety caps are hard-coded and cannot be changed by any trust setting. They exist because certain decisions require human judgment regardless of experience level.

| Skill / Category | Maximum Trust Level | Reason |
|---|---|---|
| `reva-turbo-export-compliance` | Level 2 ASSIST | Export compliance decisions have legal consequences. AI classification and license determination must always be reviewed by a human. |
| `reva-turbo-import-compliance` | Level 2 ASSIST | Import classification and formal customs entries require human review for legal compliance. |
| `reva-turbo-quality-gate` (final inspection) | Level 2 ASSIST | Final inspection sign-off determines whether product ships to customer. Must have human review. |
| `reva-turbo-inspect` (lot acceptance) | Level 2 ASSIST | Lot acceptance/rejection decisions affect customer satisfaction and have financial impact. |
| Financial approvals above threshold | Level 2 ASSIST | PO approvals, change orders, and price commitments above the configured threshold (default $50,000) require PM review. |
| Escalation to Donovan Weber | Level 2 ASSIST | Final escalation to the owner always requires explicit PM confirmation. |

If a PM attempts to set Level 3 for a safety-capped skill, the engine:

1. Warns: "This skill has a safety cap at Level 2 due to [reason]."
2. Sets the level to 2 instead of 3
3. Logs the attempt and the cap enforcement
4. Does NOT prevent the PM from setting Level 2 (which is the maximum allowed)

### Safety Override Log

When a safety cap is enforced:

```json
{
  "ts": "2026-03-30T14:00:00Z",
  "action": "safety_cap_enforced",
  "requested_level": 3,
  "enforced_level": 2,
  "skill": "reva-turbo-export-compliance",
  "reason": "export compliance safety cap",
  "set_by": "jane-doe"
}
```

## Override Interaction with Autopilot

Overrides affect trust behavior only, not autopilot transitions. A skill at Level 1 with Full Auto autopilot will:

- Explain what is happening (Level 1 behavior)
- Auto-transition to the next stage (Full Auto behavior)
- Show what the auto-transition did (Level 1 behavior)

A skill at Level 3 with Manual autopilot will:

- Execute silently (Level 3 behavior)
- Wait for PM to trigger the next stage (Manual behavior)
- Report the result tersely (Level 3 behavior)
