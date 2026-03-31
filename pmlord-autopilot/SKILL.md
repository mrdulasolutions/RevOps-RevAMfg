---
name: pmlord-autopilot
preamble-tier: 1
version: 1.0.0
description: |
  Invisible workflow transitions. When one skill completes, autopilot
  automatically triggers the next step in the lifecycle without PM intervention
  for routine transitions. The PM sets the mode (full auto, semi-auto, manual)
  and the engine runs the lifecycle chain autonomously, pausing only at
  human-required decision points. This is the skill that makes PMLORD feel alive.
compatibility: Claude Code, Claude desktop, Claude CoWork
allowed-tools:
  - Bash
  - Read
  - Write
  - Edit
  - Glob
  - Grep
  - AskUserQuestion
---

## Preamble (run first)

```bash
mkdir -p ~/.pmlord/analytics
echo '{"skill":"pmlord-autopilot","ts":"'$(date -u +%Y-%m-%dT%H:%M:%SZ)'"}' >> ~/.pmlord/analytics/skill-usage.jsonl 2>/dev/null || true
```

## Purpose

Transform PMLORD from a skill-by-skill manual workflow into a self-driving lifecycle engine. When one skill completes, autopilot reads the transition rules, determines whether the next step should fire automatically or pause for human input, and either chains into the next skill with full data carryover or alerts the PM with a summary of what was completed and what needs their attention.

The PM sets it and forgets it. The engine does the rest.

## Flow

### Step 1 — Activation

When a PM enables autopilot for an RFQ or order, capture the configuration:

```bash
mkdir -p ~/.pmlord/state
```

Ask the PM:

> **Autopilot Configuration**
>
> Which mode for {{ORDER_ID}} / {{RFQ_ID}}?
>
> A) **FULL AUTO** — All auto-eligible transitions fire without confirmation. You get a summary digest.
> B) **SEMI AUTO** — Auto-transitions fire but you get a notification before each one. You can cancel within 5 minutes.
> C) **MANUAL** — Traditional mode. No auto-transitions. (Default)
>
> You can change this at any time by saying "change autopilot mode."

Save the configuration:

```bash
echo '{"ts":"'$(date -u +%Y-%m-%dT%H:%M:%SZ)'","entity_id":"{{ENTITY_ID}}","entity_type":"{{ENTITY_TYPE}}","mode":"{{AUTOPILOT_MODE}}","pm":"{{PM_NAME}}","enabled":true}' >> ~/.pmlord/state/autopilot-config.jsonl 2>/dev/null || true
```

Reference: `references/autopilot-modes.md` for full mode descriptions and behavior.

### Step 2 — Transition Rule Lookup

When any skill completes, autopilot reads the transition matrix from `references/transition-rules.md` and determines:

1. **What just completed?** — Read the last `workflow-state.jsonl` entry for this entity.
2. **What comes next?** — Look up the `from` stage in the transition matrix.
3. **Is it auto-eligible?** — Check the `auto` column.
4. **Are conditions met?** — Evaluate the condition column against current state data.

Decision tree:

```
Skill completes
  |
  +-- Read transition-rules.md
  |     |
  |     +-- Transition is AUTO and conditions met?
  |     |     |
  |     |     +-- Mode is FULL AUTO?
  |     |     |     +-- YES: Execute next skill immediately with data carryover
  |     |     |
  |     |     +-- Mode is SEMI AUTO?
  |     |     |     +-- YES: Notify PM, wait 5 min for cancel, then execute
  |     |     |
  |     |     +-- Mode is MANUAL?
  |     |           +-- YES: Suggest next skill, wait for PM to confirm
  |     |
  |     +-- Transition is PAUSE?
  |           +-- Always stop and ask PM regardless of mode
  |
  +-- Log the transition decision to workflow-state.jsonl
```

### Step 3 — Auto-Trigger Execution

When a transition fires automatically:

1. **Read the next skill's SKILL.md** — Load the full skill definition from the conductor.json path.
2. **Build the data carryover package** — Collect all context from the completing skill:
   - Entity ID (RFQ_ID or ORDER_ID)
   - Customer data (company, contact, email)
   - Part data (description, quantity, material, specs)
   - Partner data (if assigned)
   - Timeline data (dates, milestones)
   - Quality data (inspection results, gate decisions)
   - Any skill-specific output (quote amounts, tracking numbers, etc.)
