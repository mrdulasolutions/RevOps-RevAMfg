---
name: pmlord-trust
preamble-tier: 2
version: 1.0.0
description: |
  Progressive autonomy system for PMLORD. Three trust levels control
  how every skill behaves: Level 1 LEARN (explain everything, PM decides),
  Level 2 ASSIST (draft and pre-fill, PM reviews), Level 3 OPERATE
  (handle routine autonomously, PM audits exceptions).
  Supports per-user, per-skill, and per-entity overrides.
compatibility: Claude Code, Claude desktop, Claude CoWork
allowed-tools:
  - Bash
  - Read
  - Write
  - Edit
  - AskUserQuestion
---

## Preamble (run first)

```bash
mkdir -p ~/.pmlord/analytics ~/.pmlord/state ~/.pmlord/users
echo '{"skill":"pmlord-trust","ts":"'$(date -u +%Y-%m-%dT%H:%M:%SZ)'"}' >> ~/.pmlord/analytics/skill-usage.jsonl 2>/dev/null || true
```

## Purpose

Trust is the behavioral backbone of the PMLORD engine. It does not gate access or lock features -- it modifies HOW every skill communicates, confirms, and executes. A new PM gets a patient teaching assistant. An experienced PM gets a silent operator that only speaks up when something goes wrong.

Trust is a spectrum, not a lock. The PM can change their level at any time, override it per-skill or per-customer, and the engine will never gatekeep. Trust exists to serve the PM, not to restrict them.

Read `prompts/trust-system.md` for the core behavioral philosophy.

## 4 Modes

### Mode 1: `set` -- Change Trust Level

Set the system-wide trust level or a per-user level.

**Trigger:** PM says "set trust level", "change trust to...", "I want level X", "switch to learn/assist/operate mode"

**Flow:**

1. Read current trust level:

```bash
cat ~/.pmlord/state/trust-level.json 2>/dev/null || echo '{"level":1,"name":"learn","set_by":"default","set_at":"never"}'
```

2. Ask the PM which level they want:

> **Trust Level Selection**
>
> Current level: **{{CURRENT_LEVEL}}** ({{CURRENT_NAME}})
>
> Which level would you like?
>
> **1 - LEARN (Crawl)** -- "Let me show you how this works"
> I explain every step before taking it. You decide everything. Full teaching mode with context and best practices.
>
> **2 - ASSIST (Walk)** -- "I'll draft it, you verify"
> I pre-fill forms, draft communications, and build packages. You review before anything goes out. Confidence scores on outputs.
>
> **3 - OPERATE (Run)** -- "I'll handle the routine, you audit the exceptions"
> I handle routine tasks autonomously. You get exception-only alerts. Periodic audit summaries instead of per-action approval.

3. Save the new level:

```bash
echo '{"level":{{LEVEL}},"name":"{{NAME}}","set_by":"{{PM_NAME}}","set_at":"'$(date -u +%Y-%m-%dT%H:%M:%SZ)'","previous_level":{{PREV_LEVEL}},"reason":"{{REASON}}"}' > ~/.pmlord/state/trust-level.json
```

4. Log the change to history:

```bash
echo '{"ts":"'$(date -u +%Y-%m-%dT%H:%M:%SZ)'","action":"set","level":{{LEVEL}},"name":"{{NAME}}","set_by":"{{PM_NAME}}","scope":"system","reason":"{{REASON}}"}' >> ~/.pmlord/state/trust-history.jsonl
```

5. Confirm with behavioral summary:

Display what changes at the new level using the reference table from `references/trust-matrix.md`. Show 3--4 concrete examples of how behavior will differ.

### Mode 2: `assess` -- Trust Assessment Questionnaire

Run an interactive assessment to recommend the right trust level.

**Trigger:** PM says "assess my trust level", "what level should I be?", "help me pick a trust level", or this is the first time the engine runs and no trust level is set.

**Flow:**

1. Check if a trust level is already set:

```bash
cat ~/.pmlord/state/trust-level.json 2>/dev/null || echo "none"
```

2. Run the questionnaire. Ask each question one at a time:

