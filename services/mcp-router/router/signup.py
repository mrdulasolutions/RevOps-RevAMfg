"""Self-service signup flow for Rev A PMs.

Nakatomi's ``POST /auth/signup`` always creates a fresh user + workspace.
There's no native "join an existing workspace" endpoint, so we stitch the
dance together here:

1. Caller supplies email / password / name / signup_token.
2. We validate ``signup_token`` against the router's env.
3. We call Nakatomi's ``POST /auth/signup`` to create the user (and a
   throwaway personal workspace — it's cheap and harmless).
4. We use the router's admin token to ``POST /workspace/members`` into
   the Rev A workspace.
5. We use the admin token to mint a per-user API key scoped to Rev A.
6. We return the key and the public MCP URL.

The admin token and signup token are set on the router at deploy time
(see ``railway/template.yaml``). The user never sees either.
"""

from __future__ import annotations

import logging
import secrets
from typing import Any

import httpx
from fastapi import APIRouter, HTTPException
from fastapi.responses import HTMLResponse
from pydantic import BaseModel, EmailStr, Field

from .config import settings

log = logging.getLogger("reva.signup")

router = APIRouter()


# ---------------------------------------------------------------------------
# Settings that live *only* for signup. Kept here (not in config.py) so the
# rest of the router stays unaware of admin credentials.
# ---------------------------------------------------------------------------

import os  # noqa: E402

REVA_SIGNUP_TOKEN = os.environ.get("REVA_SIGNUP_TOKEN", "")
REVA_WORKSPACE_SLUG = os.environ.get("REVA_WORKSPACE_SLUG", "reva")
NAKATOMI_ADMIN_TOKEN = os.environ.get("NAKATOMI_ADMIN_TOKEN", "")
PUBLIC_MCP_URL = os.environ.get("PUBLIC_MCP_URL", "")  # optional hint for the UI

# Email domains allowed to self-serve a key. A valid signup_token alone isn't
# enough — the signup token is shared in a group chat, and we don't want a
# leaked token to hand out keys to random gmail accounts. Comma-separated,
# case-insensitive, no leading `@`. Override via env to re-use this router
# for a different tenant.
_DEFAULT_ALLOWED_DOMAINS = "revamfg.com,mrdula.solutions"
ALLOWED_EMAIL_DOMAINS: frozenset[str] = frozenset(
    d.strip().lower().lstrip("@")
    for d in os.environ.get("REVA_ALLOWED_EMAIL_DOMAINS", _DEFAULT_ALLOWED_DOMAINS).split(",")
    if d.strip()
)

SIGNUP_ENABLED = bool(REVA_SIGNUP_TOKEN and NAKATOMI_ADMIN_TOKEN)


def _email_domain_allowed(email: str) -> bool:
    """True if the email's domain (case-insensitive) is in the allowlist.

    Empty allowlist => deny everything (fail-closed). Returning True on an
    empty set would turn a misconfigured env var into an open signup.
    """
    if not ALLOWED_EMAIL_DOMAINS:
        return False
    _, _, domain = email.rpartition("@")
    return domain.lower() in ALLOWED_EMAIL_DOMAINS


class SignupRequest(BaseModel):
    email: EmailStr
    password: str = Field(min_length=12)
    display_name: str = Field(min_length=1, max_length=80)
    signup_token: str
    key_name: str | None = None  # label for the API key; defaults to the display name


class SignupResponse(BaseModel):
    api_key: str
    user_id: str
    workspace_slug: str
    mcp_url: str


# ---------------------------------------------------------------------------
# POST /signup — does the dance.
# ---------------------------------------------------------------------------


