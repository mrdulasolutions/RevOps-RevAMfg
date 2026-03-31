# Section 7 of 7: CoWork Space Optimization

## Overview

Configure how REVA-TURBO organizes work within Claude CoWork spaces. This section helps the PM structure AI-assisted projects for maximum efficiency — separating customer work, internal operations, and active pipeline management.

This section does not create a separate config file. Settings are appended to `workflow-config.yaml` under a `cowork:` key.

## Questions

### Q1: CoWork Organization Explanation

Before asking questions, explain the concept:

> **Claude CoWork Project Organization for REVA-TURBO**
>
> CoWork lets you run multiple AI-assisted projects simultaneously. For a manufacturing
> PM workflow, we recommend organizing projects by function:
>
> 1. **Customer Projects** — One CoWork project per major customer. This keeps customer-specific
>    context (specs, history, communications) isolated and easy to find.
>
> 2. **Internal Ops** — A single project for dashboards, partner management, reporting,
>    and operational tasks that span multiple customers.
>
> 3. **Active RFQs** — A project for managing the current RFQ pipeline, separate from
>    ongoing customer relationships.
>
> This structure prevents context bleed between customers and keeps sensitive
> information properly compartmentalized.

Then ask:
> Does this structure work for your team?
> A) Yes, set up recommended structure
> B) I'd like a different structure — let me explain
> C) Skip CoWork configuration

### Q2: Auto-Create Starter Projects

If A or B from Q1:

> Would you like to auto-create starter CoWork project names?
> A) Yes, create the recommended set
> B) Yes, but let me customize the names
> C) No, I'll create projects manually

**If A (recommended set):**
Create project name suggestions:
- "REVA-TURBO -- Internal Ops"
- "REVA-TURBO -- Active RFQs"
- "REVA-TURBO -- Quality Dashboard"

Also, if team members were defined in Section 1, suggest:
> Based on your team, should we create customer-specific projects?
> (You can add customer names now or later)
>
> Enter customer names separated by commas, or press Enter to skip:
> Example: Acme Corp, TechWidget Inc, GlobalParts LLC

For each customer name, generate: "REVA-TURBO -- [Customer Name]"

**If B (custom names):**
Collect project names in a loop:
> Project name:
> Add another? (Y/N)

### Q3: Pin Key Skills to CoWork Sidebar

> REVA-TURBO recommends pinning these skills to your CoWork sidebar for quick access:
>
> 1. reva-turbo-engine (master orchestrator)
> 2. reva-turbo-dashboard (status overview)
> 3. reva-turbo-rfq-intake (new RFQ processing)
> 4. reva-turbo-pulse (alerts and notifications)
> 5. reva-turbo-quick (quick actions)
>
> A) Pin all recommended skills
> B) Let me choose which to pin
> C) Don't pin any — I'll do it manually

If B, show checkboxes for each skill and let PM select.

### Q4: Notification Preferences for CoWork

> How should REVA-TURBO handle notifications in CoWork?
>
> **Escalation alerts** (SLA breaches, blocked orders):
> A) Immediate — notify as soon as triggered
> B) Batched hourly — collect and send once per hour
> C) Daily digest — include in daily summary
>
> **Order status changes** (stage transitions, partner updates):
> A) Immediate
> B) Batched hourly
> C) Daily digest
> D) Off — I'll check the dashboard manually
>
> **Quality gate results** (inspection pass/fail):
> A) Immediate — critical for production flow
> B) Batched hourly
> C) Daily digest

### Q5: Project Isolation Rules

> How strictly should customer projects be isolated?
> A) Strict — Never share customer data between CoWork projects
> B) Standard — Allow cross-referencing for reporting, but keep specs isolated
> C) Open — All projects can access shared data (smallest teams only)

Recommend A for companies with NDA obligations.

## Summary Display

```
┌─────────────────────────────────────────────────────┐
│  COWORK SPACE CONFIGURATION                         │
├──────────────────┬──────────────────────────────────┤
│  Structure       │  [Recommended / Custom]          │
│  Projects        │  [N] projects created            │
│  Pinned Skills   │  [list or "None"]                │
│  Escalation      │  [Immediate/Batched/Daily]       │
│  Order Updates   │  [Immediate/Batched/Daily/Off]   │
│  Quality Gates   │  [Immediate/Batched/Daily]       │
│  Isolation       │  [Strict/Standard/Open]          │
├──────────────────┴──────────────────────────────────┤
│  PROJECTS:                                          │
│  - REVA-TURBO -- Internal Ops                           │
│  - REVA-TURBO -- Active RFQs                            │
│  - REVA-TURBO -- [Customer 1]                           │
│  - REVA-TURBO -- [Customer 2]                           │
└─────────────────────────────────────────────────────┘
```

Confirm: A) Save, B) Edit, C) Start over.

## Output

Update `~/.reva-turbo/config/workflow-config.yaml` — append or merge a `cowork:` section with the CoWork settings. Do not overwrite the workflow stages/gates/SLAs configured in Section 2.
