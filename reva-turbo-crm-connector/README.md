# reva-turbo-crm-connector

CRM integration skill for the REVA-TURBO engine.

## What It Does

Provides bidirectional sync between REVA-TURBO and CRM systems:

1. Look up customers, contacts, and orders in CRM
2. Create and update CRM records from REVA-TURBO data
3. Pull CRM data into REVA-TURBO for processing
4. Map REVA-TURBO fields to CRM entities

## Supported CRMs

- **Microsoft Dynamics 365 / Power Apps** — via Dataverse Web API
- **HubSpot** — via HubSpot MCP tools

## Usage

```
/reva-turbo-crm-connector
```

Or triggered by other REVA-TURBO skills when CRM operations are needed (e.g., reva-turbo-rfq-intake pushing a new lead).

## Files

| File | Purpose |
|------|---------|
| `SKILL.md` | Skill instructions and flow |
| `skill.yaml` | Skill manifest |
| `prompts/crm-mapping-system.md` | CRM mapping logic |
| `references/dynamics-field-mapping.md` | Dynamics 365 field mapping |
| `references/crm-api-patterns.md` | API patterns for Dynamics and HubSpot |

## Configuration

CRM type is stored in `~/.reva-turbo/config/crm-config.json`. Set to `dynamics365`, `hubspot`, or `none`.
