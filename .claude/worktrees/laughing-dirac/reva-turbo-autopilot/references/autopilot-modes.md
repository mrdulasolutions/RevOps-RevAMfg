# Autopilot Modes

Three operating modes control how aggressively autopilot advances the lifecycle.

## FULL AUTO

**For experienced PMs managing high-volume, routine orders.**

- All auto-eligible transitions fire immediately without PM confirmation.
- The PM receives a summary digest after each chain completes or pauses.
- Pause points still fire (these are non-negotiable safety gates).
- Best for: repeat orders from established customers with trusted partners.
- Risk: lowest PM visibility into routine transitions. The PM trusts the system.

Behavior:
1. Skill completes.
2. Autopilot reads transition rules.
3. If AUTO and conditions met: execute next skill immediately.
4. Chain continues until a PAUSE point or the lifecycle ends.
5. PM receives a batch summary: "Autopilot completed steps X, Y, Z. Paused at W."

Configuration:
```json
{
  "mode": "full_auto",
  "notify_on_auto": false,
  "notify_on_pause": true,
  "notify_on_complete": true,
  "cancel_window_minutes": 0,
  "digest_frequency": "per_chain"
}
```

## SEMI AUTO

**For PMs who want speed but want to stay in the loop. Recommended default for experienced users.**

- Auto-eligible transitions fire, but the PM receives a notification before each one.
- The PM has a 5-minute cancel window to stop the transition.
- If no cancel within 5 minutes, the transition proceeds.
- Pause points still fire immediately (no 5-minute window — they always stop).
- Best for: orders with moderate complexity, newer partner relationships, or PMs building trust in autopilot.

Behavior:
1. Skill completes.
2. Autopilot reads transition rules.
3. If AUTO and conditions met: notify PM with "About to auto-advance from X to Y. Cancel within 5 minutes if needed."
4. Wait 5 minutes.
5. If PM cancels: pause and wait for manual instruction.
6. If no cancel: execute next skill.
7. Repeat for each transition in the chain.

Configuration:
```json
{
  "mode": "semi_auto",
  "notify_on_auto": true,
  "notify_on_pause": true,
  "notify_on_complete": true,
  "cancel_window_minutes": 5,
  "digest_frequency": "per_transition"
}
```

## MANUAL

**Traditional REVA-TURBO behavior. Default for new users and new entities.**

- No auto-transitions. Every skill completion suggests the next step but waits for PM confirmation.
- This is how REVA-TURBO works without autopilot.
- PMs can upgrade to SEMI AUTO or FULL AUTO at any time.
- Best for: first-time orders, complex/custom orders, sensitive customers, new PMs learning the system.

Behavior:
1. Skill completes.
2. REVA-TURBO suggests the next step: "Next recommended: [skill]. Want me to run it?"
3. PM confirms or chooses a different path.

Configuration:
```json
{
  "mode": "manual",
  "notify_on_auto": false,
  "notify_on_pause": false,
  "notify_on_complete": false,
  "cancel_window_minutes": null,
  "digest_frequency": null
}
```

## Mode Switching

PMs can switch modes at any time:

| From | To | Effect |
|------|----|--------|
| MANUAL | SEMI AUTO | Next auto-eligible transition will fire with cancel window |
| MANUAL | FULL AUTO | Next auto-eligible transition will fire immediately |
| SEMI AUTO | FULL AUTO | Cancel window removed, auto-transitions fire immediately |
| SEMI AUTO | MANUAL | Auto-transitions stop, PM confirms each step |
| FULL AUTO | SEMI AUTO | Cancel window added to future auto-transitions |
| FULL AUTO | MANUAL | Auto-transitions stop, PM confirms each step |

Mode switches take effect immediately and apply to the current entity only. Other entities keep their existing mode.

## Mode Recommendations by Scenario

| Scenario | Recommended Mode | Rationale |
|----------|-----------------|-----------|
| Repeat order, established customer, trusted partner | FULL AUTO | Routine — let the engine run |
| New order, returning customer | SEMI AUTO | Mostly routine but worth monitoring |
| First order from new customer | MANUAL | Needs PM attention at every step |
| Complex/custom part | SEMI AUTO | Partner may need extra guidance |
| High-value order (>$50K) | SEMI AUTO | Financial significance warrants visibility |
| Rush order | FULL AUTO | Speed is critical — let autopilot fly |
| Order with known partner quality issues | MANUAL | PM needs tight control |
| PM training/onboarding | MANUAL | New PM should see every step |

## Per-Entity Configuration

Autopilot mode is set per entity (RFQ or order), not globally. A PM can have:
- Order A on FULL AUTO (routine reorder)
- Order B on SEMI AUTO (new part type)
- Order C on MANUAL (complex custom order)

All three run simultaneously with their own mode, transition history, and pause points.
