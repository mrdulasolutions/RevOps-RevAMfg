# pmlord-crm-connector

CRM integration skill for the PMLORD engine.

## What It Does

Provides bidirectional sync between PMLORD and CRM systems:

1. Look up customers, contacts, and orders in CRM
2. Create and update CRM records from PMLORD data
3. Pull CRM data into PMLORD for processing
4. Map PMLORD fields to CRM entities

## Supported CRMs

- **Microsoft Dynamics 365 / Power Apps** — via Dataverse Web API
- **HubSpot** — via HubSpot MCP tools

## Usage

```
/pmlord-crm-connector
```

Or triggered by other PMLORD skills when CRM operations are needed (e.g., pmlord-rfq-intake pushing a new lead).

## Files

| File | Purpose |
|------|---------|
| `SKILL.md` | Skill instructions and flow |
| `skill.yaml` | Skill manifest |
| `prompts/crm-mapping-system.md` | CRM mapping logic |
| `references/dynamics-field-mapping.md` | Dynamics 365 field mapping |
| `references/crm-api-patterns.md` | API patterns for Dynamics and HubSpot |

## Configuration

CRM type is stored in `~/.pmlord/config/crm-config.json`. Set to `dynamics365`, `hubspot`, or `none`.