**Question 1:**
> How long have you used PM workflow tools (ERP, PLM, or similar)?
>
> A) **New** -- This is my first time or I am just getting started
> B) **Some experience** -- I have used similar tools but not extensively
> C) **Expert** -- I have years of experience with PM workflows

**Question 2:**
> How familiar are you with your manufacturing partners (suppliers, factories, logistics)?
>
> A) **New relationships** -- These are new partners or I am still learning their capabilities
> B) **Established** -- I have worked with most of these partners before
> C) **Deep relationships** -- I know these partners well and have long-standing history

**Question 3:**
> How comfortable are you with AI-generated communications going to customers or partners?
>
> A) **Review everything** -- I want to see and approve every message before it goes out
> B) **Spot check** -- I trust routine messages but want to review anything unusual
> C) **Trust it** -- I am comfortable with AI handling routine communications

**Question 4:**
> Do you want to learn how the PMLORD engine works as you use it?
>
> A) **Yes, teach me** -- I want to understand each step and why it matters
> B) **I know enough** -- Brief explanations when something is unusual are fine
> C) **Just do it** -- I do not need explanations, just results

3. Score the answers:

| Answer pattern | Recommended level |
|---|---|
| Mostly A's (3--4 A answers) | Level 1: LEARN |
| Mix of A's and B's, or mostly B's | Level 2: ASSIST |
| Mostly C's (3--4 C answers) | Level 3: OPERATE |
| Mix of B's and C's | Level 2: ASSIST (with suggestion to try Level 3 after a few weeks) |

4. Present the recommendation:

> **Assessment Result**
>
> Based on your answers, I recommend **Level {{LEVEL}}: {{NAME}}**.
>
> {{EXPLANATION of why this level fits their answers}}
>
> Would you like to set this level now? You can change it at any time.

5. If PM accepts, save using the `set` flow above with reason "trust-assessment".

### Mode 3: `history` -- Trust Level Change History

Show the trust level change history.

**Trigger:** PM says "trust history", "show trust changes", "when did I change trust levels"

**Flow:**

1. Read the history file:

```bash
cat ~/.pmlord/state/trust-history.jsonl 2>/dev/null || echo "No trust history found."
```

2. Format as a readable table:

| Date | Action | Level | Scope | Reason |
|---|---|---|---|---|
| 2026-01-15 | set | 1 (LEARN) | system | Initial setup |
| 2026-02-01 | set | 2 (ASSIST) | system | trust-assessment |
| 2026-02-15 | override | 1 (LEARN) | skill:export-compliance | safety-critical |

3. Include summary statistics:
   - Current system level
   - Time at current level
   - Number of active overrides
   - Progression note if applicable (reference `references/trust-progression.md`)

### Mode 4: `override` -- Per-Skill or Per-Entity Overrides

Set trust level overrides that take precedence over the system-wide level.

**Trigger:** PM says "override trust for...", "set trust level for [skill/customer]...", "I want level X for..."

**Flow:**

1. Determine override type:
   - **Per-skill**: "set trust level 1 for export-compliance"
   - **Per-entity**: "set trust level 1 for customer Acme Corp"

2. Read current overrides:

```bash
cat ~/.pmlord/state/trust-overrides.jsonl 2>/dev/null || echo "No overrides set."
```

3. For per-skill overrides, ask:

> **Skill Trust Override**
>
> Set trust level **{{LEVEL}}** for skill **{{SKILL_NAME}}**?
>
> This means when you use {{SKILL_NAME}}, it will behave at Level {{LEVEL}} ({{LEVEL_NAME}}) regardless of your system-wide trust level.
>
> Reason (optional): ___
>
> Expiry (optional): ___ days, or permanent

4. For per-entity overrides, ask:

> **Entity Trust Override**
>
> Set trust level **{{LEVEL}}** for **{{ENTITY_TYPE}}** "{{ENTITY_ID}}"?
>
> This means when working with {{ENTITY_ID}}, all skills will behave at Level {{LEVEL}} ({{LEVEL_NAME}}).
>
> Reason (optional): ___
>
> Expiry (optional): ___ days, or permanent

