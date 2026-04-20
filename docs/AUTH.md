# Authentication and Signup

End-to-end: how a Rev A PM goes from "never heard of REVA-OPS" to a
working Claude Code connection in about 90 seconds.

## Two principals, two paths

| Principal       | Credentials                        | How they get them                          |
|-----------------|-----------------------------------|--------------------------------------------|
| Admin (MrDula)  | Railway account + admin `nk_...`  | `./railway/deploy.sh` prints both          |
| PM (Rev A user) | Personal `nk_...` API key          | Self-serve via `/signup` page **or** `install.sh` wizard |

There is no shared-key-for-the-team path. Every PM has their own key so
Nakatomi's timeline attributes activities, notes, and deal moves to the
right person.

## Admin flow — one-time

```bash
./railway/deploy.sh --project-name reva-ops --admin-email admin@reva-mfg.com
```

`deploy.sh` does this (and prints all of it):

1. Creates the Railway project.
2. Provisions Postgres, FalkorDB, Qdrant.
3. Deploys `mcp-router`, `nakatomi-backend`, `automem-backend` from their source repos.
4. Waits for migrations to run inside Nakatomi on boot.
5. Runs `python -m scripts.seed` on `nakatomi-backend` → creates:
   - The Rev A workspace (`slug: reva`)
   - An admin user with `role: owner`
   - An initial admin API key (`nk_...`)
6. Runs `services/nakatomi-backend/seed/reva.py` → installs the Rev A
   pipeline + custom-field manifest.
7. Sets two shared env vars on the `mcp-router` service:
   - `NAKATOMI_ADMIN_TOKEN` = the admin API key from step 5
   - `REVA_SIGNUP_TOKEN` = a freshly generated shared signup gate
8. Prints the public MCP URL, admin email / password / API key, and the
   signup token.

The admin keeps the admin key. The signup token is what they share with
PMs during onboarding (Slack DM, 1Password, whatever).

## PM flow — one-time per PM

### Option 1 — terminal wizard (recommended)

```bash
curl -fsSL https://raw.githubusercontent.com/mrdulasolutions/RevOps-RevAMfg/main/plugin/install.sh \
  | REVA_MCP_URL=https://<router>.up.railway.app/mcp bash
```

Because `REVA_API_KEY` is *not* set, `install.sh` drops into the wizard:

```
Your name            : Jane Doe
Work email           : jane@reva-mfg.com
Password (12+ chars) : ************
Signup token         : (paste what the admin sent)
```

Under the hood it POSTs to `<router>/signup`, captures the returned
`nk_...` key, and writes it into `~/.claude/mcp.json`. Restart Claude
Code. Done.

### Option 2 — browser

Visit `https://<router>.up.railway.app/signup`. Same inputs, same
result. The page displays the key once and gives you the exact
`install.sh` command to run with `REVA_API_KEY` pre-filled.

### Option 3 — pre-shared key

If an admin already has a key they want to hand you:

```bash
curl -fsSL https://.../plugin/install.sh \
  | REVA_MCP_URL=... REVA_API_KEY=nk_... bash
```

## What `/signup` actually does

Nakatomi's native `POST /auth/signup` only creates fresh workspaces —
there's no public "join an existing workspace" endpoint. The router
stitches the flow together:

```
PM → POST /signup {name, email, password, signup_token}
      │
      │  router: validate signup_token (constant-time compare)
      ▼
      POST nakatomi/auth/signup           ← public; creates user +
                                            throwaway personal workspace
      │  returns user_id
      ▼
      POST nakatomi/workspace/members     ← admin token; adds user to Rev A
      (headers: Authorization: Bearer <NAKATOMI_ADMIN_TOKEN>,
                X-Workspace: reva)
      │
      ▼
      POST nakatomi/workspace/api-keys    ← admin token; mints key for user
      │  returns plaintext key (only time it's ever returned)
      ▼
      PM ← {api_key, user_id, workspace_slug, mcp_url}
```

The throwaway personal workspace is never referenced — it's a
side-effect of Nakatomi's signup contract. Harmless.

## Rotation

- **Signup token** — redeploy `mcp-router` with a new `REVA_SIGNUP_TOKEN`
  env. Old token stops working instantly. Existing PMs are unaffected
  (their keys are minted; they don't need the signup token anymore).
- **PM API key** — Nakatomi's `/workspace/api-keys/{id}` DELETE endpoint
  revokes. PM re-runs the signup wizard.
- **Admin token** — admin mints a replacement via Nakatomi's own API or
  through the router's admin calls (not yet exposed), then updates
  `NAKATOMI_ADMIN_TOKEN` on the router.

## What `install.sh` writes

After a successful signup:

```
~/.claude/mcp.json            ← adds "reva" MCP server entry
~/.reva-turbo/config.yaml     ← reva_mcp_url + reva_api_key
~/.claude/skills/reva-turbo   ← symlink to the cloned plugin dir
```

`~/.claude/mcp.json` after install:

```json
{
  "mcpServers": {
    "reva": {
      "type": "http",
      "url": "https://<router>.up.railway.app/mcp",
      "headers": { "Authorization": "Bearer nk_xxx..." }
    }
  }
}
```

Claude Code picks that up on next restart.

## Security notes

- `/signup` requires `REVA_SIGNUP_TOKEN` AND `NAKATOMI_ADMIN_TOKEN` to
  be set on the router. Missing either disables the endpoint (returns
  503). A pristine deploy with no admin interaction is closed by default.
- Passwords are sent over TLS to the router, forwarded over the Railway
  private network to Nakatomi, and hashed with bcrypt before storage.
- The signup token is compared with `secrets.compare_digest` — no
  timing leaks.
- API keys are stored hashed (SHA-256) in Nakatomi; plaintext is only
  returned at mint time. Losing the key means minting a new one.
- The admin token never leaves the router (not forwarded to the PM,
  not in logs, not in the MCP response). If a router container image is
  compromised, rotate `NAKATOMI_ADMIN_TOKEN`.

## Known gaps (tracked for v2.1)

- No email verification. Signup token is the only gate. Fine for an
  internal Rev A team; not OK for public deploys.
- No password reset flow in the router. If a PM forgets, admin has to
  mint a new key via Nakatomi directly and hand it over.
- No SSO (SAML/OIDC). Tracked in `docs/ROADMAP.md`.
