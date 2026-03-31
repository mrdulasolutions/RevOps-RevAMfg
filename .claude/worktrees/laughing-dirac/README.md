# REVA-TURBO

**The PM Workflow Engine for Rev A Manufacturing**

REVA-TURBO is an AI-powered skills engine that runs inside Claude Code. It digitizes the entire Product Manager lifecycle at Rev A Manufacturing — from the moment an RFQ hits the inbox to the day the customer signs for delivery. 41 skills. 20 in-engine commands. Zero tribal knowledge.

Built on the Claude Code skills architecture. Powered by Anthropic Claude. Designed for contract manufacturing.

---

## What It Does

Rev A Manufacturing receives RFQs via email, website, and CRM. PMs qualify them, generate quotes, send specs to manufacturing partners in China, track production, receive goods for inspection, repackage, and ship to customers. Every step involves decisions, emails, documents, and handoffs that used to live in spreadsheets, inboxes, and people's heads.

REVA-TURBO replaces all of that with a structured, auditable, AI-assisted workflow.

```
RFQ arrives
  -> Parse & intake (extract specs, quantities, materials, tolerances)
  -> Qualify (capability match, capacity check, credit readiness)
  -> New customer? -> Customer gate (onboarding, CRM, NDA, credit terms)
  -> EXPORT COMPLIANCE (EAR/ITAR/sanctions screening — hard gate)
  -> Quote (cost estimation, margin calculation, lead time)
  -> Customer accepts
  -> Package specs for China partner (metric conversion, drawing prep, IP protection)
  -> Track manufacturing (10 milestones, delay detection)
  -> [Goods shipped from China]
  -> IMPORT COMPLIANCE (HTS classification, duty calculation — hard gate)
  -> Receive & inspect (dimensional, material, finish verification)
  -> Quality gate (G1-G4 stage gates: PASS / CONDITIONAL / FAIL)
  -> Repackage (relabel, kit, customer-spec packaging)
  -> Ship to customer (routing, customs, tracking)
  -> Close order (audit trail, profitability analysis, partner scorecard)
```

> Export compliance is screened **before** quoting — you must confirm you can legally export before investing time in pricing.

Every decision is logged. Every communication is drafted. Every report is generated as `.docx`. Every escalation follows the matrix. No step is skipped.

---

## Skills (41)

### RFQ Pipeline

| Skill | Command | What It Does |
|-------|---------|-------------|
| **RFQ Intake** | `/reva-turbo-rfq-intake` | Parse incoming RFQs from email, website, or CRM. Extract customer, part specs, quantities, material, finish, tolerances, timeline. Create structured RFQ record. |
| **RFQ Qualify** | `/reva-turbo-rfq-qualify` | Gate checks: new vs returning customer, capability match (machining/molding/sheet metal), complexity score (1-5), capacity check, credit readiness. Decision: PROCEED / CONDITIONAL / DECLINE. |
| **RFQ Quote** | `/reva-turbo-rfq-quote` | Cost estimation across material, labor, tooling, finishing, assembly, overhead, and margin. Lead time calculation. Tooling amortization. Output: customer-facing quote `.docx`. |

### Customer Management

| Skill | Command | What It Does |
|-------|---------|-------------|
| **Customer Gate** | `/reva-turbo-customer-gate` | New customer onboarding: company verification, CRM setup, PM assignment (by region and load), initial credit terms, NDA tracking. |
| **Customer Profile** | `/reva-turbo-customer-profile` | Build and maintain customer profiles: order history, preferences, quality requirements, payment terms, communication preferences. |
| **Customer Comms** | `/reva-turbo-customer-comms` | Draft emails in Rev A voice: RFQ acknowledgment, quote submission, order confirmation, status update, shipment notification. 5 templates. |

### Manufacturing Partner

| Skill | Command | What It Does |
|-------|---------|-------------|
| **China Package** | `/reva-turbo-china-package` | Standardize specs for China partners: metric conversion, drawing requirements, translation notes, IP protection measures, material equivalency mapping. |
| **China Track** | `/reva-turbo-china-track` | 10-milestone tracking: specs confirmed, tooling started, tooling complete, first article, first article approved, production started, production complete, QC, packed, shipped. Delay detection and quality checkpoint scheduling. |
| **Partner Scorecard** | `/reva-turbo-partner-scorecard` | Evaluate partners on quality, delivery, cost, and communication. Weighted scoring. Letter grade (A-F) with trend analysis. |

