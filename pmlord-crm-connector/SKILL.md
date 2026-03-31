---
name: pmlord-crm-connector
preamble-tier: 2
version: 1.0.0
description: |
  Sync PMLORD data with CRM systems. Supports Microsoft Power Apps / Dynamics 365
  and HubSpot. Read and write customer, order, and RFQ data. Maps PMLORD fields
  to CRM entities for bidirectional synchronization.
compatibility: Claude Code, Claude desktop, Claude CoWork
allowed-tools:
  - Bash
  - Read
  - Write
  - Edit
  - Glob
  - Grep
  - AskUserQuestion
  - mcp__f1849d86-0209-4780-a242-dd60da75b679__get_crm_objects
  - mcp__f1849d86-0209-4780-a242-dd60da75b679__search_crm_objects
  - mcp__f1849d86-0209-4780-a242-dd60da75b679__manage_crm_objects
  - mcp__f1849d86-0209-4780-a242-dd60da75b679__get_properties
  - mcp__f1849d86-0209-4780-a242-dd60da75b679__search_properties
  - mcp__f1849d86-0209-4780-a242-dd60da75b679__get_user_details
  - mcp__f1849d86-0209-4780-a242-dd60da75b679__search_owners
---

## Preamble (run first)

```bash
mkdir -p ~/.pmlord/analytics
echo '{"skill":"pmlord-crm-connector","ts":"'$(date -u +%Y-%m-%dT%H:%M:%SZ)'"}' >> ~/.pmlord/analytics/skill-usage.jsonl 2>/dev/null || true
```

## Purpose

Provide bidirectional synchronization between PMLORD and CRM systems. Read customer data, order history, and contact information from CRM. Write back order status updates, RFQ outcomes, and interaction logs. Supports Microsoft Dynamics 365 / Power Apps and HubSpot.

## Flow

### Step 1: CRM Configuration Check

Determine which CRM is configured:

```bash
cat ~/.pmlord/config/crm-config.json 2>/dev/null || echo '{"crm_type":"none"}'
```

If no CRM is configured:

> No CRM integration is configured. Which CRM does Rev A Manufacturing use?
> A) Microsoft Dynamics 365 / Power Apps
> B) HubSpot
> C) None — use local PMLORD state files only

If configured, proceed with the configured CRM type.

### Step 2: CRM Action

> What CRM action do you need?
> A) Look up a customer / contact
> B) Look up an order / deal
> C) Create or update a customer record
> D) Create or update an order / deal
> E) Sync PMLORD data to CRM
> F) Pull CRM data into PMLORD
> G) Check sync status

### Step 3: Field Mapping

Reference `references/dynamics-field-mapping.md` for Dynamics 365 mappings or `references/crm-api-patterns.md` for HubSpot patterns.

#### HubSpot Operations

**Read Customer:**
```
Use mcp__f1849d86__search_crm_objects with object_type "contacts" or "companies"
```

**Read Deal/Order:**
```
Use mcp__f1849d86__search_crm_objects with object_type "deals"
```

**Write/Update:**
```
Use mcp__f1849d86__manage_crm_objects to create or update records
```

#### Dynamics 365 Operations

For Dynamics 365, use the API patterns documented in `references/crm-api-patterns.md`. Dynamics integration uses the Dataverse Web API.

### Step 4: Data Sync

When syncing PMLORD data to CRM:

1. Read current PMLORD state for the entity
2. Map PMLORD fields to CRM fields
3. Check for conflicts (CRM data newer than PMLORD data)
4. Present the sync plan to the PM

**HUMAN-IN-THE-LOOP CHECKPOINT:**

> **CRM Sync Plan:**
>
> Direction: {{SYNC_DIRECTION}} (PMLORD -> CRM / CRM -> PMLORD)
> Entity: {{ENTITY_TYPE}} ({{ENTITY_NAME}})
> Fields to update: {{FIELD_COUNT}}
>
> | Field | PMLORD Value | CRM Value | Action |
> |-------|-------------|-----------|--------|
> | {{FIELD_ROW_1}} |
> | {{FIELD_ROW_2}} |
>
> A) Apply sync
> B) Review field-by-field
> C) Cancel sync

### Step 5: Log Sync

```bash
echo '{"ts":"'$(date -u +%Y-%m-%dT%H:%M:%SZ)'","action":"crm_sync","direction":"{{DIRECTION}}","entity":"{{ENTITY_TYPE}}","name":"{{ENTITY_NAME}}","fields_updated":{{FIELD_COUNT}},"crm_type":"{{CRM_TYPE}}","pm":"{{PM_NAME}}"}' >> ~/.pmlord/state/crm-sync-log.jsonl
```

## Rules

1. **Never overwrite CRM data without PM confirmation.** Always show what will change.
2. **Conflict resolution is manual.** If PMLORD and CRM have different values, present both and let the PM decide.
3. **Customer data is sensitive.** Do not log full customer records. Log only sync metadata.
4. **Idempotent syncs.** Running sync twice should not create duplicates.
5. **Graceful degradation.** If CRM is unreachable, fall back to local PMLORD state files.

## Template References

- `prompts/crm-mapping-system.md` — System prompt for CRM mapping logic
- `references/dynamics-field-mapping.md` — Dynamics 365 field mapping
- `references/crm-api-patterns.md` — CRM API patterns for both Dynamics and HubSpot
