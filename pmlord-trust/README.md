# pmlord-trust

Progressive autonomy system for the PMLORD skills engine.

## Overview

Trust controls HOW every skill in the engine behaves. It is not a permission system -- it is a behavioral overlay that adjusts verbosity, autonomy, and confirmation requirements based on the PM's experience and preferences.

## The 3 Trust Levels

| Level | Name | Philosophy | Behavior |
|---|---|---|---|
| 1 | LEARN | "Let me show you how this works" | Explains every step, asks before each action, teaches as it goes |
| 2 | ASSIST | "I'll draft it, you verify" | Pre-fills and drafts, shows confidence scores, batches confirmations |
| 3 | OPERATE | "I'll handle the routine, you audit the exceptions" | Handles routine autonomously, alerts on exceptions only, terse output |

## Usage

### Set Trust Level

```
/pmlord-trust set 2
```

### Run Trust Assessment

```
/pmlord-trust assess
```

The engine will ask 4 questions about your experience and recommend a level.

### View History

```
/pmlord-trust history
```

### Set Overrides

Per-skill override:
```
/pmlord-trust override --skill pmlord-export-compliance --level 1
```

Per-entity override:
```
/pmlord-trust override --entity customer:acme-corp --level 1
```

## Override Specificity Chain

When multiple trust levels apply, the most specific one wins:

```
entity > skill > user > system
```

Example: System is Level 3, but export-compliance is overridden to Level 1. When running export compliance for customer Acme Corp (which has its own override to Level 2), the entity override wins and the engine operates at Level 2.

## Safety Caps

Some skills have maximum trust levels that cannot be overridden:

- **Export/import compliance**: Max Level 2 (never auto-approve)
- **Quality gates (final inspection)**: Max Level 2
- **Financial approvals above threshold**: Max Level 2

## State Files

All trust state is stored at `~/.pmlord/state/`:

- `trust-level.json` -- System-wide default
- `trust-overrides.jsonl` -- Per-skill and per-entity overrides
- `trust-history.jsonl` -- Audit log of all changes

Per-user overrides: `~/.pmlord/users/<pm-slug>/trust-level.json`

## Integration

Every PMLORD skill should call `bin/trust-check.sh` at startup to determine the effective trust level, then apply the behavioral overlay from the corresponding prompt file (`prompts/trust-learn.md`, `prompts/trust-assist.md`, or `prompts/trust-operate.md`).

## Interaction with Autopilot

Trust and autopilot are complementary but independent:

- **Trust** = how the engine communicates (verbose vs terse, confirm vs auto-execute)
- **Autopilot** = whether the engine chains to the next workflow stage automatically

They combine naturally: Level 3 + Full Auto = silent autonomous operation. Level 1 + Manual = patient teaching with full control.