### Quality

| Skill | Command | What It Does |
|-------|---------|-------------|
| **Inspect** | `/reva-turbo-inspect` | Incoming inspection: spec-based checklist, dimensional checks, material verification, finish inspection, documentation review. Disposition: ACCEPT / REJECT / HOLD. |
| **NCR** | `/reva-turbo-ncr` | Non-conformance reports: document defect, 5-Why root cause analysis, fishbone diagram, disposition (rework/scrap/use-as-is/RTV), CAPA corrective action plan. |
| **Quality Gate** | `/reva-turbo-quality-gate` | 4 stage gates: G1 (incoming), G2 (in-process), G3 (final), G4 (pre-ship). Each gate has specific criteria. Decision: PASS / CONDITIONAL PASS / FAIL. |

### Order & Logistics

| Skill | Command | What It Does |
|-------|---------|-------------|
| **Order Track** | `/reva-turbo-order-track` | 12-stage lifecycle: PO received, acknowledged, specs to China, manufacturing, shipped from China, received at Rev A, inspected, repackaged, shipped to customer, delivered, invoiced, closed. |
| **Logistics** | `/reva-turbo-logistics` | Shipping coordination: air/sea/ground routing, customs documentation, broker coordination, insurance requirements, tracking. Direct-to-customer vs inspect-and-forward routing logic. |
| **Repackage** | `/reva-turbo-repackage` | Receiving, inspection verification, repackaging to customer spec, labeling, kitting, outbound shipping preparation. Work order generation. |

### Reporting & Analytics

| Skill | Command | What It Does |
|-------|---------|-------------|
| **Dashboard** | `/reva-turbo-dashboard` | PM workload dashboard: open RFQs, active orders, quality issues, upcoming deliveries, partner performance, capacity utilization. |
| **Report** | `/reva-turbo-report` | Periodic reports: weekly PM summary, monthly performance, quarterly leadership review, customer-specific reports. All output as `.docx`. |
| **Audit Trail** | `/reva-turbo-audit-trail` | Append-only decision log: gate decisions, approvals, quality dispositions, escalations, overrides. Immutable audit record. |

### System

| Skill | Command | What It Does |
|-------|---------|-------------|
| **Engine** | `/revmyengine` | Master orchestrator: intent routing, lifecycle chaining, workflow state management. The brain of REVA-TURBO. |
| **Escalate** | `/reva-turbo-escalate` | Escalation workflow with 3-level matrix. Auto-detects escalation triggers (quality, delay, customer complaint). Routes to Senior PM then Donovan Weber. |
| **DOCX** | `/reva-turbo-docx` | Markdown-to-Word converter. Handles `{{PLACEHOLDER}}` template filling. Consistent Rev A branding. |
| **Templates** | `/reva-turbo-templates` | Central template inventory: quotes, reports, emails, inspection forms, NCRs. Version tracking and management. |
| **Cron** | `/reva-turbo-cron` | Scheduled recurring tasks: daily order checks, weekly partner follow-ups, monthly scorecards, quarterly reviews. |
| **Reminder** | `/reva-turbo-reminder` | Business-rule reminders: quote no-response (3 days), quote expiration (T-5), delivery approaching (T-7/3/1), post-delivery satisfaction (T+3). |

### Connectors

| Skill | Command | What It Does |
|-------|---------|-------------|
| **Email** | `/reva-turbo-email-connector` | Universal email connector. Native Claude M365 (primary, read-only, Team/Enterprise plan), Hostinger MCP (send/receive), Gmail MCP (drafts), Generic Inbox MCP (Microsoft send/reply/forward). Auto-detects providers, classifies inbound emails, routes to skills. |
| **CRM** | `/reva-turbo-crm-connector` | CRM integration for Microsoft Power Apps (Dataverse), Dynamics 365, and HubSpot. Adapter pattern supports all three. Field mapping: RFQ->Opportunity, Customer->Account, Order->Sales Order. |
| **ERP** | `/reva-turbo-erp-connector` | ERP/inventory integration for capacity and cost data. Flexible adapter — Rev A's ERP tooling is evolving. |

### Compliance

