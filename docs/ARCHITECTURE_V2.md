# REVA-OPS v2 Architecture

> v2 replaces the single-plugin layout with a monorepo: plugin + CRM backend + memory backend + MCP router, all deploying to one Railway project. **One public `/mcp` endpoint; everything else is private.**

## Components

### 1. REVA-TURBO plugin (`plugin/`)
46 Claude Code skills + 20 slash commands + one installer. Installed to `~/.claude/skills/reva-turbo` via symlink; shipped with `.claude/settings.json` pinning Sonnet 4.6. Unchanged from v1 except:
- Two new skills (`reva-turbo-reva-crm`, `reva-turbo-reva-memory`) that talk to the router
- `install.sh` now accepts `REVA_MCP_URL` + `REVA_API_KEY` and registers the MCP server in `~/.claude/mcp.json`
- Plugin lives under `plugin/` instead of at repo root; `install.sh` auto-detects either layout

### 2. MCP router (`services/mcp-router/`)
FastAPI app mounting a FastMCP streamable-HTTP server at `/mcp`. Four responsibilities:
1. **Auth** — pull `Authorization: Bearer nk_...` off each MCP request and forward it to Nakatomi.
2. **CRM tools** (`crm_*` namespace) — proxy to Nakatomi's REST API over the private network.
3. **Memory tools** (`mem_*` namespace) — proxy to AutoMem's REST API, attaching the service token on each call (AutoMem is per-workspace, not per-user).
4. **Cross-system tools** (`reva_*` namespace) — orchestrate multi-hop flows like `remember_about_entity` (write memory → link to CRM entity in one call).

Zero business logic. If you're tempted to add validation or workflow here, push it upstream into Nakatomi (structured) or a plugin skill (contextual).

### 3. Nakatomi backend (`services/nakatomi-backend/`)
The structured system of record. Railway builds from the upstream repo (`mrdulasolutions/NakatomiCRM`) — we don't vendor the code, just bump refs. Rev A overlays are applied at deploy time by `seed/reva.py`:
- `Manufacturing RFQ` pipeline (12 stages)
- Custom-field manifest (`company.compliance`, `deal.quality_gates`, `deal.ncrs`, …)
- Memory-connector env pointed at internal AutoMem

### 4. AutoMem backend (`services/automem-backend/`)
The hybrid memory store (FalkorDB graph + Qdrant vectors). Same pattern: Railway builds from `mrdulasolutions/automem`. Rev A overlays are purely conventional — tag-based scoping (`reva-crm`, `reva/<topic>`, `{entity_type}:{entity_id}`) enforced by the router.

## Data flow

### Write path (`reva_remember_about_entity`)
```
Claude Code / plugin
  │  MCP streamable-HTTP
  ▼
mcp-router.reva_remember_about_entity
  ├─► AutoMem POST /memory (returns memory_id)
  └─► Nakatomi POST /memory-links (attaches memory_id to entity)
```

### Read path (`crm_timeline` with memory hydration)
```
Claude Code asks: "what's on with Acme?"
  ▼
mcp-router.crm_timeline(company, acme_id)
  ├─► Nakatomi GET /timeline?entity_type=company&entity_id=acme_id
  └─► (optional follow-up) reva_recall_for_entity(company, acme_id)
        └─► AutoMem GET /recall?tags=company:acme_id
```

## Auth model

| Principal              | Token                | Validated by                |
|------------------------|----------------------|-----------------------------|
| Human PM via Claude    | `nk_...` bearer      | Nakatomi on each call       |
| Router → Nakatomi      | forwarded bearer     | Nakatomi on each call       |
| Router → AutoMem       | `AUTOMEM_API_TOKEN`  | AutoMem (single service key)|
| Admin CLI              | Railway service env  | Railway                     |

The client never sees or needs `AUTOMEM_API_TOKEN`. Memory calls from the router attach it automatically.

## Deployment topology

```
Railway project: reva-ops
├── mcp-router           [public domain]   ← only externally reachable service
├── nakatomi-backend     [private only]
├── automem-backend      [private only]
├── postgres             [Railway plugin]
├── falkordb             [Railway plugin]  (redis image with FalkorDB module)
└── qdrant               [Railway plugin]  (custom docker image)
```

All private services communicate over `*.railway.internal` DNS. No traffic leaves the Railway project for internal calls.

## Why not submodules / why not a single Docker image

- **Submodules.** Rejected: makes `git clone` slower, breaks shallow clones on Railway, and the upstream Nakatomi/AutoMem repos are already pinnable via Railway's source-repo field. We get the same version-pinning behavior with none of the friction.
- **Single fat image.** Rejected: Railway separates scaling and environment per service. Running AutoMem (Python + FalkorDB client + Qdrant client + embeddings) inside the same process as Nakatomi (SQLAlchemy + FastAPI) makes restarts expensive and OOM events catastrophic. The router's one job is to *look* like a single endpoint; it doesn't need to *be* a single process.

## Rollback / disaster recovery

- Postgres, FalkorDB, Qdrant are Railway-managed with daily volume snapshots.
- Service source is pinned to git refs in `railway/template.yaml` — rolling back is a `railway redeploy --ref <old-sha>`.
- Plugin uninstall: `rm -rf ~/.claude/skills/reva-turbo ~/.reva-turbo` and remove the `reva` entry from `~/.claude/mcp.json`.

## Open questions tracked for v2.1

- Per-user API keys in the plugin (today: one shared Rev A key). Nakatomi already supports per-user; plugin UX just needs to call `POST /workspace/api-keys`.
- Auth mode `service` (the router validates + re-mints tokens) — skeleton is in `router/auth.py`; needs a `/auth/whoami` check before we flip the env var.
- Streaming progress through MCP for long-running tools (`reva_remember_about_entity` is 2 HTTP round-trips — nice to surface per-step status).
- Attachment surface — AutoMem has `upload_document`; router hasn't wrapped it yet (deliberate: agents should be reading files themselves and summarizing).
