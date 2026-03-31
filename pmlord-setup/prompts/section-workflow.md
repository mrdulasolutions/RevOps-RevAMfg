# Section 2 of 7: Workflow Configuration

## Overview

Configure the PMLORD lifecycle pipeline — which stages are active, custom display names, quality gate thresholds, auto-advance rules, priority definitions, and SLA targets. This drives the entire order lifecycle engine.

## Questions

### Q1: Active Lifecycle Stages

Display all 15 stages with their default status (all active). Let the PM toggle stages on/off.

```
PMLORD Lifecycle Pipeline — 15 Stages
Enter stage numbers to toggle off, 'all' to activate all, 'done' when finished.

 1. [x] rfq-intake          — RFQ received and parsed
 2. [x] rfq-qualify          — Customer and project qualified
 3. [x] rfq-quote            — Quote prepared and sent to customer
 4. [x] customer-gate        — Customer approves quote and terms
 5. [x] china-package        — Technical package sent to mfg partners
 6. [x] partner-quote        — Partner quotes received and evaluated
 7. [x] order-confirm        — Order placed with manufacturing partner
 8. [x] production-track     — Production monitoring and updates
 9. [x] quality-gate         — Quality inspections (G1-G4)
10. [x] export-compliance    — Export/import compliance screening
11. [x] logistics            — Shipping coordination and tracking
12. [x] import-compliance    — US customs and import clearance
13. [x] delivery             — Customer delivery and confirmation
14. [x] invoice              — Invoicing and payment tracking
15. [x] closeout             — Project closeout and archive
```

PM enters numbers to toggle (e.g., "10,12" to deactivate export and import compliance). Re-display after each toggle. Type "done" to confirm.

**Minimum requirement:** At least rfq-intake, rfq-quote, and delivery must remain active.

### Q2: Custom Stage Display Names

For each active stage, offer to rename:

> Would you like to customize any stage display names?
> A) Use defaults for all
> B) Customize — I'll show each stage one by one

If B, for each active stage:
> Stage: [internal-name] — Current display: "[default name]"
> New display name (Enter to keep current):

Example customizations:
- "china-package" -> "Send to Shenzhen"
- "partner-quote" -> "Factory Pricing"
- "production-track" -> "Production Watch"

### Q3: Quality Gate Thresholds (G1-G4)

> Quality Gates control when production can proceed. Set minimum pass percentages:
>
> G1 — Drawing Review (drawings match specs before tooling):
>   Default: 100% | Enter new value or press Enter for default:
>
> G2 — First Article Inspection (first production sample meets spec):
>   Default: 95% | Enter new value or press Enter for default:
>
> G3 — Production Sample (mid-production quality check):
>   Default: 98% | Enter new value or press Enter for default:
>
> G4 — Final Inspection (pre-ship quality verification):
>   Default: 99% | Enter new value or press Enter for default:

Validation: Must be a number between 0 and 100. Warn if set below 90% ("This is below typical manufacturing standards. Are you sure?").

### Q4: Auto-Advance Settings

> Some stages can auto-advance to the next stage without PM approval.
> Recommended manual stages are marked with (*).
>
> For each active stage, should it auto-advance when complete?

Display each active stage:
```
 1. rfq-intake       → Auto-advance? (Y/N) [default: Y]
 2. rfq-qualify       → Auto-advance? (Y/N) [default: Y]
 3. rfq-quote         → Auto-advance? (Y/N) [default: N]
 4. customer-gate (*)  → Auto-advance? (Y/N) [default: N]
 5. china-package     → Auto-advance? (Y/N) [default: Y]
 ...
 9. quality-gate (*)  → Auto-advance? (Y/N) [default: N]
10. export-compliance (*) → Auto-advance? (Y/N) [default: N]
...
```

Stages marked (*) are recommended manual. Warn if the PM enables auto-advance for these:
> "Auto-advancing [stage] without PM review could introduce risk. Confirm? (Y/N)"

### Q5: Default Priority Levels

> PMLORD uses 4 priority levels. Confirm or customize response time expectations:
>
> A) Critical — Same-day response required
> B) High — 24-hour response
> C) Medium — 48-hour response (default for new projects)
> D) Low — 1-week response
>
> Accept these defaults? (Y to accept, or enter custom response times)

If custom, collect response time for each level.

### Q6: SLA Definitions — Target Days Per Stage

> Set target completion days for each active stage.
> These drive the dashboard alerts and escalation timers.

Display as a table with defaults:

```
Stage                Default (days)    Your target:
─────────────────    ──────────────    ────────────
rfq-intake                 1          [Enter or keep]
rfq-qualify                2
rfq-quote                  3
customer-gate              5
china-package              2
partner-quote              5
order-confirm              2
production-track          30
quality-gate               5
export-compliance          3
logistics                 14
import-compliance          5
delivery                   3
invoice                    5
closeout                   7
```

PM can enter "defaults" to accept all, or enter values one by one.

## Summary Display

```
┌─────────────────────────────────────────────────────┐
│  WORKFLOW CONFIGURATION SUMMARY                     │
├─────────────────────────────────────────────────────┤
│  Active Stages:  [N] of 15                          │
│  Custom Names:   [N] customized                     │
│  Quality Gates:  G1=[x]% G2=[x]% G3=[x]% G4=[x]%   │
│  Auto-Advance:   [N] stages on auto                 │
│  Default Priority: [level]                          │
│  Total Pipeline SLA: [sum] days                     │
└─────────────────────────────────────────────────────┘
```

Then confirm: A) Save, B) Edit, C) Start over.

## Output

Write to `~/.pmlord/config/workflow-config.yaml` using `templates/workflow-config.yaml.tmpl`.
