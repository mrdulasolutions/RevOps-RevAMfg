# revmyengine

**REVA-TURBO Master Orchestrator**

The brain of the REVA-TURBO skills engine. Routes PM requests to the correct sub-skill, chains the RFQ-to-delivery lifecycle, manages workflow state, and coordinates all 40 sub-skills.

## What It Does

1. **Command Routing** — Handles 20 in-engine `/` commands (`/status`, `/help`, `/whoami`, `/partners`, `/switch`, etc.) before checking intent routing
2. **Intent Routing** — Detects PM intent from natural language and routes to the correct sub-skill (40 intents mapped to 40 skills)
3. **Lifecycle Chaining** — After one skill completes, suggests the natural next step in the PM workflow
4. **First-Run Detection** — Detects new installations and triggers `reva-turbo-setup` onboarding wizard
5. **Trust Injection** — Reads the PM's trust level and applies the behavioral overlay (LEARN/ASSIST/OPERATE) to every skill invocation
6. **Voice Loading** — Reads the PM's voice profile and applies it to all generated content
7. **Context Stack** — Maintains working context (`/switch`, `/back`) so commands and skills scope to the active customer/order
8. **Session Tracking** — PID-based session management with auto-cleanup
9. **Telemetry** — Opt-in usage tracking (3 tiers: on, off)

## Invocation

```
/revmyengine
```

Or simply describe what you need — the engine detects intent automatically.

## Files

| File | Purpose |
|------|---------|
| `SKILL.md` | Full orchestrator instructions with YAML frontmatter |
| `skill.yaml` | Machine-readable manifest |
| `prompts/engine-system.md` | Core system prompt with command/trust/voice/first-run rules |
| `prompts/workflow-router.md` | Workflow transition rules |
| `references/command-registry.md` | 20 in-engine commands with types and implementations |
| `references/escalation-matrix.md` | Escalation chain (PM → Manager → VP → CEO) |
| `references/pm-lifecycle.md` | 15-stage lifecycle documentation |
| `references/rev-a-capabilities.md` | Rev A Manufacturing capability reference |
| `references/team-directory.md` | Team roster with roles and contacts |
| `bin/check-workflow-state.sh` | PreToolUse hook — validates workflow transitions |

## Architecture

```
User input
    |
    v
Command Router (/status, /help, etc.)
    |
    v (if not a command)
Intent Router (40 intents → 40 skills)
    |
    v
Trust Overlay (LEARN / ASSIST / OPERATE)
    +
Voice Profile (per-PM communication style)
    |
    v
Sub-skill execution (read SKILL.md, follow instructions)
    |
    v
Lifecycle Chain (suggest next step)
```

## Version

1.2.0
