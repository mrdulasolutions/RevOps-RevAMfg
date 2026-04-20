# REVA-TURBO Trust Level Behavior Reference

This document defines how each REVA-TURBO skill responds to the three Trust Levels: Level 1 (Learn), Level 2 (Assist), and Level 3 (Operate). Trust levels are set via `reva-turbo-trust` and stored in `~/.reva-turbo/config/trust.yaml`.

**Current trust level is always visible via `/reva-turbo whoami`.**

---

## Trust Level Definitions

| Level | Name | Description |
|-------|------|-------------|
| **1** | **Learn** | Always asks before acting. Shows analysis and recommendation. Waits for PM to execute every action manually. |
| **2** | **Assist** | Prepares actions and drafts. PM approves each one. Can execute non-sensitive, non-gated tasks automatically after approval. |
| **3** | **Operate** | Can auto-advance through non-gated stages. All HITL gates still enforced. Compliance, financial, and communications actions always require PM approval regardless of trust level. |

---

## Safety Overrides — Absolute (Cannot Be Overridden by Any Trust Level)

The following categories are **always** governed at the specified minimum trust behavior, regardless of what trust level is configured:

| Category | Minimum Behavior | Rationale |
|----------|-----------------|-----------|
| Export compliance decisions (ECCN, ITAR, license) | Always Level 1 — PM must approve every classification and license determination | Regulatory exposure; no automation allowed |
| Import compliance — HTS classification changes | Always Level 1 for any HTS code change | Duty impact; potential customs fraud risk |
| Import compliance — routine re-imports (same HTS) | Level 2 minimum | Still requires PM acknowledgment |
| Customer communications — all outbound | Always Level 2 minimum — PM must approve all outbound comms | Brand and relationship risk |
| Quality gate FAIL or HOLD disposition | Always Level 1 — PM must review and decide | Customer impact; quality liability |
| Partner selection | Always Level 2 — PM must confirm vendor selection | Commercial and IP risk |
| Cost overrides >10% over estimate | Always Level 1 — PM must review before proceeding | Financial exposure |
| ISF filing | Always Level 2 — PM must review all 10 data elements before filing | CBP penalty risk ($5,000/violation) |
| Escalation to Donovan Weber | Always Level 1 — PM must explicitly trigger | Executive escalation requires human judgment |

---

## Per-Skill Trust Behavior Table

### RFQ Pipeline Skills

| Skill | Level 1 (Learn) | Level 2 (Assist) | Level 3 (Operate) |
|-------|----------------|-----------------|------------------|
| **reva-turbo-rfq-intake** | Shows extracted RFQ fields, asks PM to confirm each | Auto-logs RFQ; asks PM to confirm before creating workflow record | Auto-extracts, auto-logs, auto-advances to rfq-qualify |
| **reva-turbo-rfq-qualify** | Shows qualification analysis and recommendation; PM decides | Runs qualification gate; PM confirms PROCEED/REJECT decision | Auto-runs qualification; auto-advances if PROCEED; pauses on REJECT or CONDITIONAL |
| **reva-turbo-rfq-quote** | Builds cost model, shows to PM, PM executes quote generation | Generates quote draft; PM reviews and approves before saving | Generates and saves quote; pauses at PM review step before sending |

### Customer Skills

| Skill | Level 1 (Learn) | Level 2 (Assist) | Level 3 (Operate) |
|-------|----------------|-----------------|------------------|
| **reva-turbo-customer-gate** | Shows onboarding checklist analysis; PM completes each step manually | Runs checklist; PM approves gate decision | Auto-runs non-sensitive checks; PM approves gate decision — SAFETY OVERRIDE: gate decision always requires PM |
| **reva-turbo-customer-profile** | Shows proposed profile fields; PM confirms before writing | Writes profile after PM confirms; shows summary | Auto-writes profile; notifies PM of completion |
| **reva-turbo-customer-comms** | Drafts all comms; PM must approve each one and execute send manually | Drafts and saves to drafts folder; PM approves; PM initiates send | Drafts and saves; PM approves and confirms send — SAFETY OVERRIDE: all outbound comms require Level 2 minimum |

