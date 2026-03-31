# CRM API Patterns

## HubSpot Integration

### Authentication
- API key or OAuth 2.0 (private app access token preferred)
- Base URL: `https://api.hubapi.com`

### HubSpot MCP Tools

REVA-TURBO uses HubSpot MCP tools for direct integration:

| Operation | MCP Tool | Parameters |
|-----------|----------|-----------|
| Search companies | `search_crm_objects` | object_type: "companies", query: search term |
| Search contacts | `search_crm_objects` | object_type: "contacts", query: search term |
| Search deals | `search_crm_objects` | object_type: "deals", query: search term |
| Get company | `get_crm_objects` | object_type: "companies", object_id: ID |
| Get contact | `get_crm_objects` | object_type: "contacts", object_id: ID |
| Get deal | `get_crm_objects` | object_type: "deals", object_id: ID |
| Create/Update | `manage_crm_objects` | operation, object_type, properties |
| Get properties | `get_properties` | object_type |
| Search properties | `search_properties` | object_type, query |

### HubSpot Field Mapping

| REVA-TURBO Field | HubSpot Property | Object Type |
|-------------|-----------------|-------------|
| Customer Company | `name` | Company |
| Customer Domain | `domain` | Company |
| Customer Industry | `industry` | Company |
| Contact First Name | `firstname` | Contact |
| Contact Last Name | `lastname` | Contact |
| Contact Email | `email` | Contact |
| Contact Phone | `phone` | Contact |
| RFQ / Order | Deal Name | Deal |
| Order Value | `amount` | Deal |
| Stage | `dealstage` | Deal |
| Close Date | `closedate` | Deal |
| Pipeline | `pipeline` | Deal |
| Assigned PM | `hubspot_owner_id` | Deal |

### HubSpot Custom Properties

Create these custom properties in HubSpot for REVA-TURBO integration:

| Property | Internal Name | Object | Type | Description |
|----------|-------------|--------|------|-------------|
| PO Number | `reva-turbo_po_number` | Deal | Single-line text | Rev A PO number |
| REVA-TURBO Stage | `reva-turbo_stage` | Deal | Single-line text | Order stage (01-12) |
| Routing Type | `reva-turbo_routing` | Deal | Dropdown | direct-to-customer / inspect-and-forward |
| Mfg Partner | `reva-turbo_mfg_partner` | Deal | Single-line text | China partner name |
| Delivery Date | `reva-turbo_delivery_date` | Deal | Date | Promised delivery date |
| Partner Score | `reva-turbo_partner_score` | Company | Single-line text | Partner grade (vendor companies) |
| Last Sync | `reva-turbo_last_sync` | All | Date/time | Last REVA-TURBO sync timestamp |

### HubSpot Pipeline Stages

Map REVA-TURBO order stages to HubSpot deal pipeline stages:

| REVA-TURBO Stage | HubSpot Stage | Stage ID |
|-------------|--------------|----------|
| RFQ Intake | Qualification | `qualifiedtobuy` |
| RFQ Qualify | Needs Analysis | Custom |
| RFQ Quote | Proposal Made | `presentationscheduled` |
| Quote Sent | Contract Sent | `contractsent` |
| PO Received | Closed Won | `closedwon` |
| Manufacturing | Custom: Manufacturing | Custom |
| Shipped | Custom: Shipped | Custom |
| Delivered | Custom: Delivered | Custom |
| Closed | Custom: Closed | Custom |

## Dynamics 365 Integration

### Dataverse Web API

For Dynamics 365, REVA-TURBO uses the Dataverse Web API. See `dynamics-field-mapping.md` for field details.

### Common API Patterns

#### Search for a Record
```http
GET {org_url}/api/data/v9.2/{entity_set}?$filter=contains(name,'{search}')&$select=name,accountid&$top=10
```

#### Get a Record by ID
```http
GET {org_url}/api/data/v9.2/{entity_set}({record_id})?$select=field1,field2
```

#### Create a Record
```http
POST {org_url}/api/data/v9.2/{entity_set}
Content-Type: application/json
{"field1":"value1","field2":"value2"}
```

#### Update a Record
```http
PATCH {org_url}/api/data/v9.2/{entity_set}({record_id})
Content-Type: application/json
{"field1":"new_value"}
```

#### Associate Records
```http
POST {org_url}/api/data/v9.2/{entity_set}({id1})/{relationship}/$ref
Content-Type: application/json
{"@odata.id":"{org_url}/api/data/v9.2/{related_entity_set}({id2})"}
```

## Sync Patterns

### Full Sync
1. Pull all active records from CRM for the entity type
2. Compare with REVA-TURBO state files
3. Identify new, updated, and deleted records
4. Present sync plan to PM
5. Execute approved changes in both directions
6. Log sync completion

### Incremental Sync
1. Check last sync timestamp from `crm-sync-log.jsonl`
2. Pull only records modified since last sync
3. Compare and sync as above
4. More efficient for daily operations

### Event-Driven Sync
1. Triggered when a REVA-TURBO skill completes an action (e.g., stage transition)
2. Push the specific change to CRM immediately
3. Log the sync
4. Fastest for keeping CRM current

## Error Handling

| Error | Action |
|-------|--------|
| CRM unreachable | Log error, continue with local state, retry on next sync |
| Authentication expired | Prompt PM to re-authenticate |
| Duplicate record | Present both records to PM for merge decision |
| Field validation error | Log the specific field and value, skip that field, sync remainder |
| Rate limit hit | Wait and retry with exponential backoff |