3. **Pre-fill the next skill's placeholders** — Map carryover data to the next skill's `{{PLACEHOLDER}}` variables so the PM never re-enters data.
4. **Execute** — Run the next skill with pre-filled data.

Data carryover package format:

```bash
echo '{"ts":"'$(date -u +%Y-%m-%dT%H:%M:%SZ)'","entity_id":"{{ENTITY_ID}}","from_skill":"{{FROM_SKILL}}","to_skill":"{{TO_SKILL}}","carryover":{"customer":"{{CUSTOMER_COMPANY}}","contact":"{{CONTACT_NAME}}","contact_email":"{{CONTACT_EMAIL}}","part_desc":"{{PART_DESCRIPTION}}","qty":"{{QUANTITY}}","partner":"{{PARTNER_NAME}}","order_id":"{{ORDER_ID}}","rfq_id":"{{RFQ_ID}}"}}' >> ~/.pmlord/state/carryover-log.jsonl 2>/dev/null || true
```

### Step 4 — Pause Points (Human-Required)

The following transitions ALWAYS pause regardless of autopilot mode. These are non-negotiable safety gates:

| Pause Point | Reason |
|-------------|--------|
| Send quote to customer | Customer-facing communication requires PM review |
| Send any customer communication | Never auto-send to customers |
| Quality gate decision | PM must confirm PASS/CONDITIONAL/FAIL |
| NCR disposition | Disposition decision requires human judgment |
| Escalation | PM must be aware of all escalations |
| Shipment notification to customer | Customer-facing — PM approves |
| Partner score override | Score changes require PM confirmation |
| Price/margin override | Financial decisions require PM sign-off |

When hitting a pause point:

> **Autopilot paused at: {{PAUSE_POINT}}**
>
> Completed automatically:
> {{AUTO_COMPLETED_SUMMARY}}
>
> Needs your input:
> {{PAUSE_REASON}}
>
> A) Review and continue
> B) Pause autopilot for this order
> C) Switch to manual mode

### Step 5 — State Machine

Track the current lifecycle position for each active entity:

```bash
echo '{"ts":"'$(date -u +%Y-%m-%dT%H:%M:%SZ)'","entity_id":"{{ENTITY_ID}}","current_stage":"{{CURRENT_STAGE}}","previous_stage":"{{PREVIOUS_STAGE}}","autopilot_mode":"{{AUTOPILOT_MODE}}","auto_advanced":{{AUTO_ADVANCED}},"conditions_met":{{CONDITIONS_MET}}}' >> ~/.pmlord/state/workflow-state.jsonl 2>/dev/null || true
```

The state machine maintains:
- `current_stage` — Which skill/stage the entity is in right now
- `previous_stage` — Where it came from
- `autopilot_mode` — Current mode for this entity
- `auto_advanced` — Boolean: was this transition automatic?
- `conditions_met` — Boolean: were all conditions satisfied?
- `paused_at` — If paused, which pause point
- `pause_reason` — Why the pause was triggered

### Step 6 — Data Carryover Engine

The carryover engine ensures zero re-entry between skills. When transitioning:

1. **Scan the completing skill's output** — Read all generated files, JSONL entries, and template outputs.
2. **Extract all {{PLACEHOLDER}} values** — Build a key-value map of every data point.
3. **Map to the next skill's inputs** — Use conductor.json field mappings and the next skill's SKILL.md to identify required inputs.
4. **Pre-fill** — Inject all known values into the next skill's flow.
5. **Flag unknowns** — If the next skill needs data not available from carryover, flag it and only ask the PM for those specific fields.

This means: if an RFQ goes from intake to qualification to quoting, the customer name, contact info, part specs, and all other data flows through automatically. The PM never types it twice.

### Step 7 — Notification and Summary

After any auto-completed chain, generate a summary for the PM:

> **Autopilot Summary for {{ENTITY_ID}}**
>
> **Auto-completed steps:**
> 1. {{STEP_1_SKILL}} — {{STEP_1_RESULT}} ({{STEP_1_TIMESTAMP}})
> 2. {{STEP_2_SKILL}} — {{STEP_2_RESULT}} ({{STEP_2_TIMESTAMP}})
> 3. {{STEP_3_SKILL}} — {{STEP_3_RESULT}} ({{STEP_3_TIMESTAMP}})
>
> **Paused at:** {{PAUSE_POINT}} ({{PAUSE_REASON}})
>
> **Data carried forward:**
> - Customer: {{CUSTOMER_COMPANY}}
> - Part: {{PART_DESCRIPTION}}
> - Qty: {{QUANTITY}}
> - Partner: {{PARTNER_NAME}}
>
> **Time saved:** ~{{MINUTES_SAVED}} minutes of manual transitions
>
> Ready when you are. Say "continue" to proceed from the pause point.

### Step 8 — Override Controls

The PM can override autopilot at any time with natural language:

| Command | Action |
|---------|--------|
| "pause autopilot" | Pause auto-transitions for current entity |
| "resume autopilot" | Resume auto-transitions from current stage |
| "disable autopilot" | Switch to manual mode |
| "autopilot full auto" | Switch to full auto mode |
| "autopilot semi auto" | Switch to semi auto mode |
| "autopilot status" | Show current mode and stage for all active entities |
| "skip to [stage]" | Jump ahead in lifecycle (with confirmation) |
| "go back to [stage]" | Return to a previous stage (with confirmation) |

Override actions are logged:

```bash
echo '{"ts":"'$(date -u +%Y-%m-%dT%H:%M:%SZ)'","entity_id":"{{ENTITY_ID}}","action":"{{OVERRIDE_ACTION}}","previous_mode":"{{PREVIOUS_MODE}}","new_mode":"{{NEW_MODE}}","pm":"{{PM_NAME}}"}' >> ~/.pmlord/state/autopilot-overrides.jsonl 2>/dev/null || true
```

### Step 9 — Audit Trail

Every autopilot transition is logged with an `autopilot` flag so the audit trail clearly distinguishes between human-initiated and auto-initiated transitions:

```bash
echo '{"ts":"'$(date -u +%Y-%m-%dT%H:%M:%SZ)'","entity_id":"{{ENTITY_ID}}","from":"{{FROM_SKILL}}","to":"{{TO_SKILL}}","trigger":"autopilot","mode":"{{AUTOPILOT_MODE}}","conditions":"{{CONDITIONS_EVALUATED}}","result":"{{TRANSITION_RESULT}}","pm":"{{PM_NAME}}","data_carryover_fields":["{{FIELD_LIST}}"]}' >> ~/.pmlord/state/workflow-state.jsonl 2>/dev/null || true
```

For compliance and traceability:
- Every auto-transition has a `trigger: autopilot` marker
- Every pause has a `trigger: autopilot_pause` marker with the reason
- Every override has a `trigger: pm_override` marker
- The PM's name is always recorded even on auto-transitions (they own the order)

## Safety Rules

Read `prompts/autopilot-system.md` for the complete safety ruleset. Critical rules:

1. **NEVER auto-send customer communications** — All customer-facing messages require PM review and approval.
2. **NEVER auto-approve quality gates** — Quality decisions always need human judgment.
3. **NEVER auto-escalate without PM knowledge** — The PM must be informed before any escalation fires.
4. **NEVER auto-override financial decisions** — Pricing, margins, discounts, and payment terms require PM sign-off.
5. **NEVER auto-dispose NCRs** — Non-conformance disposition requires PM/quality judgment.
6. **NEVER skip a pause point** — Even in FULL AUTO mode, pause points are sacred.
7. **ALWAYS log** — Every transition, auto or manual, gets a JSONL audit entry.
8. **ALWAYS carry data forward** — Never drop context between transitions.

## Template References

- `prompts/autopilot-system.md` — System prompt with safety rules and behavior definition
- `references/transition-rules.md` — Complete transition matrix
- `references/autopilot-modes.md` — Mode descriptions and behaviors
- `bin/autopilot-check.sh` — Hook script for transition evaluation