| Skill | Command | What It Does |
|-------|---------|-------------|
| **Export Compliance** | `/reva-turbo-export-compliance` | EAR/ITAR/sanctions screening via ExChek engine (exchek.us). Auto-detects installation, offers Enterprise or installs free Community engine from GitHub. Hard gate before sending technical data to China or shipping internationally. |
| **Import Compliance** | `/reva-turbo-import-compliance` | HTS classification, duty calculation (MFN + Section 301 + AD/CVD), customs documentation via TradeInsights.ai API. Hard gate before customs entry on inbound China shipments. |

### Magic Layer

| Skill | Command | What It Does |
|-------|---------|-------------|
| **Autopilot** | `/reva-turbo-autopilot` | Invisible workflow auto-advancement. Three modes: FULL AUTO (hands-free lifecycle transitions), SEMI AUTO (advance with confirmation), MANUAL (explicit only). 21-transition rule matrix. |
| **Pulse** | `/reva-turbo-pulse` | Real-time alert feed via Slack, iMessage, and email. 14 alert types across CRITICAL/WARNING/INFO. Daily digest. Weekly pulse report. Dedup, snooze, off-hours suppression. |
| **Intel** | `/reva-turbo-intel` | Predictive analytics engine: lead time forecasting, risk scoring, trend analysis. 22 KPIs across sales, delivery, quality, financial, operational. 7 analysis methods. 20 pre-built insight patterns. |
| **Quick** | `/reva-turbo-quick` | One-shot natural language actions: "quote Acme 500 units aluminum bracket" -> pre-fills and routes to the right skill. 23 quick actions. NLP intent detection with confidence scoring. |
| **Sync** | `/reva-turbo-sync` | Bidirectional auto-sync with CRM and email. 9-stage outbound sync mapping. Inbound email matching (sender, reference number, content classification). Conflict resolution with system-of-record rules. |
| **Change Order** | `/reva-turbo-change-order` | Mid-stream change management: 6-dimension impact analysis (cost, time, tooling, quality, partner, logistics). Cascading updates to 8 downstream skills. Change fee policy. Revision control. |
| **Profit** | `/reva-turbo-profit` | Actual vs estimated cost tracking across 12 cost categories. Variance analysis with 4-tier flag system. Customer lifetime profitability. Margin alerts. Improvement lever identification. |
| **Handoff** | `/reva-turbo-handoff` | Multi-PM collaboration: vacation handoff (with auto-revert), permanent transfer, shared ownership, approval routing, workload balancing. Briefing and return-briefing generation. |
| **Rules** | `/reva-turbo-rules` | YAML-based business rules engine: 7 rule types (pricing, approval, alert, routing, quality, workflow, customer). 31 pre-built rules. Conflict resolution. Rule chaining (3-level limit). Override logging. |

### Personalization

| Skill | Command | What It Does |
|-------|---------|-------------|
| **Setup** | `/reva-turbo-setup` | Interactive 7-section onboarding wizard: company profile, workflow configuration, connectors (CRM/email/ERP/Slack), manufacturing partners, shipping & logistics, document formatting, CoWork space. Creates 6 YAML config files. Supports skip, resume, per-section reconfiguration. |
| **Trust** | `/reva-turbo-trust` | Progressive autonomy system with 3 trust levels: Level 1 LEARN (crawl — explain everything, PM decides all), Level 2 ASSIST (walk — pre-fill and draft, PM reviews), Level 3 OPERATE (run — handle routine autonomously, PM audits exceptions). Per-user, per-skill, and per-entity overrides. |
| **Voice** | `/reva-turbo-voice` | Per-user voice and personality tuner. 3-phase onboarding: sample analysis (paste emails), structured interview (15+ dimensions), preference capture. Customizes ALL engine output: tone, greeting style, email length, technical depth, formality, banned phrases. Continuous learning from PM edits. |

### In-Engine Commands (20)

REVA-TURBO includes 20 slash commands for quick actions without invoking full skills:

| Command | What It Does |
|---------|-------------|
| `/status` | Pipeline summary — active RFQs, orders, gates, overdue items |
| `/help` | List all commands and skills |
| `/whoami` | PM profile, trust level, voice settings, active context |
| `/partners` | Manufacturing partner table |
| `/customers` | Active customer table |
| `/search <term>` | Search across all state files |
| `/switch <entity>` | Switch working context to customer/RFQ/order |
| `/back` | Return to previous context |
| `/pipeline` | Full pipeline dashboard |
| `/config` | View/set engine configuration |
| `/setup` | Run onboarding wizard |
| `/trust` | Manage trust level |
| `/voice` | Manage voice profile |
| `/export` | Export report |
| `/audit` | Decision audit trail |
| `/alerts` | Review notifications |
| `/rules` | List business rules |
| `/backup` | Backup state and config |
| `/save` | Force session snapshot |
| `/shortcuts` | Command quick-reference |

