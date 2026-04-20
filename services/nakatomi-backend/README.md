# Nakatomi Backend (internal service)

The CRM backend. Private to the Railway project — not publicly exposed.
All external traffic goes through `services/mcp-router`.

## Upstream

Source: https://github.com/mrdulasolutions/NakatomiCRM

We don't vendor the source — Railway builds it directly from the upstream
repo (pin in `railway/template.yaml`). That keeps this repo small and lets
us pick up Nakatomi fixes by bumping a single ref.

## Rev A customizations

Delivered as a post-migration seed step, not as forked source code:

- **Pipeline** — `Manufacturing RFQ`: RFQ → Qualified → Quoted → Accepted
  → In Manufacturing → Inspection → Repackage → Shipped → Delivered →
  Invoiced → Paid → Closed
- **Custom fields** (JSONB) per entity:
  - `company.partner_scorecard` — on-time %, defect rate, lead-time days
  - `company.compliance` — ITAR/EAR flags, certifications
  - `deal.quality_gates` — G1 material, G2 FAI, G3 production, G4 shipping
  - `deal.ncrs` — non-conformance reports (array of `{id, stage, issue, status}`)
  - `contact.role` — buyer / engineering / quality / shipping / finance
- **Memory taxonomy** tags prefixed `reva/`: `reva/rfq`, `reva/quality`,
  `reva/compliance`, `reva/china-source`, `reva/partner-scorecard`

See [`seed/reva.py`](./seed/reva.py) for the exact payloads and
[`docs/REV_A_SCHEMA.md`](../../docs/REV_A_SCHEMA.md) for the schema doc.

## Environment (set on Railway)

| Var                | Notes                                               |
|--------------------|-----------------------------------------------------|
| `DATABASE_URL`     | Railway Postgres plugin exposes this automatically  |
| `SECRET_KEY`       | 64 hex chars — `openssl rand -hex 32`               |
| `STORAGE_BACKEND`  | `local` (default) or `s3`                           |
| `MEMORY_CONNECTORS`| `automem`                                           |
| `AUTOMEM_URL`      | `http://automem-backend.railway.internal:8001`      |
| `AUTOMEM_API_TOKEN`| shared secret, same value as on the router + automem|

Nakatomi is reached at `http://nakatomi-backend.railway.internal:8000`
from inside the Railway project.