@router.post("/signup", response_model=SignupResponse)
async def signup(req: SignupRequest) -> SignupResponse:
    if not SIGNUP_ENABLED:
        raise HTTPException(
            status_code=503,
            detail="signup is not configured on this deploy "
                   "(REVA_SIGNUP_TOKEN / NAKATOMI_ADMIN_TOKEN unset)",
        )
    if not secrets.compare_digest(req.signup_token, REVA_SIGNUP_TOKEN):
        raise HTTPException(status_code=403, detail="invalid signup token")

    # Domain allowlist. Checked AFTER the signup-token check so rejection
    # here also implies the caller already knew the (shared) token — we
    # just won't hand them a key unless their mailbox matches.
    if not _email_domain_allowed(req.email):
        allowed = ", ".join(f"@{d}" for d in sorted(ALLOWED_EMAIL_DOMAINS))
        log.info("signup blocked: email domain not allowed (email=%s)", req.email)
        raise HTTPException(
            status_code=403,
            detail=f"email domain not allowed — use one of: {allowed}",
        )

    # Throwaway personal workspace for the new user — Nakatomi requires one
    # at signup time. Uses a random slug so re-runs don't collide.
    personal_slug = f"personal-{secrets.token_hex(4)}"

    timeout = httpx.Timeout(settings.upstream_timeout, connect=settings.upstream_connect_timeout)

    async with httpx.AsyncClient(timeout=timeout) as client:
        # 1. Create user (public endpoint; no auth header).
        r = await client.post(
            f"{settings.nakatomi_internal_url.rstrip('/')}/auth/signup",
            json={
                "email": req.email,
                "password": req.password,
                "display_name": req.display_name,
                "workspace_name": f"{req.display_name}'s space",
                "workspace_slug": personal_slug,
            },
        )
        if r.status_code == 409:
            raise HTTPException(status_code=409, detail=_extract_detail(r, "email already registered"))
        if r.status_code >= 400:
            log.error("upstream signup failed: %s %s", r.status_code, r.text[:200])
            raise HTTPException(status_code=502, detail="upstream signup failed")
        tok = r.json()
        user_id: str = tok["user_id"]

        # 2. Add user to the Rev A workspace.
        admin_headers = {
            "Authorization": f"Bearer {NAKATOMI_ADMIN_TOKEN}",
            "X-Workspace": REVA_WORKSPACE_SLUG,
        }
        r = await client.post(
            f"{settings.nakatomi_internal_url.rstrip('/')}/workspace/members",
            headers=admin_headers,
            json={"email": req.email, "role": "member"},
        )
        # 409 means they're already a member — fine, continue to key mint.
        if r.status_code not in (200, 201, 409):
            log.error("add member failed: %s %s", r.status_code, r.text[:200])
            raise HTTPException(status_code=502, detail="failed to add to Rev A workspace")

        # 3. Mint an API key scoped to the Rev A workspace + this user.
        r = await client.post(
            f"{settings.nakatomi_internal_url.rstrip('/')}/workspace/api-keys",
            headers=admin_headers,
            json={
                "user_id": user_id,
                "name": req.key_name or f"{req.display_name} (auto)",
                "role": "member",
            },
        )
        if r.status_code >= 400:
            log.error("api-key mint failed: %s %s", r.status_code, r.text[:200])
            raise HTTPException(status_code=502, detail="failed to mint API key")
        key_row = r.json()
        api_key: str = key_row["key"]  # plaintext, only returned once

    return SignupResponse(
        api_key=api_key,
        user_id=user_id,
        workspace_slug=REVA_WORKSPACE_SLUG,
        mcp_url=PUBLIC_MCP_URL or "/mcp",
    )


def _extract_detail(resp: httpx.Response, fallback: str) -> str:
    try:
        d = resp.json().get("detail")
        if isinstance(d, str) and d:
            return d
    except Exception:  # noqa: BLE001
        pass
    return fallback


# ---------------------------------------------------------------------------
# GET /signup — human-friendly HTML page (calls POST /signup via fetch).
# ---------------------------------------------------------------------------