---

## Architecture

REVA-TURBO follows a 4-layer architecture:

```
Layer 4: Orchestrator
  revmyengine — intent routing, lifecycle chaining, workflow state

Layer 3: Composition Skills
  dashboard, report, audit-trail, intel, profit — aggregate from atomics

Layer 2: Content Skills (Atomic)
  rfq-intake, rfq-qualify, customer-gate, export-compliance, rfq-quote,
  china-package, import-compliance, inspect, ncr, quality-gate,
  order-track, logistics, change-order, etc.

Layer 1: Infrastructure
  Connectors (email, CRM, ERP), scheduling (cron, reminder),
  utilities (docx, templates), magic (autopilot, pulse, sync, rules, etc.)
```

### Skill Structure

Every skill follows the same directory pattern:

```
skill-name/
  SKILL.md          # YAML frontmatter + full instructions
  skill.yaml        # Machine-readable manifest
  README.md         # User-facing documentation
  prompts/          # System prompts and user templates
  references/       # Domain reference materials
  templates/        # Report/document templates ({{PLACEHOLDER}})
  bin/              # Hook scripts, utilities
```

### Data Flow

```
Email / Website / CRM
       |
       v
rfq-intake --> rfq-qualify --+--> EXPORT COMPLIANCE (EAR/ITAR/sanctions — hard gate)
                    |        |              |
                    v        |              v
              customer-gate -+        rfq-quote --> Quote .docx
              (new customers)               |
                                            v
                                    customer-comms
                                            |
                                            v
                              china-package --> china-track --> [goods shipped]
                                                                    |
                                                                    v
                                                          IMPORT COMPLIANCE (HTS/duties — hard gate)
                                                                    |
                                                                    v
                                                           inspect --> quality-gate
                                                                    |
                                                                    v (if reject)
                                                                   ncr
                                                                    |
                                                                    v
                                              repackage --> logistics --> order-track (close)
```

> **Key:** Export compliance screening happens BEFORE quoting — you must know if you can legally export before investing time in pricing.

### State Management

Runtime state persists at `~/.reva-turbo/`:

| Path | Format | Purpose |
|------|--------|---------|
| `config.yaml` | YAML | Persistent configuration (PM, CRM type, platform, telemetry) |
| `sessions/<PID>` | Touch file | Active session tracking (auto-cleanup after 2 hours) |
| `analytics/skill-usage.jsonl` | JSONL | Telemetry event log |
| `state/active-rfqs.jsonl` | JSONL | Active RFQ tracking |
| `state/active-orders.jsonl` | JSONL | Active order tracking |
| `state/workflow-state.jsonl` | JSONL | Workflow transition log |
| `state/rules-eval-log.jsonl` | JSONL | Rules engine evaluation log |
| `rules.yaml` | YAML | Custom business rules |
| `reports/REVA-TURBO-Reports/` | .docx | Generated reports |
| `company-profile.yaml` | YAML | Company name, address, team, escalation (via setup) |
| `partners.yaml` | YAML | Manufacturing partner profiles (via setup) |
| `shipping-config.yaml` | YAML | Carriers, ports, broker, incoterms (via setup) |
| `document-config.yaml` | YAML | Logo, formats, storage, backup (via setup) |
| `connector-config.yaml` | YAML | CRM, email, ERP, Slack settings (via setup) |
| `workflow-config.yaml` | YAML | Stage activation, thresholds, SLAs (via setup) |
| `users/<pm-slug>/voice-profile.yaml` | YAML | Per-PM voice dimensions (via voice) |
| `users/<pm-slug>/preferences.yaml` | YAML | Per-PM workflow preferences (via voice) |
| `users/<pm-slug>/edit-history.jsonl` | JSONL | Voice continuous learning edit log |
| `state/trust-level.json` | JSON | System-wide trust level |
| `state/current-context.json` | JSON | Active working context (customer/order) |
| `state/context-history.jsonl` | JSONL | Context stack for /switch and /back |
| `state/trust-overrides.jsonl` | JSONL | Per-skill/entity trust overrides |

### Hook System

PreToolUse hooks intercept tool invocations before execution:

- **check-workflow-state.sh** — Validates workflow transitions (e.g., must qualify before quoting)
- **check-data-sensitivity.sh** — Prevents writing customer trade secrets to unprotected locations
- **autopilot-check.sh** — Evaluates auto-advancement rules for workflow transitions
- **pulse-check.sh** — Scans state files for alert conditions
- **sync-check.sh** — Checks sync health across channels
- **rules-engine.sh** — Evaluates business rules against current context

---

## Configuration

```bash
# View all config
reva-turbo-config list

# Set config values
reva-turbo-config set default_pm ray-yeh
reva-turbo-config set report_format docx
reva-turbo-config set platform mac
reva-turbo-config set crm_type dynamics
reva-turbo-config set telemetry on
reva-turbo-config set proactive true
reva-turbo-config set china_partner_default "Shenzhen Precision MFG"
```

### Config Keys

| Key | Values | Default | Purpose |
|-----|--------|---------|---------|
| `default_pm` | PM name slug | `""` | Default PM for assignments |
| `report_format` | `docx` | `docx` | Report output format |
| `platform` | `mac`, `windows` | auto-detected | Operating system |
| `crm_type` | `dynamics`, `powerapps`, `hubspot`, `none` | `none` | CRM integration target |
| `telemetry` | `on, off` | `off` | Telemetry tier |
| `proactive` | `true`, `false` | `true` | Auto-suggest skills based on context |
| `china_partner_default` | Partner name | `""` | Default manufacturing partner |
| `setup_completed` | `true`, `false`, `skipped` | `false` | Whether setup wizard has run |
| `trust_level` | `1`, `2`, `3` | `2` | System-wide trust level (1=LEARN, 2=ASSIST, 3=OPERATE) |

---

## Reports

All reports are saved as `.docx` to `~/.reva-turbo/reports/REVA-TURBO-Reports/` by default.

**Naming convention:** `REVA-TURBO-{Type}-{YYYY-MM-DD}-{ShortName}.docx`

**Report types:**

| Type | Skill | Frequency |
|------|-------|-----------|
| Weekly PM Summary | reva-turbo-report | Weekly |
| Monthly Performance | reva-turbo-report | Monthly |
| Quarterly Leadership Review | reva-turbo-report | Quarterly |
| Customer Report | reva-turbo-report | On demand |
| Profitability Report | reva-turbo-profit | Per order / on demand |
| Intel Report | reva-turbo-intel | On demand |
| Partner Scorecard | reva-turbo-partner-scorecard | Monthly |
| Daily Pulse Digest | reva-turbo-pulse | Daily |
| Weekly Pulse Report | reva-turbo-pulse | Weekly |
| Handoff Briefing | reva-turbo-handoff | On event |
| Change Order | reva-turbo-change-order | On event |
| Margin Alert | reva-turbo-profit | On trigger |
| NCR Report | reva-turbo-ncr | On event |
| Inspection Report | reva-turbo-inspect | On event |
| Quote | reva-turbo-rfq-quote | Per RFQ |

---

## Team

| Name | Role | Region |
|------|------|--------|
| **Donovan Weber** | President & Co-founder | All escalations |
| **Ray Yeh** | Senior Project Manager | — |
| **Harley Scott** | Senior Project Manager | — |
| **Matt Nebo** | Director of BD | West Coast |
| **Barry Coyle** | Director of BD | Midwest |
| **Bryce Martel** | Director of BD | East Coast |
| **Ryan Knight** | Business Development | — |

---

## Telemetry

REVA-TURBO tracks skill usage locally to improve the engine. Two settings:

| Tier | What's Collected | Where |
|------|-----------------|-------|
| `off` | Nothing | — |
| `anonymous` | Skill name, duration, outcome (no PII) | `~/.reva-turbo/analytics/skill-usage.jsonl` |
| `community` | Same as anonymous + installation ID | `~/.reva-turbo/analytics/skill-usage.jsonl` |

No code, file paths, customer data, or PII are ever collected. Telemetry is opt-in and prompted on first run.

---

## Quick Start

See [INSTALL.md](INSTALL.md) for detailed installation instructions including agentic install, git clone, upload, and zip import methods.

```bash
git clone https://github.com/mrdulasolutions/RevOps-RevAMfg.git reva-turbo
cd reva-turbo
./setup
```

Then in Claude Code:
```
/revmyengine
```

---

## Documentation