5. Check safety constraints before saving. Reference `references/trust-overrides.md` for built-in safety caps:
   - Export/import compliance: max Level 2
   - Quality gates (final inspection): max Level 2
   - Financial approvals above threshold: max Level 2

   If the PM tries to set Level 3 on a safety-capped skill, warn:

   > This skill has a safety cap at Level 2. Export compliance decisions always require human review. I will set it to Level 2 instead.

6. Save the override:

```bash
echo '{"ts":"'$(date -u +%Y-%m-%dT%H:%M:%SZ)'","type":"{{skill|entity}}","skill":"{{SKILL_NAME}}","entity_type":"{{ENTITY_TYPE}}","entity_id":"{{ENTITY_ID}}","level":{{LEVEL}},"reason":"{{REASON}}","expires":"{{EXPIRY_DATE|null}}","set_by":"{{PM_NAME}}"}' >> ~/.pmlord/state/trust-overrides.jsonl
```

7. Log to history:

```bash
echo '{"ts":"'$(date -u +%Y-%m-%dT%H:%M:%SZ)'","action":"override","level":{{LEVEL}},"name":"{{NAME}}","scope":"{{SCOPE}}","reason":"{{REASON}}"}' >> ~/.pmlord/state/trust-history.jsonl
```

## Trust Level Display

When any skill starts, it should read the effective trust level using `bin/trust-check.sh` and display a compact indicator:

```
Trust: Level 2 ASSIST | Override: export-compliance -> Level 1 LEARN
```

The display format varies by trust level:
- **Level 1 LEARN**: `[LEARN] Teaching mode active -- I will explain each step`
- **Level 2 ASSIST**: `[ASSIST] Draft mode -- I will prepare, you review`
- **Level 3 OPERATE**: `[OPERATE] Autonomous mode -- exception alerts only`

## State Management

All trust state lives under `~/.pmlord/state/`:

| File | Purpose |
|---|---|
| `trust-level.json` | System-wide default trust level |
| `trust-overrides.jsonl` | Per-skill and per-entity overrides (append-only log) |
| `trust-history.jsonl` | All trust level changes (append-only audit log) |

Per-user trust levels are stored at `~/.pmlord/users/<pm-slug>/trust-level.json` using the same schema as the system-wide file.

## Integration with Other Skills

Every PMLORD skill should call `bin/trust-check.sh` at the start to determine the effective trust level, then apply the behavioral overlay from the appropriate prompt file:

- Level 1: Read and follow `prompts/trust-learn.md`
- Level 2: Read and follow `prompts/trust-assist.md`
- Level 3: Read and follow `prompts/trust-operate.md`

The specificity chain for resolving the effective trust level is:

**entity > skill > user > system**

This means a per-entity override (e.g., "Level 1 for customer Acme Corp") takes precedence over a per-skill override, which takes precedence over a per-user setting, which takes precedence over the system default.

## Interaction with Autopilot

Trust and autopilot are complementary but independent:

- **Trust** controls how the engine communicates and confirms with the PM
- **Autopilot** controls whether the engine automatically chains to the next workflow stage

At Level 3 OPERATE + Full Autopilot, the engine runs silently through the workflow, only alerting on exceptions. At Level 1 LEARN + Manual Autopilot, the engine explains each step and waits for confirmation before doing anything.

Trust does NOT override autopilot pause points. If autopilot says "pause here for human input," trust level does not bypass that gate. Conversely, if trust is Level 1 but autopilot is Full Auto, the engine will still explain what it is about to auto-transition to, but will proceed automatically.

## First-Run Behavior

If no trust level is set (`~/.pmlord/state/trust-level.json` does not exist), the engine defaults to **Level 1: LEARN** and offers to run the trust assessment:

> Welcome to PMLORD. Since this is your first time, I am starting in **LEARN mode** -- I will explain each step as we go.
>
> Would you like me to assess your experience level to find the right trust setting? (You can always change it later.)

## Promotion Suggestions

After sustained usage at a given level, the engine may suggest promotion. See `references/trust-progression.md` for criteria. Suggestions are never pushy -- one-time offer that can be dismissed:

> You have completed 50 RFQs at Level 2 with a 95% approval rate. Ready to try Level 3 for RFQ intake? You can always switch back.
