# Trust Level Progression

Guidelines for when to suggest trust level promotions and demotions. The PM always has final say -- the engine suggests, never forces.

## Progression Timeline

The recommended progression for a new PM:

```
Week 1-2:   Level 1 LEARN    -- Learning the workflow, understanding each step
Week 3-6:   Level 2 ASSIST   -- Comfortable with workflow, reviewing drafts
Week 7+:    Level 3 OPERATE  -- Experienced, trusting autonomous operation
```

This is a guideline, not a rule. Some PMs will progress faster, others will prefer to stay at Level 1 or 2 permanently. The engine adapts to the PM, not the other way around.

## Promotion Criteria

### Level 1 -> Level 2 Promotion

The engine may suggest promotion when ALL of the following are true:

| Criterion | Threshold | How Measured |
|---|---|---|
| Time at Level 1 | >= 2 weeks | Calendar time since trust level set |
| Successful operations | >= 20 completed actions | Count from trust-audit.jsonl |
| Override rate | < 15% | PM changed engine suggestion / total suggestions |
| Error rate | < 5% | Actions that required correction / total actions |
| PM skipping explanations | > 50% of the time | PM says "skip", "proceed", "just do it" frequently |

**Suggestion format:**

> You have been at Level 1 (LEARN) for 3 weeks and have completed 35 actions with a 95% acceptance rate. You seem comfortable with the workflow.
>
> Would you like to move to **Level 2 (ASSIST)**? I will still show you everything, but I will pre-fill forms and batch routine confirmations to save you time.
>
> You can always switch back to Level 1 at any time.

### Level 2 -> Level 3 Promotion

The engine may suggest promotion when ALL of the following are true:

| Criterion | Threshold | How Measured |
|---|---|---|
| Time at Level 2 | >= 4 weeks | Calendar time since trust level set |
| Successful operations | >= 50 completed actions | Count from trust-audit.jsonl |
| Approval rate | >= 90% | PM approved without changes / total drafts presented |
| Override rate | < 10% | PM changed pre-filled value / total pre-filled values |
| Error rate | < 3% | Actions that required correction / total actions |
| Routine task volume | >= 10/week | Enough volume to benefit from automation |

**Suggestion format:**

> You have completed 75 actions at Level 2 with a 94% approval rate. Your override rate is only 6%, meaning my drafts are almost always what you want.
>
> Ready to try **Level 3 (OPERATE)** for routine tasks? I will handle the day-to-day autonomously and only alert you on exceptions. You will get a daily summary of everything I did.
>
> Options:
> A) Move to Level 3 for everything
> B) Move to Level 3 for specific skills only (I will suggest which ones)
> C) Stay at Level 2 for now
> D) Do not ask me again (I will not suggest promotion unless you ask)

### Partial Promotion (Per-Skill)

The engine can suggest promoting specific skills based on skill-specific metrics:

> Your RFQ intake approval rate is 98% over 40 RFQs. Want to move just RFQ intake to Level 3? Other skills stay at Level 2.

This creates a per-skill override rather than changing the system level.

## Demotion Criteria

### Automatic Demotion Suggestion

The engine may suggest demotion when any of the following are true:

| Criterion | Threshold | Suggested Action |
|---|---|---|
| Override rate increases | > 30% over 2-week window | Suggest demotion by 1 level |
| Error rate increases | > 10% over 2-week window | Suggest demotion by 1 level |
| PM requests more detail | 3+ times in a session | Offer to switch to lower level |
| New skill category | PM uses a skill for the first time | Suggest Level 1 for that skill |
| New customer | First order from unknown customer | Suggest Level 1 override for that entity |
| New partner | First order to unknown partner | Suggest Level 1 override for that entity |

**Suggestion format:**

> I have noticed you are overriding my pre-filled values more often lately (35% over the last 2 weeks, up from 6%). This might mean:
>
> A) Your requirements have changed -- want to update my defaults?
> B) You would prefer more control -- want to switch to Level 1 for a while?
> C) It is just a temporary thing -- keep Level 2

### PM-Initiated Demotion

The PM can always demote instantly without meeting any criteria:

- "Switch to Level 1" -- immediate, no questions
- "I want more detail" -- offer Level 1 or just increase verbosity for this session
- "Slow down" -- switch to lower level or add confirmation points

### Automatic Per-Skill Demotion

When a PM uses a skill category for the first time, the engine should suggest Level 1 for that skill:

> This is your first time using the export compliance skill. I recommend Level 1 (LEARN) for this skill so I can walk you through the compliance workflow. Your other skills will stay at Level 2.

## Progression Tracking

Track progression metrics in `~/.pmlord/analytics/trust-progression.jsonl`:

```json
{
  "ts": "2026-03-30T00:00:00Z",
  "level": 2,
  "days_at_level": 14,
  "total_actions": 42,
  "approval_rate": 0.93,
  "override_rate": 0.07,
  "error_rate": 0.02,
  "promotion_eligible": false,
  "promotion_criteria_met": ["time", "actions", "error_rate"],
  "promotion_criteria_missing": ["approval_rate"]
}
```

Recalculate daily and append to the log.

## Promotion Frequency

- Only suggest promotion once per criterion milestone
- If PM declines, do not suggest again for at least 2 weeks
- If PM says "do not ask again," suppress all promotion suggestions until PM explicitly asks
- Track suggestion history to avoid repetition:

```json
{
  "ts": "2026-03-30T10:00:00Z",
  "suggestion": "promote_2_to_3",
  "scope": "system",
  "response": "declined",
  "suppress_until": "2026-04-13T10:00:00Z"
}
```

## Edge Cases

### PM Who Wants Level 3 Immediately

Allow it without friction. Some PMs are experienced and know what they want. The assessment questionnaire may recommend Level 3 on first run. If the PM explicitly asks for Level 3, set it immediately.

### PM Who Stays at Level 1 Permanently

Respect this choice. Some PMs prefer full visibility and control. Never make them feel like they "should" move up. Level 1 is a valid long-term choice.

### Mixed Skill Levels

A PM might want Level 3 for RFQ intake (routine, high volume) but Level 1 for export compliance (complex, safety-critical). This is the ideal use case for per-skill overrides and should be encouraged.

### Team With Multiple PMs

Each PM has their own trust level stored at `~/.pmlord/users/<pm-slug>/trust-level.json`. A senior PM might be at Level 3 while a new PM is at Level 1. The engine adjusts behavior based on who is using it.
