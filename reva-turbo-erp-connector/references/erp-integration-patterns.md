# ERP Integration Patterns

## Pattern 1: No ERP (Manual Entry)

For companies without an ERP system or in the early stages of adoption.

### How It Works
- PM enters data manually when prompted by REVA-TURBO skills
- Data is stored in REVA-TURBO state files as JSON
- PM updates data periodically or when it changes

### Data Collection Prompts

**Capacity:**
```
What is the current capacity for {{PARTNER_NAME}}?
- Current utilization: ___%
- Available units: ___
- Lead time: ___ days
- Any constraints? ___
```

**Cost:**
```
What is the cost breakdown for {{PART_NUMBER}}?
- Material cost per unit: $___
- Labor cost per unit: $___
- Overhead per unit: $___
- Tooling/setup: $___
- Target margin: ___%
```

**Inventory:**
```
What is the inventory level for {{PART_NUMBER}}?
- On hand: ___
- On order: ___
- Allocated: ___
- Available: ___
```

### Pros/Cons
- (+) No integration required, works immediately
- (+) PM has full control over data accuracy
- (-) Manual data entry is time-consuming
- (-) Data may become stale

## Pattern 2: CSV/Excel Import

For companies that export data from their systems into spreadsheets.

### How It Works
1. PM exports data from their system (QuickBooks, Excel, custom tool)
2. Saves the export to `~/.reva-turbo/imports/`
3. REVA-TURBO parses the CSV and loads the data

### Expected CSV Formats

**Capacity CSV:**
```csv
partner,utilization_pct,available_units,lead_time_days,max_capacity,constraints
"Shenzhen MFG Co",75,500,21,2000,"material X backorder"
"Guangzhou Parts Ltd",60,800,14,2000,""
```

**Cost CSV:**
```csv
part_number,description,material_cost,labor_cost,overhead_cost,tooling_cost,total_cost,margin_pct
"REV-A-001","Widget Assembly",12.50,8.00,3.50,0.75,26.75,35
```

**Inventory CSV:**
```csv
part_number,description,on_hand,on_order,allocated,available,reorder_point,location
"REV-A-001","Widget Assembly",150,500,100,50,25,"Rev A Warehouse"
```

### Import Process
1. Detect CSV file in import directory
2. Parse headers and validate format
3. Convert to REVA-TURBO JSON data structures
4. Present summary to PM for confirmation
5. Save to `~/.reva-turbo/erp-data/`

### Pros/Cons
- (+) Bulk data import, more efficient than manual
- (+) Works with any system that can export CSV
- (-) Data is only as fresh as the last export
- (-) Requires consistent export formatting

## Pattern 3: JSON Data Files

For custom systems or tools that output JSON.

### How It Works
1. External system or script generates JSON data files
2. Files are placed in `~/.reva-turbo/imports/` or `~/.reva-turbo/erp-data/`
3. REVA-TURBO reads and uses the data directly

### Expected JSON Format
See the data schemas in SKILL.md for capacity, cost, and inventory JSON structures.

### Pros/Cons
- (+) Flexible, works with any system
- (+) JSON is native to REVA-TURBO
- (-) Requires custom export script

## Pattern 4: Direct API Connection

For companies with ERP systems that expose APIs.

### SAP Business One

**API Base:** `https://{server}:50000/b1s/v1`
**Authentication:** Session-based (POST /Login)

| Data Type | Endpoint |
|-----------|----------|
| Items/Inventory | `GET /Items` |
| Production Orders | `GET /ProductionOrders` |
| Purchase Orders | `GET /PurchaseOrders` |
| Business Partners | `GET /BusinessPartners` |

### NetSuite (SuiteTalk)

**API:** RESTlet or SuiteTalk SOAP
**Authentication:** Token-Based Authentication (TBA)

| Data Type | Record Type |
|-----------|------------|
| Items | `inventoryItem`, `assemblyItem` |
| Production | `workOrder` |
| Purchase Orders | `purchaseOrder` |
| Vendors | `vendor` |

### QuickBooks Online

**API Base:** `https://quickbooks.api.intuit.com/v3/company/{companyId}`
**Authentication:** OAuth 2.0

| Data Type | Endpoint |
|-----------|----------|
| Items | `GET /query?query=SELECT * FROM Item` |
| Purchase Orders | `GET /query?query=SELECT * FROM PurchaseOrder` |
| Vendors | `GET /query?query=SELECT * FROM Vendor` |
| Invoices | `GET /query?query=SELECT * FROM Invoice` |

### Configuration File Format

```json
{
  "erp_type": "api",
  "api_base_url": "https://erp.example.com/api",
  "auth_type": "oauth2",
  "client_id": "stored_in_keychain",
  "token_endpoint": "https://erp.example.com/oauth/token",
  "endpoints": {
    "capacity": "/manufacturing/capacity",
    "inventory": "/inventory/levels",
    "costs": "/accounting/costs",
    "production": "/manufacturing/orders"
  },
  "refresh_interval_minutes": 60
}
```

### Pros/Cons
- (+) Real-time data, most accurate
- (+) Automated, no manual intervention
- (-) Requires API access and configuration
- (-) Depends on ERP vendor API availability

## Data Freshness Guidelines

| Source | Acceptable Freshness | Warning Threshold | Stale Threshold |
|--------|---------------------|-------------------|-----------------|
| API | Real-time | > 1 hour | > 4 hours |
| JSON import | Same day | > 1 day | > 3 days |
| CSV import | Same week | > 3 days | > 7 days |
| Manual entry | When entered | > 1 week | > 2 weeks |

## Data Caching

All retrieved ERP data is cached locally at `~/.reva-turbo/erp-data/` with timestamps. This ensures REVA-TURBO can function even when the ERP system is unavailable.

Cache files:
- `capacity.json` — Partner capacity data
- `costs.json` — Part cost breakdowns
- `inventory.json` — Inventory levels
- `production.json` — Production schedules
- `erp-sync-log.jsonl` — Sync history