### Compliance Skills

| Skill | Level 1 (Learn) | Level 2 (Assist) | Level 3 (Operate) |
|-------|----------------|-----------------|------------------|
| **reva-turbo-export-compliance** | Presents ExChek analysis; PM reviews every determination | Same as Level 1 — SAFETY OVERRIDE: always Level 1 for all determinations | Same as Level 1 — SAFETY OVERRIDE applies regardless of trust level |
| **reva-turbo-import-compliance** | Presents HTS analysis and duty calc; PM confirms all classifications | Auto-confirms routine re-imports (same HTS); PM confirms any HTS change | Same as Level 2 — HTS changes always require PM; routine re-imports can auto-confirm |
| **reva-turbo-isf-filing** | Collects 10+2 data, presents to PM, PM initiates filing manually | Collects and prepares 10+2; PM reviews and approves; PM initiates filing — SAFETY OVERRIDE: Level 2 minimum always | Same as Level 2 — SAFETY OVERRIDE applies |

### Manufacturing Skills

| Skill | Level 1 (Learn) | Level 2 (Assist) | Level 3 (Operate) |
|-------|----------------|-----------------|------------------|
| **reva-turbo-partner-select** | Scores all partners, presents ranked list, PM chooses | Scores and recommends; PM must confirm selection — SAFETY OVERRIDE: Level 2 minimum | Same as Level 2 — partner selection always requires PM |
| **reva-turbo-china-package** | Builds package draft; PM reviews each section; PM approves before sending | Builds and presents complete package; PM approves to send | Builds and presents; PM must approve before sending — sensitive IP always requires review |
| **reva-turbo-china-track** | Shows milestone status and recommendations; PM manually advances each | Auto-updates milestone log; surfaces delays to PM; PM decides on escalation | Auto-updates log; auto-suggests escalation on Critical delays; PM approves escalation |
| **reva-turbo-partner-scorecard** | Presents calculated scorecard; PM reviews before saving | Auto-calculates and saves scorecard; notifies PM of grade and action recommendations | Auto-calculates, saves, and queues action recommendations for PM review |
| **reva-turbo-partner-master** | Shows proposed record changes; PM confirms each | Makes changes after PM confirmation | Auto-updates non-sensitive fields; PM confirms structural changes |

### Quality Skills

| Skill | Level 1 (Learn) | Level 2 (Assist) | Level 3 (Operate) |
|-------|----------------|-----------------|------------------|
| **reva-turbo-inspect** | Guides PM through each inspection step; PM records results; PM assigns disposition | Structures inspection checklist; PM records results; disposition recommendation requires PM confirmation | Same as Level 2 — disposition always requires PM |
| **reva-turbo-ncr** | Guides through NCR process; PM confirms each section | Builds NCR draft; PM reviews and confirms before saving | Auto-builds NCR from inspection data; PM reviews before finalizing |
| **reva-turbo-quality-gate** | Presents checklist; PM runs each check; PM makes gate decision | Structures checklist; PM runs checks; PM makes gate decision | G1/G2: auto-advance if all criteria met; G3/G4: always requires PM — SAFETY OVERRIDE for G3/G4 |

### Order Skills

| Skill | Level 1 (Learn) | Level 2 (Assist) | Level 3 (Operate) |
|-------|----------------|-----------------|------------------|
| **reva-turbo-order-track** | Shows order status; PM manually advances stages | Recommends stage advances; PM confirms each transition | Auto-advances stages on confirmed triggers; PM confirms major transitions (ship, deliver, close) |
| **reva-turbo-logistics** | Presents routing analysis; PM makes routing decision; PM sets up shipment | Recommends routing; PM confirms; prepares shipment docs after confirmation | Auto-recommends routing; PM confirms routing; auto-prepares docs after confirmation |
| **reva-turbo-repackage** | Guides through repackaging; PM records actions | Structures repackaging workflow; PM confirms completion | Auto-logs repackaging when PM confirms; auto-advances to logistics |
| **reva-turbo-cost-tracking** | Shows cost entries; PM confirms each entry | Auto-logs estimates from quote; PM confirms actuals | Auto-logs estimates; HITL on >10% variance always enforced |

