---
name: pmlord-templates
preamble-tier: 2
version: 1.0.0
description: |
  Central template management for the PMLORD engine. Maintains an inventory
  of all templates across all skills, supports versioning, and provides
  template lookup and usage guidance.
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
echo '{"skill":"pmlord-templates","ts":"'$(date -u +%Y-%m-%dT%H:%M:%SZ)'"}' >> ~/.pmlord/analytics/skill-usage.jsonl 2>/dev/null || true
```

## Purpose

Serve as the central registry for all PMLORD templates. Every template used across every skill is cataloged here with its location, version, purpose, and key variables. This skill helps PMs find the right template and ensures consistency across the engine.

## Flow

### Step 1: Template Action

> What do you need?
> A) Find a template (search by name or purpose)
> B) List all templates
> C) View a specific template
> D) Check template versions
> E) Suggest a template for my task

### Step 2: Template Lookup

Reference `references/template-inventory.md` for the complete catalog. Search by:

1. **Skill name** — All templates for a specific skill
2. **Template type** — Reports, work orders, checklists, communications
3. **Keyword** — Search template names and descriptions

### Step 3: Template Delivery

When a PM requests a template:

1. Read the template file from the source skill directory
2. Present the template with its `{{PLACEHOLDER}}` variables listed
3. Offer to fill the template with provided data

### Step 4: Version Tracking

All templates are versioned via the parent skill's version number. Log template usage:

```bash
echo '{"ts":"'$(date -u +%Y-%m-%dT%H:%M:%SZ)'","template":"{{TEMPLATE_NAME}}","skill":"{{SOURCE_SKILL}}","pm":"{{PM_NAME}}"}' >> ~/.pmlord/state/template-usage.jsonl 2>/dev/null || true
```

## Rules

1. **Single source of truth.** Templates live in their parent skill's `templates/` directory. This skill only provides the index.
2. **No orphan templates.** Every template must belong to a skill.
3. **Consistent naming.** Template files use Title Case with spaces: `Order Status Report.md`
4. **All templates use {{PLACEHOLDER}} variables.** No hardcoded values.
5. **Report naming convention.** All generated reports follow: `PMLORD-{Type}-{YYYY-MM-DD}-{ShortName}.md` or `.docx`

## Template References

- `references/template-inventory.md` — Complete catalog of all templates across all skills
