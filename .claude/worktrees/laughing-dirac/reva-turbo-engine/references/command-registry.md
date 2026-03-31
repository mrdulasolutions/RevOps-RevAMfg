# REVA-TURBO Command Registry

In-engine utility commands handled by the orchestrator's command router. These are lightweight actions — not full skills. They execute inline and return immediately.

Commands are distinguished from intents by the `/` prefix and are routed BEFORE intent routing.

---

## Command Reference

### Pipeline & Status

| Command | Type | Description | Implementation |
|---------|------|-------------|----------------|
| `/status` | inline | Pipeline summary — active RFQs, orders in progress, pending gates, overdue items | Read `~/.reva-turbo/state/workflow-state.jsonl`, aggregate by stage, format table |
| `/pipeline` | delegated | Full pipeline dashboard with stage counts and flow visualization | Route to `reva-turbo-dashboard` with `mode:pipeline` |
| `/customers` | inline | Active customer table — name, open RFQs, open orders, last activity | Read state files, aggregate by customer, format table |
| `/partners` | inline | Manufacturing partner table — name, country, capabilities, rating, active orders | Read `~/.reva-turbo/partners.yaml`, format table |

### Navigation & Context

| Command | Type | Description | Implementation |
|---------|------|-------------|----------------|
| `/switch <entity>` | inline | Switch working context to a customer, RFQ, or order | Write `~/.reva-turbo/state/current-context.json`, push previous to `context-history.jsonl` |
| `/back` | inline | Return to previous context | Pop from `~/.reva-turbo/state/context-history.jsonl`, write to `current-context.json` |
| `/search <term>` | inline | Search across all state files for a term | Grep `~/.reva-turbo/state/*.jsonl` and config files, format matches |

### Configuration

| Command | Type | Description | Implementation |
|---------|------|-------------|----------------|
| `/config` | config | Show all config values | Read via `reva-turbo-config` |
| `/config set <key> <val>` | config | Set a config value | Write via `reva-turbo-config set <key> <val>` |
| `/setup` | delegated | Run or re-run the onboarding wizard | Route to `reva-turbo-setup` |
| `/backup` | config | Trigger backup of state and config | Copy `~/.reva-turbo/` to backup destination per `document-config.yaml` |

### Identity & Personalization

| Command | Type | Description | Implementation |
|---------|------|-------------|----------------|
| `/whoami` | inline | Show PM profile, trust level, voice settings, active context | Read config, trust-level.json, voice-profile.yaml, current-context.json |
| `/trust` | delegated | Manage trust level (set, assess, history, override) | Route to `reva-turbo-trust` |
| `/voice` | delegated | Manage voice profile (create, edit, view, learn) | Route to `reva-turbo-voice` |

### Reporting & Audit

| Command | Type | Description | Implementation |
|---------|------|-------------|----------------|
| `/export` | delegated | Export report in configured format | Route to `reva-turbo-report` with `mode:export` |
| `/audit` | delegated | Show decision audit trail summary | Route to `reva-turbo-audit-trail` with `mode:summary` |
| `/alerts` | delegated | Review recent alerts and notifications | Route to `reva-turbo-pulse` with `mode:review` |
| `/rules` | delegated | List active business rules | Route to `reva-turbo-rules` with `mode:list` |

### Utility

| Command | Type | Description | Implementation |
|---------|------|-------------|----------------|
| `/help` | inline | List all commands and skills | Read `conductor.json`, format commands table + skills table |
| `/shortcuts` | inline | Quick-reference card of common commands | Display condensed command list with examples |
| `/save` | inline | Force session state snapshot | Write current session state to `~/.reva-turbo/sessions/` |

---

## Command Types

| Type | Behavior |
|------|----------|
| **inline** | Executed directly by the orchestrator. No skill invocation. Fast, returns immediately. |
| **delegated** | Routes to a full skill with an optional mode parameter. The skill handles the interaction. |
| **config** | Reads or writes engine configuration via `reva-turbo-config`. |

---

## Routing Rules

1. If user input starts with `/`, check this registry FIRST — before intent routing
2. If the command exists → execute it (inline) or route to skill (delegated)
3. If the command does NOT exist → fall through to intent routing (maybe they meant a skill)
4. Commands are case-insensitive: `/Status` = `/status`
5. Commands can include arguments: `/switch Acme Corp`, `/config set trust_level 2`, `/search PN-4820`

---

## Context Stack

The `/switch` and `/back` commands maintain a context stack:

**current-context.json:**
```json
{
  "type": "customer",
  "id": "acme-corp",
  "name": "Acme Corporation",
  "switched_at": "2026-03-30T14:00:00Z",
  "active_rfqs": ["RFQ-2026-0142"],
  "active_orders": ["PO-2026-0089"]
}
```

**context-history.jsonl:** (append-only, most recent first)
```json
{"type":"customer","id":"globex-inc","name":"Globex Inc","switched_at":"2026-03-30T13:00:00Z","switched_from":"2026-03-30T14:00:00Z"}
```

When context is active, all commands and skills scope to that context by default. For example, `/status` shows only the active customer's pipeline.

---

## `/whoami` Output Format

```
╔══════════════════════════════════════╗
║  REVA-TURBO — PM Profile                ║
╠══════════════════════════════════════╣
║  PM:          Sarah Chen             ║
║  Trust Level: 2 — ASSIST (Walk)      ║
║  Voice:       Professional, concise  ║
║  Context:     Acme Corp (3 active)   ║
║  Session:     2h 14m                 ║
║  Engine:      v1.2.0                 ║
╚══════════════════════════════════════╝
```

---

## `/status` Output Format

```
📊 REVA-TURBO Pipeline Status — 2026-03-30

Stage                    | Count | Oldest    | Overdue
─────────────────────────┼───────┼───────────┼────────
RFQ Intake               │   2   │ Mar 28    │   0
Qualification            │   1   │ Mar 27    │   0
Quoting                  │   3   │ Mar 25    │   1 ⚠️
Awaiting Customer        │   2   │ Mar 20    │   1 ⚠️
Export Compliance        │   0   │ —         │   0
China Manufacturing      │   4   │ Mar 10    │   0
Import Compliance        │   1   │ Mar 28    │   0
Inspection               │   2   │ Mar 29    │   0
Quality Gate             │   1   │ Mar 29    │   0
Repackaging              │   1   │ Mar 30    │   0
Shipping                 │   0   │ —         │   0
─────────────────────────┴───────┴───────────┴────────
Total active: 17 orders | 2 overdue | 4 due this week
```

---

## `/help` Output Format

```
REVA-TURBO v1.2.0 — Rev A Manufacturing PM Engine

COMMANDS (type / to use):
  /status     Pipeline summary          /search     Search all state
  /pipeline   Full dashboard            /switch     Change context
  /partners   Partner table             /back       Previous context
  /customers  Customer table            /whoami     Your profile
  /help       This screen               /shortcuts  Quick reference
  /config     View/set config           /setup      Onboarding wizard
  /trust      Trust level manager       /voice      Voice profile
  /export     Export report             /audit      Audit trail
  /alerts     Review alerts             /rules      Business rules
  /backup     Backup state              /save       Save session

SKILLS (type name or describe what you need):
  /reva-turbo-rfq-intake      New RFQ processing
  /reva-turbo-rfq-qualify      Qualification gates
  /reva-turbo-rfq-quote       Generate quote
  ... (full list from conductor.json)

Type any command or describe what you need — I'll route to the right skill.
```
