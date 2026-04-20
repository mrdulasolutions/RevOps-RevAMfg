# Railway template

One-click Railway deploy for the REVA-OPS stack.

**Single Railway project. Single public endpoint (`/mcp`). Multiple internal services.**

## What gets deployed

```
┌─────────────────────── Railway project ───────────────────────┐
│                                                                │
│   PUBLIC                                                       │
│   ┌──────────────────┐                                         │
│   │ mcp-router       │ ← reva-turbo plugin points here         │
│   │ services/...     │   https://<router>.up.railway.app/mcp   │
│   └────────┬─────────┘                                         │
│            │   (Railway private network, *.railway.internal)   │
│   ┌────────▼─────────┐        ┌──────────────────┐             │
│   │ nakatomi-backend │        │ automem-backend  │             │
│   │ (Nakatomi CRM)   │        │ (AutoMem)        │             │
│   └────────┬─────────┘        └──┬──────────┬────┘             │
│            │                     │          │                  │
│      ┌─────▼─────┐         ┌─────▼─────┐ ┌──▼────────┐         │
│      │ Postgres  │         │ FalkorDB  │ │ Qdrant    │         │
│      │ (plugin)  │         │ (plugin)  │ │ (plugin)  │         │
│      └───────────┘         └───────────┘ └───────────┘         │
└────────────────────────────────────────────────────────────────┘
```

## Files

- `template.yaml` — Railway template manifest (services, envs, plugins, build
  refs)
- `deploy.sh` — CLI path: clone, provision, seed, print the public URL + API
  key. Use this when you want a repeatable deploy you can script against.
- `env.example` — everything the template prompts for

## One-click deploy

Click the button in the root `README.md`. Railway reads `template.yaml`,
provisions the three plugins, spins up all three services, runs the
Nakatomi migrations, and seeds the Rev A schema.

## CLI deploy (recommended for admins)

```bash
# from repo root
./railway/deploy.sh --project-name reva-ops --admin-email you@reva.com
# → prints:
#   public MCP url: https://<router>.up.railway.app/mcp
#   admin api key:  nk_...
# Save both. The plugin's install.sh will prompt you for them.
```

## After deploy

Point the REVA-TURBO plugin at the new stack:

```bash
curl -fsSL https://raw.githubusercontent.com/mrdulasolutions/RevOps-RevAMfg/main/plugin/install.sh \
  | REVA_MCP_URL=https://<router>.up.railway.app/mcp \
    REVA_API_KEY=nk_... \
    bash
```
