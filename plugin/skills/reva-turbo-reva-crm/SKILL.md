---
name: reva-turbo-reva-crm
preamble-tier: 1
version: 1.0.0
description: |
  Primary CRM skill for REVA-TURBO on Rev A Manufacturing. Speaks to the
  REVA MCP router (single endpoint, unified tool set). Use this for every
  contact / company / deal / pipeline / activity operation. Wraps
  Nakatomi's structured model tuned for Rev A: RFQ → Quoted → Accepted →
  Manufacturing → Inspection → Shipped → Delivered → Invoiced → Paid.
compatibility: Claude Code, Claude desktop, Claude CoWork
recommendedModel: claude-opus-4-6
allowed-tools:
  - Bash
  - Read
  - Write
  - Edit
  - Grep
  - Glob
  - AskUserQuestion
---

## When to use this skill

Any time the user talks about:

- An RFQ, quote, part number, PO, or shipment → **deal** on the
  *Manufacturing RFQ* pipeline.
- A customer or prospect company → **company** (check `custom_fields.compliance`
  for ITAR/EAR, `custom_fields.region` for China/US/etc.)
- A buyer, engineer, QA rep, shipping contact → **contact** with `role` set.
- A call, email, visit, or supplier meeting → **activity** logged to the right entity.
- Anything owed (follow up, send drawing, chase payment) → **task**.

## Connection

This skill talks to the REVA MCP router. It does NOT talk to Nakatomi directly.

Configuration lives in `~/.reva-turbo/config.yaml`:

```yaml
reva_mcp_url: https://<router>.up.railway.app/mcp
reva_api_key: nk_...
```

The `reva-turbo-config` binary sets these during `install.sh`.

## Tool namespace (from the router)

All CRM tools are prefixed `crm_`:

- `crm_search_contacts`, `crm_get_contact`, `crm_create_contact`, `crm_update_contact`
- `crm_search_companies`, `crm_create_company`
- `crm_list_pipelines`, `crm_create_deal`, `crm_move_deal_stage`
- `crm_log_activity`, `crm_add_note`, `crm_create_task`, `crm_list_tasks`
- `crm_relate`, `crm_timeline`, `crm_describe_schema`

Cross-system (CRM × memory):
- `reva_remember_about_entity` — store a memory AND link it to a CRM entity
- `reva_recall_for_entity` — recall memories scoped to one entity

## Rev A pipeline — required stage transitions

Every deal lives on the `Manufacturing RFQ` pipeline. Stages:

| Order | Stage            | Auto-prompt when moving here                         |
|-------|------------------|------------------------------------------------------|
| 1     | RFQ Received     | Check completeness of part numbers + qty + target price |
| 2     | Qualified        | Confirm compliance flags (ITAR/EAR)                  |
| 3     | Quoted           | Ensure quote sent, margin recorded in `amount`       |
| 4     | Accepted         | Create tasks: issue PO, lock supplier                |
| 5     | In Manufacturing | Open `quality_gates.g1_material`, `.g3_production`   |
| 6     | Inspection (G2)  | Record FAI outcome in `quality_gates.g2_fai`         |
| 7     | Repackage        | Set `china_source.buyer_agent`                       |
| 8     | Shipped          | Log shipment activity; set `quality_gates.g4_shipping` |
| 9     | Delivered        | Trigger customer gate (`reva-turbo-customer-gate`)   |
| 10    | Invoiced         | Task: collect payment                                |
| 11    | Paid             | Won                                                  |
| 12    | Closed Lost      | Require reason in note                               |

When asked to move a deal, ALWAYS call `crm_move_deal_stage` (not
`crm_update_contact` — wrong verb, wrong entity). If the user says "mark it
shipped" assume the deal is in `In Manufacturing` or `Inspection (G2)` —
confirm if ambiguous.

## Rev A custom fields

See `../../../docs/REV_A_SCHEMA.md` for the full manifest. Most-used:

- `company.compliance.itar: bool` — **never** create US-export deals with
  China source without confirming this is false.
- `deal.quality_gates.{g1_material,g2_fai,g3_production,g4_shipping}` —
  each `{status, inspector, date}`. Status = `pending | pass | fail | waived`.
- `deal.ncrs[]` — non-conformance report entries. Append, don't overwrite.
- `deal.part_numbers[]` — always populate from the RFQ.

## Common flows

**"Add a new RFQ from Acme for part 12345":**
1. `crm_search_companies` by domain or name.
2. If missing, `crm_create_company` (ask for ITAR/EAR flags).
3. `crm_list_pipelines` → find the `Manufacturing RFQ` pipeline + stage ids.
4. `crm_create_deal` with stage = RFQ Received, `data.part_numbers = ["12345"]`.
5. Memory: `reva_remember_about_entity` on the deal, type `Context`,
   tags `["reva/rfq"]`, content = the RFQ summary.

**"What do we know about Acme?":**
1. `crm_search_companies` → company id.
2. `crm_timeline` on the company → activity history.
3. `reva_recall_for_entity` scoped to that company → institutional knowledge.
4. Summarize both.

## Anti-patterns

- ❌ Creating two contacts for the same email (use `email=` on
  `crm_search_contacts` first — Nakatomi allows duplicates but they poison
  reporting).
- ❌ Skipping `crm_describe_schema` when the user asks about a custom field
  you haven't seen. The schema is self-describing — use it.
- ❌ Writing memory that mentions PII without also linking it to the
  CRM entity (orphan memories can't be redacted on customer deletion).
