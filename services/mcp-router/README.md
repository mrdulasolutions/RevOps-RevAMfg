# REVA MCP Router

**One MCP endpoint. Two backends. Single Railway project.**

This is the only public-facing service in the REVA-OPS monorepo. Agents (Claude
Desktop, Cursor, the REVA-TURBO plugin, etc.) connect to a single URL:

```
https://<your-railway-domain>/mcp
```

…and get a unified tool set that spans both systems of record:

| Namespace | Tool examples                               | Backend               |
|-----------|---------------------------------------------|-----------------------|
| `crm.*`   | `crm.search_contacts`, `crm.create_deal`, … | Nakatomi (Postgres)   |
| `mem.*`   | `mem.store`, `mem.recall`, `mem.associate`  | AutoMem (Falkor+Qdrant)|

The router itself is thin: it holds no business logic. Tool calls are
translated into HTTP requests against the two internal backend services,
reached over Railway's private network (`nakatomi-backend.railway.internal`
and `automem-backend.railway.internal`).

## Why a router and not two MCPs

Two reasons:

1. **One connector config, not two.** An MCP client (Claude Desktop, Cursor,
   the REVA-TURBO plugin) has to be pointed at each endpoint separately. One
   URL is the difference between onboarding a PM in 30 seconds vs. 5 minutes
   × number of connectors.
2. **Cross-system tools.** Some workflows span CRM + memory — e.g. "remember
   that this customer's compliance gate is ITAR-controlled" is a memory write
   that should tag the CRM contact. A router owns those cross-calls; two
   separate MCPs cannot.

## Auth

The router accepts a single bearer token. It forwards that token (or an
internal key, depending on `AUTH_MODE`) to the upstream services.

- `AUTH_MODE=passthrough` (default) — the client's `Authorization: Bearer
  nk_...` header goes straight to Nakatomi. AutoMem gets a service token
  derived from `AUTOMEM_API_TOKEN`.
- `AUTH_MODE=service` — the router validates the client token against
  Nakatomi's `/auth/whoami`, then uses internal service tokens for both
  backends. Lets you rotate backend keys without rotating client keys.

## Environment

See `.env.example`. Required on Railway:

- `NAKATOMI_INTERNAL_URL` — `http://nakatomi-backend.railway.internal:8000`
- `AUTOMEM_INTERNAL_URL` — `http://automem-backend.railway.internal:8001`
- `AUTOMEM_API_TOKEN` — shared secret for the memory backend

## Local dev

```bash
cp .env.example .env
# point NAKATOMI_INTERNAL_URL / AUTOMEM_INTERNAL_URL at local docker-compose
pip install -r requirements.txt
uvicorn router.main:app --reload --port 8080
# MCP endpoint: http://localhost:8080/mcp
```