### Reporting and System Skills

| Skill | Level 1 (Learn) | Level 2 (Assist) | Level 3 (Operate) |
|-------|----------------|-----------------|------------------|
| **reva-turbo-report** | Generates draft; PM reviews and approves before saving | Generates and presents; PM approves | Auto-generates on schedule; PM notified of completion |
| **reva-turbo-profit** | Presents analysis; PM reviews and approves report | Generates analysis; PM reviews and approves | Auto-generates after order close; PM notified |
| **reva-turbo-dashboard** | Generates on request; presents to PM | Generates on request; auto-refreshes on schedule | Auto-refreshes; PM views on demand |
| **reva-turbo-escalate** | Presents escalation analysis; PM decides and sends | Same — SAFETY OVERRIDE: escalation always requires PM decision | Same — SAFETY OVERRIDE applies |
| **reva-turbo-audit-trail** | Reads and presents audit records | Reads, presents, and generates summary reports | Auto-generates weekly audit summary; PM notified |
| **reva-turbo-pulse** | Queues alerts; PM reviews and approves sending | Sends non-critical alerts automatically; PM reviews critical alerts | Sends all alerts automatically; PM receives all; can configure thresholds |
| **reva-turbo-reminder** | Creates reminders; notifies PM at trigger time | Creates and sends reminders automatically | Same as Level 2 |
| **reva-turbo-cron** | Runs scheduled tasks; notifies PM of results | Runs scheduled tasks; auto-logs results; PM notified of anomalies | Same as Level 2 |

### Magic Skills

| Skill | Level 1 (Learn) | Level 2 (Assist) | Level 3 (Operate) |
|-------|----------------|-----------------|------------------|
| **reva-turbo-autopilot** | Disabled — autopilot requires Level 3 | Disabled — autopilot requires Level 3 | Enabled — auto-advances lifecycle for non-gated stages; all SAFETY OVERRIDES apply |
| **reva-turbo-intel** | Generates analysis and forecasts on request | Generates on request; surfaces anomalies proactively | Auto-surfaces risk alerts and predictions; PM reviews |
| **reva-turbo-quick** | Interprets quick commands; shows proposed action for PM to confirm | Executes non-sensitive quick commands after confirmation; shows plan for sensitive ones | Executes most quick commands directly; pauses for sensitive (compliance, comms, financial) |
| **reva-turbo-change-order** | Presents impact analysis; PM decides | Builds change order; PM approves impact and customer notification | Auto-builds; PM must approve before any customer communication |
| **reva-turbo-handoff** | Prepares handoff summary; PM confirms | Prepares and routes handoff; target PM must accept | Same as Level 2 |
| **reva-turbo-rules** | Shows rules and proposed changes; PM approves | PM must approve all rule changes | Same as Level 2 — rules changes always require PM |

---

## Autopilot Interaction

`reva-turbo-autopilot` is a meta-skill that enables autonomous lifecycle advancement. It is only active at Trust Level 3. Even when autopilot is enabled:

1. **All HITL gates are still enforced.** Autopilot will pause at every gate marked `hitl: true` in the skill registry.
2. **All SAFETY OVERRIDES are still enforced.** Autopilot cannot bypass export compliance, customer communications approval, G3/G4 quality gates, cost variance HITL, ISF filing review, or partner selection.
3. **Autopilot advances non-gated stages automatically** — updating state files, logging transitions, and triggering downstream skills without PM interaction.
4. **Autopilot notifies PM of every auto-advance** via reva-turbo-pulse (low-priority alert by default at Trust Level 3). PM can review the pulse feed to see what autopilot has done.
5. **PM can interrupt autopilot at any time** by invoking any skill directly. The manual invocation takes precedence.

**Autopilot mode types (from conductor.json `autopilot` field):**
- `"autopilot": "pause"` — Autopilot always stops at this skill and waits for PM
- `"autopilot": "conditional"` — Autopilot can advance if all criteria are met; pauses on any exception
- `"autopilot": "auto"` — Autopilot advances through this skill automatically (informational/utility skills only)
