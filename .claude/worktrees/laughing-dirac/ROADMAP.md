# REVA-TURBO Roadmap

**Last updated:** March 30, 2026
**Current version:** 1.2.0
**Status:** Core engine shipped. Magic layer shipped. Personalization layer shipped. Customer portal next.

---

## Shipped (v1.0.0)

### Core Engine — 27 Skills

| Group | Skills | Status |
|-------|--------|--------|
| RFQ Pipeline | rfq-intake, rfq-qualify, rfq-quote | Shipped |
| Customer | customer-gate, customer-profile, customer-comms | Shipped |
| Manufacturing | china-package, china-track, partner-scorecard | Shipped |
| Quality | inspect, ncr, quality-gate | Shipped |
| Order & Logistics | order-track, logistics, repackage | Shipped |
| Reporting | dashboard, report, audit-trail | Shipped |
| System | engine, escalate, docx, templates, cron, reminder | Shipped |
| Connectors | email-connector, crm-connector, erp-connector | Shipped |

### Magic Layer — 9 Skills

| Skill | What It Does | Status |
|-------|-------------|--------|
| Autopilot | Invisible workflow auto-advancement (3 modes) | Shipped |
| Pulse | Real-time alerts via Slack/iMessage/email (14 alert types) | Shipped |
| Intel | Predictive analytics, risk scoring, trend analysis (22 KPIs) | Shipped |
| Quick | One-shot natural language PM actions (23 quick actions) | Shipped |
| Sync | Bidirectional CRM/email auto-sync with conflict resolution | Shipped |
| Change Order | Mid-stream change management with 6-dimension impact analysis | Shipped |
| Profit | Actual vs estimated cost tracking, margin alerts | Shipped |
| Handoff | Multi-PM collaboration, vacation handoff, approval chains | Shipped |
| Rules | YAML business rules engine (31 built-in rules, 7 rule types) | Shipped |

### Infrastructure

| Component | Status |
|-----------|--------|
| Orchestrator (revmyengine) | Shipped |
| Config system (reva-turbo-config) | Shipped |
| Telemetry (JSONL, 3-tier) | Shipped |
| Session tracking (PID-based) | Shipped |
| Hook system (PreToolUse) | Shipped |
| DOCX report generation | Shipped |
| Setup script (one-step install) | Shipped |
| GitHub repo (private) | Shipped |

**Total: 36 skills. 312 files. 32,028 lines.**

---

## Shipped (v1.2.0) — Personalization Layer

### Setup Wizard + Trust Levels + Voice Profiles + In-Engine Commands

| Component | What It Does | Status |
|-----------|-------------|--------|
| **reva-turbo-setup** | 7-section onboarding wizard: company, workflow, connectors, partners, shipping, docs, CoWork | Shipped |
| **reva-turbo-trust** | Progressive autonomy: LEARN (crawl) → ASSIST (walk) → OPERATE (run). Per-user/skill/entity overrides | Shipped |
| **reva-turbo-voice** | Per-PM voice tuning: 15+ dimensions, sample analysis, structured interview, continuous learning | Shipped |
| **In-engine commands** | 20 slash commands (/status, /help, /whoami, /partners, /switch, etc.) | Shipped |
| **First-run detection** | Auto-triggers setup wizard on first use | Shipped |
| **Trust injection** | Orchestrator applies trust overlay to every skill invocation | Shipped |
| **Voice loading** | Orchestrator applies voice profile to all generated content | Shipped |
| **Context stack** | /switch and /back for navigating between customers/orders/RFQs | Shipped |

### Config Files Created by Setup

| File | Contents |
|------|----------|
| `~/.reva-turbo/company-profile.yaml` | Company name, address, team, escalation matrix |
| `~/.reva-turbo/partners.yaml` | Manufacturing partner profiles |
| `~/.reva-turbo/shipping-config.yaml` | Carriers, ports, broker, incoterms |
| `~/.reva-turbo/document-config.yaml` | Logo, formats, storage, backup |
| `~/.reva-turbo/connector-config.yaml` | CRM, email, ERP, Slack settings |
| `~/.reva-turbo/workflow-config.yaml` | Stage activation, thresholds, SLAs |

**Total: 41 skills. 20 commands. ~380 files.**

---

## Next: Customer Portal (v1.1.0)

The customer portal is the first external-facing feature — a web application where Rev A's customers can track their orders, view documents, and communicate with their PM without calling or emailing.

### Three Build Options

#### Option A: Full Web App (Next.js + Vercel)

A production web application at `portal.revamfg.com` that customers bookmark and use daily.

**What customers get:**
- Submit RFQs online (structured form with file upload for drawings/specs)
- Track order status in real-time (12-stage lifecycle visualization)
- View and download documents (quotes, inspection reports, shipping docs, invoices)
- Message their PM directly (threaded conversation)
- View order history and reorder
- Receive notifications (email/SMS) on status changes

**Technical stack:**
- Next.js 14+ (App Router)
- Vercel deployment (Vercel MCP tools available)
- Authentication (email magic link or password — no friction for manufacturing buyers)
- API routes reading from REVA-TURBO data layer (`~/.reva-turbo/state/`)
- Database: Vercel Postgres or Supabase for customer accounts and portal state
- File storage: Vercel Blob or S3 for uploaded drawings and generated documents
- Real-time: WebSocket or polling for live order status updates