SIGNUP_HTML = """<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>REVA-OPS · Join the team</title>
<style>
  :root {
    --bg:#0b1020; --fg:#e6ecf3; --accent:#4ea3ff; --accent-dim:#2d75cc;
    --muted:#8593a8; --card:#121a33; --card-2:#0f1630;
    --ok:#16a06b; --err:#ff6b6b; --warn-bg:#2b230f; --warn-fg:#ffd479;
    --border:#1f2b4a;
  }
  *,*::before,*::after { box-sizing:border-box; }
  html,body { margin:0; padding:0; background:var(--bg); color:var(--fg);
    font:15px/1.5 -apple-system,BlinkMacSystemFont,"Segoe UI",sans-serif; }
  main { max-width:620px; margin:5vh auto; padding:24px; }
  header { display:flex; align-items:baseline; gap:10px; margin-bottom:4px; }
  header h1 { font-size:28px; margin:0; letter-spacing:-0.01em; }
  header .tag { font-size:11px; color:var(--muted); text-transform:uppercase;
    letter-spacing:0.08em; background:var(--card); padding:3px 7px; border-radius:4px; }
  p.sub { color:var(--muted); margin:0 0 24px; }

  .steps { display:flex; gap:6px; margin:12px 0 20px; }
  .step { flex:1; padding:8px 10px; background:var(--card); border-radius:6px;
    font-size:12px; color:var(--muted); border:1px solid transparent;
    display:flex; align-items:center; gap:8px; }
  .step .n { width:18px; height:18px; border-radius:50%; background:var(--card-2);
    color:var(--muted); font-weight:600; font-size:11px;
    display:inline-flex; align-items:center; justify-content:center; }
  .step.active { color:var(--fg); border-color:var(--accent-dim); }
  .step.active .n { background:var(--accent); color:#001126; }
  .step.done .n { background:var(--ok); color:#fff; }
  .step.done { color:var(--fg); }

  form, .panel { background:var(--card); padding:22px; border-radius:10px; border:1px solid var(--border); }
  label { display:block; font-size:13px; color:var(--muted); margin:14px 0 4px; font-weight:500; }
  label:first-of-type { margin-top:0; }
  input { width:100%; padding:11px 13px; border:1px solid var(--border);
    background:var(--card-2); color:var(--fg); border-radius:6px; font:inherit; }
  input:focus { outline:none; border-color:var(--accent); }
  button { margin-top:20px; width:100%; padding:12px; background:var(--accent); color:#001126;
    border:0; border-radius:6px; font-weight:600; font-size:15px; cursor:pointer;
    transition:background 0.15s; }
  button:hover:not(:disabled) { background:#69b4ff; }
  button:disabled { opacity:0.6; cursor:progress; }

  .result { margin-top:20px; padding:18px; border-radius:8px;
    background:#0d2b1e; border:1px solid #184d37; display:none; }
  .result.err { background:#2a0f16; border-color:#4a1820; }
  .result h3 { margin:0 0 10px; font-size:16px; }
  code { background:var(--card-2); padding:2px 6px; border-radius:4px; user-select:all;
    font-family:"SF Mono",ui-monospace,monospace; font-size:13px; word-break:break-all; }
  pre { background:var(--card-2); padding:12px; border-radius:6px; overflow-x:auto;
    margin:8px 0; font-size:13px; user-select:all; font-family:"SF Mono",ui-monospace,monospace; }
  .muted { color:var(--muted); font-size:13px; }
  .pill { display:inline-block; background:var(--card-2); padding:3px 8px; border-radius:999px;
    font-size:11px; color:var(--muted); margin-right:6px; }

  .hygiene { margin-top:12px; padding:14px 16px; border-radius:8px;
    background:var(--warn-bg); border:1px solid #55421a; color:var(--warn-fg); font-size:13px; }
  .hygiene strong { color:#ffe29a; }

  .post { display:none; }
  .post.on { display:block; }
  .post ol { padding-left:20px; margin:8px 0; }
  .post li { margin:10px 0; }
  .post li strong { color:var(--fg); }

  a { color:var(--accent); text-decoration:none; }
  a:hover { text-decoration:underline; }
</style>
</head>
<body>
<main>
  <header>
    <h1>REVA-OPS</h1>
    <span class="tag">Rev&nbsp;A Manufacturing</span>
  </header>
  <p class="sub">You're one minute from having the full PM engine — CRM,
  memory, and 48 skills — connected to Claude Desktop.</p>

  <div class="steps">
    <div class="step active" id="s1"><span class="n">1</span> Mint API key</div>
    <div class="step" id="s2"><span class="n">2</span> Install plugin</div>
    <div class="step" id="s3"><span class="n">3</span> Run engine</div>
  </div>

  <form id="f">
    <label for="name">Your name</label>
    <input id="name" required autocomplete="name" placeholder="Jane Doe" />

    <label for="email">Work email <span class="muted">(must be __ALLOWED_DOMAINS_TEXT__)</span></label>
    <input id="email" required type="email" autocomplete="email" placeholder="jane@revamfg.com" />

    <label for="password">Password <span class="muted">(12+ chars — only for future key resets)</span></label>
    <input id="password" required type="password" autocomplete="new-password" minlength="12" />

    <label for="token">Signup token <span class="muted">(one-time code from your admin)</span></label>
    <input id="token" required autocomplete="off" placeholder="e.g. 4f2a…" />

    <button type="submit" id="btn">Mint my API key →</button>
  </form>

  <div id="result" class="result"></div>

  <div id="post" class="post">
    <h3 style="margin-top:28px;">Step 2 — Install the plugin</h3>
    <div class="panel">
      <ol>
        <li><strong>Download the latest plugin zip</strong> from
          <a href="https://github.com/mrdulasolutions/RevOps-RevAMfg/releases/latest"
             target="_blank" rel="noopener">GitHub Releases</a>
          — look for <code>reva-turbo-&lt;version&gt;.zip</code>
          (v2.1.1 or later). Don't unzip it.</li>
        <li><strong>Claude Desktop → Plugins → Personal → Local uploads → +</strong>
          and drop in the zip. Click <strong>Enable</strong>.</li>
        <li><strong>No settings to fill in.</strong> The 2.1.1 plugin
          self-configures — you'll paste your key in chat in Step 3.</li>
      </ol>

      <div class="hygiene">
        <strong>Important — remove any legacy connectors.</strong>
        If you previously added a standalone <em>Nakatomi</em> or
        <em>AutoMem</em> MCP connector in Claude Desktop → Settings →
        Connectors, <strong>remove it now</strong>. This plugin wraps
        both behind the router with prefixed tool names
        (<code>crm_*</code> / <code>mem_*</code> / <code>reva_*</code>).
        Duplicates show up as raw <code>search_contacts</code> /
        <code>memory_recall</code> tool names and break intent routing.
      </div>
    </div>

    <h3 style="margin-top:28px;">Step 3 — Run the engine &amp; paste your key</h3>
    <div class="panel">
      <p style="margin-top:0;">In any Claude Desktop chat, type:</p>
      <pre>/reva-turbo:revmyengine</pre>
      <p>The engine will greet you and notice it doesn't have a key yet.
      It'll ask you to paste one. Reply with:</p>
      <pre>/connect <span style="color:var(--accent);">&lt;paste your nk_... key here&gt;</span></pre>
      <p>The engine validates the key against the router, saves it to
      your local config, and tells you to quit &amp; reopen Claude
      Desktop (Cmd-Q, relaunch). That one restart is the only manual
      step — after it, say <em>"let's go"</em> and you're in.</p>
      <p class="muted" style="margin-bottom:0;">
        Behind the scenes: the plugin is connected to the shared
        Rev&nbsp;A workspace, so it asks exactly one question
        (<em>what's your role?</em>) and pulls company profile,
        partners, and pipelines from the router — no local setup.
      </p>
    </div>

    <p class="muted" style="margin-top:24px;">
      Need to do this from a terminal instead?
      <a href="https://github.com/mrdulasolutions/RevOps-RevAMfg#for-end-users-rev-a-pms" target="_blank" rel="noopener">CLI install flow →</a>
    </p>
  </div>
</main>
<script>
const form = document.getElementById('f');
const btn  = document.getElementById('btn');
const out  = document.getElementById('result');
const post = document.getElementById('post');
const s1 = document.getElementById('s1');
const s2 = document.getElementById('s2');
const mcpUrl = new URL('/mcp', location.href).toString();

// Case-insensitive regex matching the server's ALLOWED_EMAIL_DOMAINS. If
// the server set no allowlist, this regex is `IMPOSSIBLE\.DOMAIN` — any
// submission will fail client-side before the POST, which matches the
// fail-closed behavior of `_email_domain_allowed()` on the server.
const ALLOWED_DOMAIN_RE = new RegExp('@(?:__ALLOWED_DOMAINS_REGEX__)$', 'i');

form.addEventListener('submit', async (e) => {
  e.preventDefault();
  const emailVal = document.getElementById('email').value.trim();
  if (!ALLOWED_DOMAIN_RE.test(emailVal)) {
    out.classList.add('err'); out.style.display = 'block';
    out.innerHTML = '<strong>Email not allowed:</strong> use __ALLOWED_DOMAINS_TEXT__. ' +
      'Contact your admin if you need access under a different domain.';
    return;
  }
  btn.disabled = true; btn.textContent = 'Minting…';
  out.className = 'result'; out.style.display = 'none'; out.innerHTML = '';
  post.className = 'post';
  try {
    const r = await fetch('/signup', {
      method: 'POST',
      headers: {'Content-Type': 'application/json'},
      body: JSON.stringify({
        display_name: document.getElementById('name').value,
        email: emailVal,
        password: document.getElementById('password').value,
        signup_token: document.getElementById('token').value,
      })
    });
    const data = await r.json();
    if (!r.ok) throw new Error(data.detail || ('HTTP ' + r.status));
    out.style.display = 'block';
    out.innerHTML = `
      <h3>✓ You're in — welcome to Rev A Manufacturing</h3>
      <p class="muted" style="margin:0 0 10px;">Copy this key — it's shown once. If you lose it, ask the admin to mint a new one.</p>
      <pre>${data.api_key}</pre>
      <p style="margin:8px 0 0;"><span class="pill">workspace</span>${data.workspace_slug} &nbsp;
        <span class="pill">endpoint</span><code>${mcpUrl}</code></p>
      <p style="margin:14px 0 0;"><strong>Next:</strong> install the plugin (Step 2),
        run <code>/reva-turbo:revmyengine</code> in Claude Desktop, and paste the key
        back with <code>/connect ${data.api_key.slice(0,10)}…</code>. The plugin
        will do the rest.</p>
    `;
    post.className = 'post on';
    s1.classList.add('done'); s1.classList.remove('active');
    s2.classList.add('active');
    window.scrollTo({top: out.offsetTop - 20, behavior:'smooth'});
  } catch (err) {
    out.classList.add('err'); out.style.display = 'block';
    out.innerHTML = '<strong>Error:</strong> ' + (err.message || err);
  } finally {
    btn.disabled = false; btn.textContent = 'Mint my API key →';
  }
});
</script>
</body>
</html>"""


