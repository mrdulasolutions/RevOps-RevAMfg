# Trust System -- Core Behavioral Philosophy

## What Trust Is

Trust is a **behavioral overlay**, not a permission system. It modifies:

- **Verbosity**: How much the engine explains
- **Autonomy**: How much the engine does without asking
- **Confirmation frequency**: How often the PM must approve actions
- **Output format**: Teaching prose vs. confidence-scored drafts vs. terse results

Trust does NOT modify:

- **Capability**: All skills are available at all levels
- **Data access**: The engine reads the same data regardless of level
- **Safety gates**: Hard gates always pause, sensitive data is always flagged
- **Accuracy**: The engine applies the same logic at every level

## The 3 Levels

| Level | Name | Metaphor | Key Behavior |
|---|---|---|---|
| 1 | LEARN | Crawl | Explain everything, PM decides everything |
| 2 | ASSIST | Walk | Draft and pre-fill, PM reviews and approves |
| 3 | OPERATE | Run | Handle routine autonomously, PM audits exceptions |

## Behavioral Principles

### 1. Trust Is Earned, Not Gatekept

The PM can set any trust level at any time. The engine may suggest promotions based on usage patterns, but it never forces a level or refuses to change. Trust exists to serve the PM's preferences, not to protect the engine.

### 2. Safety Overrides Trust

Regardless of trust level, the engine ALWAYS:

- Pauses at hard quality gates (final inspection sign-off)
- Flags sensitive data before writing to any location
- Requires human review for export/import compliance decisions
- Requires human review for financial approvals above configurable threshold
- Warns on anomalies (unusual order values, new customers, spec deviations)

These safety behaviors cannot be overridden by trust level. They are separate from trust.

### 3. Specificity Wins

The override chain resolves the effective trust level:

```
entity > skill > user > system
```

- **Entity override**: "Level 1 for customer Acme Corp" -- applies when working with Acme Corp across all skills
- **Skill override**: "Level 1 for export-compliance" -- applies when running export compliance for any customer
- **User override**: "Level 2 for PM Jane" -- applies to all skills for Jane unless a more specific override exists
- **System default**: The base trust level when no overrides apply

When evaluating, start from the most specific and work outward. First match wins.

### 4. Trust + Autopilot Are Independent

Trust controls the **communication style** between engine and PM.
Autopilot controls the **workflow progression** between skills.

They are orthogonal:

| | Manual Autopilot | Semi-Auto | Full Auto |
|---|---|---|---|
| **Level 1 LEARN** | Explain step, wait for approval, explain next step | Explain what auto-fired, offer to cancel | Explain what auto-fired (for learning), proceed |
| **Level 2 ASSIST** | Draft output, wait for review | Draft output, auto-proceed after brief notification | Draft output, auto-proceed silently |
| **Level 3 OPERATE** | Execute, show result, wait | Execute, auto-proceed, notify | Execute, auto-proceed, log only |

### 5. Graceful Degradation

If trust level cannot be determined (state file missing, corrupted, etc.), default to **Level 1 LEARN**. Never default to a higher trust level on error. The safe default is always the most conservative.

### 6. Transparency in Autonomous Actions

At Level 3 OPERATE, the engine acts autonomously for routine tasks. Every autonomous action is:

- Logged to the audit trail (`~/.pmlord/analytics/trust-audit.jsonl`)
- Included in periodic audit summaries (daily or weekly, configurable)
- Reversible where possible (drafts saved before sending, state snapshots before transitions)

The PM can always ask "what did you do while I was away?" and get a complete accounting.

## Trust Level Resolution Algorithm

When a skill starts, it resolves the effective trust level:

```
1. Read the context: which skill, which entity (customer/partner/order), which user
2. Check entity overrides: does this entity have a trust override?
   -> If yes and not expired, use it
3. Check skill overrides: does this skill have a trust override?
   -> If yes and not expired, use it
4. Check user overrides: does this PM have a personal trust level?
   -> If yes, use it
5. Read system default: ~/.pmlord/state/trust-level.json
   -> If exists, use it
6. Default: Level 1 LEARN
```

Then apply safety caps:
```
7. Check if the resolved skill has a safety cap
   -> export-compliance: cap at Level 2
   -> quality-gate (final): cap at Level 2
   -> financial approvals above threshold: cap at Level 2
8. If resolved level > safety cap, downgrade to cap
```

## Behavioral Overlay Application

Once the effective trust level is resolved, the skill reads the corresponding behavioral prompt:

- Level 1: `prompts/trust-learn.md`
- Level 2: `prompts/trust-assist.md`
- Level 3: `prompts/trust-operate.md`

These prompts define the communication style, confirmation patterns, and output format that the skill should follow. They are overlays -- they modify the skill's behavior but do not replace its core logic.

## State File Schemas

### trust-level.json (system or per-user)
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

### trust-overrides.jsonl (append-only)
```json
{"ts":"2026-03-15T14:30:00Z","type":"skill","skill":"pmlord-export-compliance","entity_type":null,"entity_id":null,"level":1,"reason":"safety-critical","expires":null,"set_by":"jane-doe","active":true}
{"ts":"2026-03-16T09:00:00Z","type":"entity","skill":null,"entity_type":"customer","entity_id":"acme-corp","level":1,"reason":"new customer","expires":"2026-04-16T09:00:00Z","set_by":"jane-doe","active":true}
```

### trust-history.jsonl (append-only audit log)
```json
{"ts":"2026-03-15T14:30:00Z","action":"set","level":2,"name":"assist","scope":"system","reason":"trust-assessment","set_by":"jane-doe"}
{"ts":"2026-03-15T14:35:00Z","action":"override","level":1,"name":"learn","scope":"skill:pmlord-export-compliance","reason":"safety-critical","set_by":"jane-doe"}
```
