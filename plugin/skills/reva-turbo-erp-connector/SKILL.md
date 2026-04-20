---
name: reva-turbo-erp-connector
preamble-tier: 2
version: 1.0.0
description: |
  Connect REVA-TURBO to ERP and inventory systems for capacity data, material
  availability, and cost information. Built flexible to support multiple
  ERP backends (SAP, NetSuite, QuickBooks, custom). Reads manufacturing
  capacity, inventory levels, and cost data to inform PM decisions.
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
mkdir -p ~/.reva-turbo/analytics
echo '{"skill":"reva-turbo-erp-connector","ts":"'$(date -u +%Y-%m-%dT%H:%M:%SZ)'"}' >> ~/.reva-turbo/analytics/skill-usage.jsonl 2>/dev/null || true
```

## Purpose

Connect REVA-TURBO to ERP and inventory management systems. Pull capacity data, material availability, cost breakdowns, and production schedules to support PM decision-making. The connector is designed to be flexible — it can work with local CSV/JSON data files, API connections, or manual data entry depending on what ERP system Rev A Manufacturing uses.

## Flow

### Step 1: ERP Configuration Check

```bash
cat ~/.reva-turbo/config/erp-config.json 2>/dev/null || echo '{"erp_type":"none"}'
```

Supported configurations:

| ERP Type | Integration Method |
|----------|-------------------|
| `none` | Manual data entry, local files |
| `csv` | Import from CSV exports |
| `json` | Import from JSON data files |
| `api` | Direct API connection (SAP, NetSuite, etc.) |
| `quickbooks` | QuickBooks API or exports |

If no ERP is configured:

> No ERP integration is configured. How do you provide capacity and cost data?
> A) I will enter data manually
> B) I have CSV/Excel exports to import
> C) I have JSON data files
> D) Configure API connection
> E) Skip — I do not need ERP data right now

### Step 2: Data Request

> What ERP data do you need?
> A) Manufacturing capacity (partner availability)
> B) Material availability
> C) Cost breakdown for a part/order
> D) Production schedule
> E) Inventory levels
> F) Import data from file

### Step 3: Data Retrieval

Reference `references/erp-integration-patterns.md` for integration approaches.

#### Manual Entry
Collect data from the PM directly using structured prompts.

#### CSV Import
```bash
# Look for CSV files in the import directory
ls ~/.reva-turbo/imports/*.csv 2>/dev/null
```

Parse CSV files into REVA-TURBO data structures.

#### API Connection
Use the configured API endpoint and credentials to query the ERP system.

### Step 4: Data Processing

Process retrieved data and make it available to other REVA-TURBO skills:

```bash
mkdir -p ~/.reva-turbo/erp-data
echo '{"ts":"'$(date -u +%Y-%m-%dT%H:%M:%SZ)'","type":"{{DATA_TYPE}}","source":"{{ERP_SOURCE}}","records":{{RECORD_COUNT}}}' >> ~/.reva-turbo/erp-data/erp-sync-log.jsonl
```

Save processed data:

```bash
# Capacity data
echo '{{CAPACITY_JSON}}' > ~/.reva-turbo/erp-data/capacity.json

# Cost data
echo '{{COST_JSON}}' > ~/.reva-turbo/erp-data/costs.json

# Inventory data
echo '{{INVENTORY_JSON}}' > ~/.reva-turbo/erp-data/inventory.json
```

### Step 5: Present to PM

Display the retrieved data in a clear format:

> **ERP Data Retrieved:**
>
> Type: {{DATA_TYPE}}
> Source: {{ERP_SOURCE}}
> Records: {{RECORD_COUNT}}
> Timestamp: {{TIMESTAMP}}
>
> {{DATA_SUMMARY}}
>
> A) Use this data in current workflow
> B) Export to a report
> C) Refresh / pull again
> D) Done

## Data Schemas

### Capacity Data
```json
{
  "partner": "Partner Name",
  "current_utilization_pct": 75,
  "available_capacity_units": 500,
  "lead_time_days": 21,
  "max_capacity_units": 2000,
  "constraints": ["material X on backorder", "one shift only"]
}
```

### Cost Data
```json
{
  "part_number": "REV-A-001",
  "material_cost": 12.50,
  "labor_cost": 8.00,
  "overhead_cost": 3.50,
  "tooling_cost": 0.75,
  "shipping_cost_est": 2.00,
  "total_unit_cost": 26.75,
  "margin_pct": 35,
  "quoted_price": 36.11
}
```

### Inventory Data
```json
{
  "part_number": "REV-A-001",
  "description": "Widget Assembly",
  "on_hand": 150,
  "on_order": 500,
  "allocated": 100,
  "available": 50,
  "reorder_point": 25,
  "location": "Rev A Warehouse"
}
```

## Rules

1. **Data freshness.** Always show when data was last synced. Stale data (>24 hours for API, >1 week for CSV) should be flagged.
2. **No direct ERP writes.** REVA-TURBO reads from ERP. Writes go through CRM or are manual.
3. **Flexible backend.** The skill must work even with no ERP — manual data entry is always an option.
4. **Cost confidentiality.** Cost breakdowns are internal. Never include them in customer-facing reports.
5. **Capacity is directional.** Capacity data helps inform lead time estimates but is not a commitment.

## Template References

- `references/erp-integration-patterns.md` — Integration approaches for various ERP systems