| Document | Purpose |
|----------|---------|
| [README.md](README.md) | This file — overview, skills, architecture |
| [INSTALL.md](INSTALL.md) | Installation guide (4 methods) |
| [ARCHITECTURE.md](ARCHITECTURE.md) | Technical architecture deep-dive |
| [CLIENT.md](CLIENT.md) | Rev A Manufacturing company profile |
| [ETHOS.md](ETHOS.md) | Design philosophy and principles |
| [LICENSE.md](LICENSE.md) | License terms |
| [CLAUDE.md](CLAUDE.md) | Claude Code project instructions |
| [ROADMAP.md](ROADMAP.md) | Versioned roadmap with customer portal options |

---

## File Tree

```
REVA-TURBO/
  README.md                     Overview and usage
  INSTALL.md                    Installation guide
  ARCHITECTURE.md               Technical architecture
  CLIENT.md                     Rev A Mfg company profile
  ETHOS.md                      Design philosophy
  LICENSE.md                    License terms
  ROADMAP.md                    Versioned roadmap
  CLAUDE.md                     Claude Code project instructions
  VERSION                       1.2.0
  conductor.json                Skill routing + commands registry
  setup                         One-step installer
  package.json                  Root package

  bin/                          Engine-wide utilities
    reva-turbo-config               Config read/write
    reva-turbo-telemetry-log        JSONL event logger
    reva-turbo-session-track        PID session management
    reva-turbo-update-check         Version check
    reva-turbo-slug                 Report slug generator

  revmyengine/                Master orchestrator (intent + command routing)

  # Lifecycle order (left to right = flow direction)
  reva-turbo-rfq-intake/            RFQ parsing & intake
  reva-turbo-rfq-qualify/           Gate checks
  reva-turbo-customer-gate/         New customer onboarding (if new)
  reva-turbo-export-compliance/     Export compliance (ExChek engine) [HARD GATE]
  reva-turbo-rfq-quote/             Quote generation (after compliance clears)
  reva-turbo-customer-comms/        Customer emails
  reva-turbo-china-package/         Spec packaging for China
  reva-turbo-china-track/           Manufacturing tracking
  reva-turbo-import-compliance/     Import compliance (TradeInsights.ai) [HARD GATE]
  reva-turbo-inspect/               Incoming inspection
  reva-turbo-quality-gate/          Quality gates (G1-G4)
  reva-turbo-repackage/             Repackaging workflow
  reva-turbo-logistics/             Shipping & customs
  reva-turbo-order-track/           Order lifecycle

  # Supporting skills
  reva-turbo-customer-profile/      Customer profiles
  reva-turbo-partner-scorecard/     Partner scoring
  reva-turbo-ncr/                   Non-conformance reports
  reva-turbo-dashboard/             PM dashboard
  reva-turbo-report/                Periodic reports
  reva-turbo-audit-trail/           Decision audit log
  reva-turbo-escalate/              Escalation workflow
  reva-turbo-docx/                  MD-to-DOCX converter
  reva-turbo-templates/             Template management
  reva-turbo-cron/                  Scheduled tasks
  reva-turbo-reminder/              PM reminders
  reva-turbo-email-connector/       Email (Native M365 + Hostinger + Gmail + MCP Inbox)
  reva-turbo-crm-connector/         CRM integration
  reva-turbo-erp-connector/         ERP integration

  # Magic layer
  reva-turbo-autopilot/             Workflow auto-advancement
  reva-turbo-pulse/                 Real-time alerts
  reva-turbo-intel/                 Predictive analytics
  reva-turbo-quick/                 One-shot actions
  reva-turbo-sync/                  CRM/email auto-sync
  reva-turbo-change-order/          Change management
  reva-turbo-profit/                Profitability tracking
  reva-turbo-handoff/               PM handoff & collaboration
  reva-turbo-rules/                 Business rules engine

  # Personalization
  reva-turbo-setup/                 Onboarding wizard (7 sections, 6 config files)
  reva-turbo-trust/                 Progressive autonomy (LEARN/ASSIST/OPERATE)
  reva-turbo-voice/                 Per-PM voice & personality tuner
```

**41 skill directories. 376 files. 36,937 lines. 20 in-engine commands. Zero tribal knowledge.**

---

Built by [MrDula Solutions](https://mrdulasolutions.com) for Rev A Manufacturing.

Powered by Claude Code and the Anthropic Claude model family.
