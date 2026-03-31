# REVA-TURBO Architecture

## Overview

REVA-TURBO is a Claude Code skills engine that automates the Product Manager workflow at Rev A Manufacturing. It follows a modular, event-driven architecture with 27 skills organized into 9 groups.

## Layer Model

```
┌─────────────────────────────────────────────────┐
│  Layer 4: Orchestrator                          │
│  reva-turbo-engine — intent routing, lifecycle      │
│  chaining, workflow state management            │
├─────────────────────────────────────────────────┤
│  Layer 3: Composition Skills                    │
│  reva-turbo-dashboard, reva-turbo-report,               │
│  reva-turbo-audit-trail — aggregate from atomics    │
├─────────────────────────────────────────────────┤
│  Layer 2: Content Skills (Atomic)               │
│  rfq-intake, rfq-qualify, rfq-quote,            │
│  customer-gate, china-package, inspect, ncr,    │
│  quality-gate, order-track, logistics, etc.     │
├─────────────────────────────────────────────────┤
│  Layer 1: Infrastructure                        │
│  Connectors (email, CRM, ERP), scheduling       │
│  (cron, reminder), utilities (docx, templates)  │
└─────────────────────────────────────────────────┘
```

## Skill Structure

Every skill follows the same directory pattern:

```
skill-name/
├── SKILL.md          # Frontmatter (YAML) + full instructions
├── skill.yaml        # Machine-readable manifest
├── README.md         # User-facing documentation
├── prompts/          # System prompts and user templates
├── references/       # Domain reference materials
├── templates/        # Report/document templates ({{PLACEHOLDER}})
├── scripts/          # Helper scripts (conversion, etc.)
└── bin/              # Hook scripts, utilities
```

## SKILL.md Frontmatter

```yaml
---
name: skill-name
version: 1.0.0
description: |
  What the skill does. When to use it.
compatibility: Claude Code, Claude desktop, Claude CoWork
allowed-tools:
  - Bash
  - Read
  - Write
  - AskUserQuestion
hooks:
  PreToolUse:
    - matcher: "Edit|Write"
      hooks:
        - type: command
          command: "bash ${CLAUDE_SKILL_DIR}/bin/hook-script.sh"
---
```

## Data Flow

```
Email/Website/CRM
       │
       ▼
reva-turbo-rfq-intake ──▶ reva-turbo-rfq-qualify ──▶ reva-turbo-rfq-quote
       │                      │                      │
       ▼                      ▼                      ▼
  CRM record           Gate decision            Quote .docx
                    (PROCEED/DECLINE)
       │
       ▼
reva-turbo-china-package ──▶ reva-turbo-china-track ──▶ reva-turbo-inspect
       │                      │                      │
       ▼                      ▼                      ▼
  Spec package         Progress report       Inspection report
  for China              (milestones)        (ACCEPT/REJECT)
       │
       ▼
reva-turbo-quality-gate ──▶ reva-turbo-repackage ──▶ reva-turbo-logistics
       │                      │                      │
       ▼                      ▼                      ▼
  Gate checklist         Work order          Shipping coord
  (PASS/FAIL)                                + tracking
```

## State Management

Runtime state persists at `~/.reva-turbo/`:

| File | Format | Purpose |
|------|--------|---------|
| `config.yaml` | YAML key-value | Persistent configuration |
| `sessions/<PID>` | Touch file | Active session tracking |
| `analytics/skill-usage.jsonl` | JSONL | Telemetry event log |
| `state/active-rfqs.jsonl` | JSONL | Active RFQ tracking |
| `state/active-orders.jsonl` | JSONL | Active order tracking |
| `state/workflow-state.jsonl` | JSONL | Workflow transition log |

## Hook System

PreToolUse hooks intercept tool invocations before execution:

- **check-workflow-state.sh** — validates workflow transitions (e.g., must qualify before quoting)
- **check-data-sensitivity.sh** — prevents writing customer data to unprotected locations

## Telemetry

Three tiers: `off` (default), `anonymous`, `community`.
Events logged to `~/.reva-turbo/analytics/skill-usage.jsonl` in JSONL format.
Managed by `bin/reva-turbo-telemetry-log`.

## Connectors

Connectors use MCP tools when available, with manual fallback:

| Connector | Primary | Fallback |
|-----------|---------|----------|
| Email | Hostinger/Gmail MCP | Manual paste |
| CRM | HubSpot MCP / Power Apps API | Manual entry |
| ERP | API (TBD) | Spreadsheet |

## Report Generation

1. Skill fills `{{PLACEHOLDER}}` template
2. Writes temp `.md` file
3. Runs `report-to-docx.mjs` converter
4. Renames to `REVA-TURBO-{Type}-{YYYY-MM-DD}-{ShortName}.docx`
5. Deletes temp `.md`
6. User receives `.docx` only
