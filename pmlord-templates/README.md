# pmlord-templates

Central template management skill for the PMLORD engine.

## What It Does

Provides a centralized registry and lookup for all templates across every PMLORD skill:

1. Maintains a complete inventory of all templates
2. Supports search by skill, type, or keyword
3. Tracks template usage
4. Ensures consistency in template naming and variable conventions

## Usage

```
/pmlord-templates
```

Or ask PMLORD to find a template for a specific task.

## Files

| File | Purpose |
|------|---------|
| `SKILL.md` | Skill instructions and flow |
| `skill.yaml` | Skill manifest |
| `references/template-inventory.md` | Complete catalog of ALL templates across ALL skills |

## Template Conventions

- Templates live in their parent skill's `templates/` directory
- File names use Title Case: `Order Status Report.md`
- Variables use `{{DOUBLE_BRACES}}` format
- Reports follow naming: `PMLORD-{Type}-{YYYY-MM-DD}-{ShortName}.md`