**Pages:**
| Page | Purpose |
|------|---------|
| `/login` | Email magic link or password auth |
| `/dashboard` | Customer's order overview — active orders, recent quotes, action items |
| `/rfq/new` | Submit a new RFQ (structured form + file upload) |
| `/rfq/[id]` | View RFQ status, quote, accept/decline |
| `/orders` | All orders with filtering and search |
| `/orders/[id]` | Order detail — 12-stage timeline, milestones, documents, messages |
| `/documents` | All documents (quotes, reports, certs, invoices) |
| `/messages` | Threaded PM conversation history |
| `/account` | Company profile, contacts, preferences |

**REVA-TURBO integration:**
- Portal writes new RFQs → `reva-turbo-rfq-intake` picks them up
- Portal reads order status from `~/.reva-turbo/state/active-orders.jsonl`
- Portal serves documents from `~/.reva-turbo/reports/REVA-TURBO-Reports/`
- Portal triggers `reva-turbo-pulse` alerts on customer actions (RFQ submitted, quote accepted)
- Portal reads customer profile from `reva-turbo-customer-profile` data
- PM uses `reva-turbo-customer-comms` → message appears in portal

**Effort:** Largest build. Full frontend + backend + auth + deployment + ongoing hosting.

**Timeline:** 2-3 build sessions.

---

#### Option B: REVA-TURBO Skill + Generated Portal

A REVA-TURBO skill (`reva-turbo-customer-portal`) that generates per-customer status pages. The PM runs `/reva-turbo:reva-turbo-customer-portal` and gets a shareable link or HTML file for that customer.

**What customers get:**
- A unique URL to their order dashboard (read-only)
- Current order status with timeline visualization
- Document downloads (quotes, inspection reports, shipping docs)
- No login required (unique URL per customer with optional expiration)
- Mobile-friendly single-page layout

**Technical approach:**
- Skill generates static HTML from REVA-TURBO state data
- HTML uses embedded CSS (no build step, no dependencies)
- PM can email the link or attach the HTML
- Optional: deploy generated pages to Vercel as static sites
- Optional: auto-regenerate on order status change

**Skill structure:**
```
reva-turbo-customer-portal/
  SKILL.md              # Flow: select customer, select orders, generate portal
  skill.yaml            # Manifest
  README.md             # Usage docs
  prompts/              # System prompt, generation rules
  references/           # Portal design spec, branding guide
  templates/            # HTML template with {{PLACEHOLDER}} variables
  bin/                  # Portal generation script
```

**Effort:** Medium. Skill + HTML template. No infra, no auth, no hosting costs.

**Timeline:** 1 build session.

---

#### Option C: Hybrid (Recommended)

Build in two phases:

**Phase 1 (this session):** Build `reva-turbo-customer-portal` as a REVA-TURBO skill (Option B). This gives Rev A an immediate capability — PMs can generate customer-facing status pages today.

**Phase 2 (next session):** Wire the skill's data layer and logic into a full Next.js web app (Option A). The skill becomes the backend brain; the web app becomes the frontend.

**Why hybrid:**
- Ship something useful immediately (Phase 1)
- The skill forces us to define the data model, page structure, and customer-facing content before building UI
- Phase 2 reuses everything from Phase 1 — no throwaway work
- Rev A can start sending portal links to customers this week while the full app is being built

**Timeline:**
- Phase 1: This session
- Phase 2: Next session

---

### Decision Required

| Option | Ship Speed | Customer Experience | PM Effort | Infra Cost |
|--------|-----------|-------------------|-----------|------------|
| **A: Full Web App** | 2-3 sessions | Best — real app with login | Low — portal is self-service | Vercel hosting |
| **B: Skill Only** | 1 session | Good — static pages, no login | Medium — PM generates per customer | None |
| **C: Hybrid** | Phase 1 now, Phase 2 next | Best (eventually) | Low (eventually) | Vercel (Phase 2) |

**Recommendation:** Option C. Ship the skill now, build the app next.

---

## Future Considerations (v1.3.0+)

Ideas not yet committed to the roadmap. These are possibilities, not promises.

| Idea | Category | Notes |
|------|----------|-------|
| Customer self-service RFQ submission | Portal | Let customers submit RFQs without emailing |
| Real-time order tracking (push notifications) | Portal | SMS/email alerts on stage changes |
| Partner portal | Portal | Mirror of customer portal for China manufacturing partners |
| Mobile app (PWA) | Platform | Progressive web app for PM field use |
| Multi-tenant support | Architecture | Run REVA-TURBO for multiple clients from one engine |
| AI quote estimation | Intelligence | Train on historical quotes to auto-estimate new ones |
| Voice interface | Platform | "Hey REVA-TURBO, what's the status of Acme's order?" |
| Supplier discovery | Intelligence | Find new manufacturing partners based on capability gaps |
| Automated PO generation | Workflow | Generate purchase orders from approved quotes |
| Customer satisfaction scoring | Analytics | NPS-style scoring integrated into order close |
| Warranty tracking | Workflow | Post-delivery warranty and returns management |
| Cost database | Intelligence | Historical cost data for better future estimates |
| Drawing version control | System | Track drawing revisions across orders |
| Compliance module | Quality | ITAR, ISO, AS9100 compliance tracking |
| Financial integration | Connector | QuickBooks/Xero connector for invoicing |

---

## Versioning

| Version | Scope | Status |
|---------|-------|--------|
| **v1.0.0** | Core engine (27 skills) + Magic Layer (9 skills) + Compliance (2 skills) + docs | Shipped |
| **v1.2.0** | Personalization layer (setup, trust, voice) + 20 in-engine commands | Shipped |
| **v1.3.0** | Customer portal (skill + web app) | Next |
| **v1.4.0** | Partner portal + mobile PWA | Future |
| **v2.0.0** | Multi-tenant + AI quote estimation + financial integration | Future |

---

*Built by MrDula Solutions for Rev A Manufacturing.*