@router.get("/signup", response_class=HTMLResponse)
async def signup_page() -> HTMLResponse:
    if not SIGNUP_ENABLED:
        return HTMLResponse(
            "<h1>Signup not configured</h1><p>Ask the admin to set "
            "<code>REVA_SIGNUP_TOKEN</code> and <code>NAKATOMI_ADMIN_TOKEN</code> "
            "on the mcp-router service.</p>",
            status_code=503,
        )
    # Inject the domain allowlist so the form can show it inline and
    # provide an HTML5 pattern for the email field — catches typos
    # client-side before the POST round-trip.
    domains = sorted(ALLOWED_EMAIL_DOMAINS)
    domains_text = " or ".join(f"@{d}" for d in domains) if domains else ""
    # Build a regex that matches any of the allowed domains (case-insensitive
    # via the JS flag below). Each domain is escape-safe — only letters, dots,
    # hyphens expected, but we belt-and-suspenders with re.escape.
    import re as _re
    domain_alt = "|".join(_re.escape(d) for d in domains) if domains else "IMPOSSIBLE\\.DOMAIN"
    html = (
        SIGNUP_HTML
        .replace("__ALLOWED_DOMAINS_TEXT__", domains_text)
        .replace("__ALLOWED_DOMAINS_REGEX__", domain_alt)
    )
    return HTMLResponse(html)
