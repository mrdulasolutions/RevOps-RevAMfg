# AutoMem Backend (internal service)

The memory backend — hybrid graph (FalkorDB) + vector (Qdrant) store.
Private to the Railway project; all external traffic goes through
`services/mcp-router`.

## Upstream

Source: https://github.com/mrdulasolutions/automem

Same vendor-by-reference pattern as Nakatomi: Railway builds directly
from the upstream repo, with Rev A overlays applied via env + seeds.

## Rev A overlays

AutoMem is workspace-agnostic by design — we scope memories to Rev A via
tag convention:

- Every memory the router stores carries the tag `reva-crm` plus one or
  more `{entity_type}:{entity_id}` tags (see
  `services/mcp-router/router/tools/cross.py`).
- Recall tools from the MCP router filter by those tags so a prompt
  never leaks across entities or — in a multi-tenant future — across
  workspaces.

## Environment (set on Railway)

| Var                | Notes                                                     |
|--------------------|-----------------------------------------------------------|
| `PORT`             | `8001` internal                                           |
| `FALKORDB_HOST`    | Railway FalkorDB plugin private host                      |
| `QDRANT_URL`       | Railway Qdrant plugin private URL                         |
| `API_TOKEN`        | shared secret, same value on the router                   |
| `ADMIN_TOKEN`      | separate admin secret for schema ops                      |
| `OPENAI_API_KEY`   | optional — if omitted AutoMem uses placeholder embeddings |
| `EMBEDDING_MODEL`  | default `text-embedding-3-small`                          |

Reached from the router at
`http://automem-backend.railway.internal:8001`.
