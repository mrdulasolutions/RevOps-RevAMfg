# reva-turbo-autopilot

Invisible workflow transitions for the REVA-TURBO engine. The skill that makes REVA-TURBO feel alive.

## What It Does

When one skill or milestone completes, autopilot automatically evaluates transition rules and chains into the next lifecycle step without PM intervention — unless the transition requires human judgment. The PM sets the mode, and the engine drives the lifecycle forward.

1. PM activates autopilot for an RFQ or order (full auto, semi-auto, or manual)
2. Transition rules define which steps are automatic vs. require confirmation
3. Auto-eligible transitions fire with full data carryover (no re-entry)
4. Pause points stop the chain at quality gates, customer comms, escalations, and financial decisions
5. PM gets a summary of everything that ran automatically and what needs their attention
6. PM can pause, resume, override, or disable autopilot at any time
7. Every transition is audit-logged with an autopilot flag for compliance

## Three Modes

| Mode | Behavior |
|------|----------|
| **FULL AUTO** | Auto-eligible transitions fire immediately. PM gets summary digest. |
| **SEMI AUTO** | Transitions fire with 5-minute cancel window. PM notified before each. |
| **MANUAL** | Traditional mode. No auto-transitions. Default for new users. |

## Usage

```
/reva-turbo-autopilot
```

Or enable autopilot during any skill run by saying "enable autopilot."

## Inputs

- Entity ID (RFQ or order)
- Autopilot mode selection
- PM confirmation at pause points

## Outputs

- Autopilot configuration saved to `~/.reva-turbo/state/autopilot-config.jsonl`
- Auto-transition log entries in `~/.reva-turbo/state/workflow-state.jsonl`
- Data carryover log in `~/.reva-turbo/state/carryover-log.jsonl`
- Override log in `~/.reva-turbo/state/autopilot-overrides.jsonl`

## Files

| File | Purpose |
|------|---------|
| `SKILL.md` | Skill instructions and flow |
| `skill.yaml` | Skill manifest |
| `prompts/autopilot-system.md` | System prompt with safety rules |
| `references/transition-rules.md` | Complete transition matrix |
| `references/autopilot-modes.md` | Mode descriptions and behaviors |
| `bin/autopilot-check.sh` | Hook script for transition evaluation |

## Safety

Autopilot NEVER auto-sends customer communications, auto-approves quality gates, auto-escalates without PM knowledge, or auto-disposes NCRs. These pause points are non-negotiable in all modes.
