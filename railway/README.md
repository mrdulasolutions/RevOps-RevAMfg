# Railway deploy

One Railway project, three application services, three managed databases.
Only `mcp-router` has a public domain — everything else is on Railway's
private network (`*.railway.internal`).

```
┌─────────────────────── Railway project ───────────────────────┐
│                                                                │
│   PUBLIC                                                       │
│   ┌──────────────────┐                                         │
│   │ mcp-router       │ ← reva-turbo plugin points here         │
│   │ /mcp + /signup   │   https://<router>.up.railway.app/mcp   │
│   └────────┬─────────┘                                         │
│            │   (Railway private network, *.railway.internal)   │
│   ┌────────▼─────────┐        ┌──────────────────┐             │
│   │ nakatomi-backend │        │ automem-backend  │             │
│   │ (Nakatomi CRM)   │        │ (AutoMem)        │             │
│   └────────┬─────────┘        └──┬──────────┬────┘             │
│            │                     │          │                  │
│      ┌─────▼─────┐         ┌─────▼─────┐ ┌──▼────────┐         │
│      │ Postgres  │         │ FalkorDB  │ │ Qdrant    │         │
│      └───────────┘         └───────────┘ └───────────┘         │
└────────────────────────────────────────────────────────────────┘
```

## Files

- `deploy.sh` — phased deploy script against the Railway CLI (4.40+)
- `template.yaml` — reference spec for the stack. Not executable — Railway
  CLI doesn't deploy from a local YAML; use `deploy.sh` for reproducibility
  or the web UI for manual clicks.
- `.deploy-state` — generated secrets (gitignored)

## Prerequisites

```bash
# CLI
brew install railwayapp/railway/railway      # macOS
# or: npm i -g @railway/cli

railway login                                # browser-based OAuth
railway whoami                               # sanity check

# Other deps
brew install jq openssl
```

**Authorize Railway's GitHub App for the `mrdulasolutions` org.** This is
a one-time per-workspace step and is required for the `services` phase
to deploy Nakatomi + AutoMem from their repos. Without it, `railway add
--repo` returns `Unauthorized`.

1. Open https://railway.com/account → **Integrations** → **GitHub**
2. Click **Configure** and grant the Railway app access to `NakatomiCRM`
   and `automem` (or the whole `mrdulasolutions` org)
3. Re-run the `services` phase

## Deploy (phased)

`deploy.sh` is broken into phases so you can inspect Railway's state
between steps. Run without arguments for the whole flight, or pass a
specific phase name to retry one.

```bash
# Phase 1: create project + provision DBs (Postgres, FalkorDB, Qdrant)
./railway/deploy.sh init

# Phase 2: add & configure nakatomi-backend, automem-backend, mcp-router
#          (sets private-network URLs, mints API tokens, generates router
#          public domain, runs `railway up` for the router from
#          services/mcp-router)
./railway/deploy.sh services

# Phase 3: seed Nakatomi admin user + Rev A pipeline/custom fields
./railway/deploy.sh seed --admin-email you@reva-mfg.com

# Phase 4: print the public MCP URL, admin creds, and PM signup token
./railway/deploy.sh finalize

# Or do all four in order:
./railway/deploy.sh --admin-email you@reva-mfg.com
```

After `init`, this directory is linked to the project via `.railway/`;
every subsequent `railway` command auto-discovers it.

## What you hand out to PMs

Two things only:

1. **Signup URL** — `https://<router>.up.railway.app/signup`
2. **Signup token** — the `REVA_SIGNUP_TOKEN` value printed by
   `deploy.sh finalize` (or read from `.deploy-state`)

PMs mint their own `nk_...` API keys from that page. You don't share your
admin key with anyone.

## Rotating the signup token

```bash
railway variable set "REVA_SIGNUP_TOKEN=$(openssl rand -hex 16)" --service mcp-router
# Old token stops working on the next deploy. Existing PMs are unaffected
# (their API keys don't depend on the signup token after mint).
```

## If something fails mid-flight

Each phase is independently re-runnable:

```bash
./railway/deploy.sh services      # re-runs service adds (idempotent — `railway add` errors on dupes, which the script tolerates)
./railway/deploy.sh seed          # retry just the seed if Nakatomi wasn't ready the first time
```

Logs:

```bash
railway logs --service mcp-router
railway logs --service nakatomi-backend
railway logs --service automem-backend
```

## Manual fallback (web UI)

If the CLI path fails and you need to unblock, you can click the same
topology together in the Railway dashboard:

1. Create project `reva-ops`
2. Add Postgres, FalkorDB (`falkordb/falkordb:latest`), Qdrant
   (`qdrant/qdrant:latest`) as services
3. Add GitHub-source services `nakatomi-backend` (`mrdulasolutions/NakatomiCRM`)
   and `automem-backend` (`mrdulasolutions/automem`)
4. Add `mcp-router`: either point at `mrdulasolutions/RevOps-RevAMfg` with
   Root Directory = `services/mcp-router`, or deploy via CLI from the local
   subdir (`cd services/mcp-router && railway up`)
5. Copy the env-var blocks from `deploy.sh` phase 2 into the dashboard
6. Run the seed commands from phase 3 via `railway run`
