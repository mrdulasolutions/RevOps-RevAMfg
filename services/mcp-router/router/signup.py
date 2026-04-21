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
<html lang="en" data-theme="dark">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>REV A MFG · Join the RevAOps engine</title>
<meta name="theme-color" content="#0a0a0a">
<style>
  /* Palette pulled from revamfg.com: warm near-black background, cream
     copy, burnt-orange (#bf6a3f) CTA, warm gray muted. Mirrors the
     homepage's data-theme="dark" look so the signup flow feels like an
     extension of the brand rather than a separate tool. */
  :root {
    --bg:#0a0a0a;
    --bg-warm:#1c1410;
    --fg:#f4eade;
    --fg-dim:#c9c4b3;
    --muted:#847c6c;
    --accent:#bf6a3f;
    --accent-hover:#d17a4e;
    --accent-dim:#7a4529;
    --card:#17110d;
    --card-2:#0f0b08;
    --border:#2a1f17;
    --border-bright:#3d2d21;
    --ok:#a3c49a;
    --ok-bg:#17221a;
    --ok-border:#2a3d2e;
    --err:#e58b7c;
    --err-bg:#2a1714;
    --err-border:#4a2a24;
    --warn-bg:#261a0f;
    --warn-fg:#e8c48f;
    --warn-border:#4a3420;
  }
  *,*::before,*::after { box-sizing:border-box; }
  html,body { margin:0; padding:0; background:var(--bg); color:var(--fg);
    font:15px/1.55 -apple-system,BlinkMacSystemFont,"Inter","Segoe UI",
    system-ui,sans-serif; -webkit-font-smoothing:antialiased;
    text-rendering:optimizeLegibility; }
  /* Subtle warm vignette — echoes the homepage hero's dark-warm tone
     without overpowering the form. */
  body::before {
    content:""; position:fixed; inset:0; pointer-events:none; z-index:-1;
    background:
      radial-gradient(ellipse 90% 60% at 50% -10%, rgba(191,106,63,0.08), transparent 60%),
      radial-gradient(ellipse 60% 80% at 100% 100%, rgba(191,106,63,0.04), transparent 70%);
  }
  main { max-width:640px; margin:6vh auto 4vh; padding:24px; }

  /* Logo block — "REV A MFG" uppercase with heavy tracking mirrors the
     homepage wordmark; the "RevAOps Engine" sub is the product line. */
  .brand { margin-bottom:32px; }
  .logo { font-size:11px; font-weight:700; letter-spacing:0.32em;
    color:var(--fg); text-transform:uppercase; margin:0 0 6px;
    display:flex; align-items:center; gap:10px; }
  .logo::after { content:""; flex:1; height:1px; background:var(--border-bright); }
  h1.title { font-size:34px; font-weight:600; letter-spacing:-0.02em;
    margin:0 0 8px; line-height:1.1; color:var(--fg); }
  h1.title em { font-style:normal; color:var(--accent); }
  p.sub { color:var(--fg-dim); margin:0; font-size:15px;
    max-width:52ch; }
  p.tagline { color:var(--muted); margin:4px 0 0; font-size:12px;
    letter-spacing:0.12em; text-transform:uppercase; }

  /* Step tracker — warm-stone pills with copper highlight when active. */
  .steps { display:flex; gap:8px; margin:28px 0 20px; }
  .step { flex:1; padding:10px 12px; background:var(--card-2);
    border-radius:4px; font-size:12px; color:var(--muted);
    border:1px solid var(--border); display:flex; align-items:center;
    gap:10px; transition:border-color 0.15s, color 0.15s; }
  .step .n { width:20px; height:20px; border-radius:50%;
    background:transparent; border:1px solid var(--border-bright);
    color:var(--muted); font-weight:600; font-size:11px;
    display:inline-flex; align-items:center; justify-content:center;
    transition:all 0.15s; }
  .step.active { color:var(--fg); border-color:var(--accent); }
  .step.active .n { background:var(--accent); color:#0a0a0a; border-color:var(--accent); }
  .step.done { color:var(--fg-dim); border-color:var(--accent-dim); }
  .step.done .n { background:var(--accent-dim); color:var(--fg); border-color:var(--accent-dim); }

  form, .panel { background:var(--card); padding:24px; border-radius:6px;
    border:1px solid var(--border); }
  form { box-shadow:0 1px 0 rgba(191,106,63,0.04) inset; }
  label { display:block; font-size:11px; color:var(--muted);
    margin:18px 0 6px; font-weight:600; letter-spacing:0.08em;
    text-transform:uppercase; }
  label:first-of-type { margin-top:0; }
  label .hint { color:var(--muted); font-weight:400; text-transform:none;
    letter-spacing:0; margin-left:6px; font-size:11px; }
  input { width:100%; padding:12px 14px; border:1px solid var(--border);
    background:var(--card-2); color:var(--fg); border-radius:4px;
    font:inherit; transition:border-color 0.15s, background 0.15s; }
  input::placeholder { color:var(--muted); opacity:0.7; }
  input:focus { outline:none; border-color:var(--accent);
    background:#0a0a0a; }
  button { margin-top:24px; width:100%; padding:14px;
    background:var(--accent); color:#0a0a0a; border:0; border-radius:4px;
    font-weight:700; font-size:14px; letter-spacing:0.05em;
    text-transform:uppercase; cursor:pointer;
    transition:background 0.15s, transform 0.05s;
    font-family:inherit; }
  button:hover:not(:disabled) { background:var(--accent-hover); }
  button:active:not(:disabled) { transform:translateY(1px); }
  button:disabled { opacity:0.5; cursor:progress; background:var(--accent-dim); }

  .result { margin-top:20px; padding:20px; border-radius:6px;
    background:var(--ok-bg); border:1px solid var(--ok-border); display:none; }
  .result.err { background:var(--err-bg); border-color:var(--err-border); color:var(--err); }
  .result h3 { margin:0 0 10px; font-size:16px; color:var(--fg);
    letter-spacing:-0.01em; }
  .result.err h3, .result.err strong { color:var(--err); }
  code { background:var(--card-2); padding:3px 7px; border-radius:3px;
    user-select:all; font-family:"SF Mono","JetBrains Mono",
    ui-monospace,monospace; font-size:13px; word-break:break-all;
    color:var(--fg); border:1px solid var(--border); }
  pre { background:var(--card-2); padding:14px 16px; border-radius:4px;
    overflow-x:auto; margin:10px 0; font-size:13px; user-select:all;
    font-family:"SF Mono","JetBrains Mono",ui-monospace,monospace;
    color:var(--fg); border:1px solid var(--border); }
  .muted { color:var(--muted); font-size:13px; }
  .pill { display:inline-block; background:var(--card-2); padding:4px 10px;
    border-radius:999px; font-size:10px; color:var(--muted);
    margin-right:6px; letter-spacing:0.08em; text-transform:uppercase;
    border:1px solid var(--border); font-weight:600; }

  .hygiene { margin-top:14px; padding:16px 18px; border-radius:4px;
    background:var(--warn-bg); border:1px solid var(--warn-border);
    color:var(--warn-fg); font-size:13px; line-height:1.55; }
  .hygiene strong { color:#f4d9a8; display:block; margin-bottom:4px;
    font-size:12px; letter-spacing:0.06em; text-transform:uppercase; }
  .hygiene code { background:rgba(0,0,0,0.25); color:var(--warn-fg);
    border-color:var(--warn-border); }

  .section-head { margin:32px 0 10px; font-size:11px; font-weight:700;
    letter-spacing:0.2em; text-transform:uppercase; color:var(--accent);
    display:flex; align-items:center; gap:12px; }
  .section-head::after { content:""; flex:1; height:1px;
    background:linear-gradient(to right, var(--accent-dim), transparent); }
  .section-head h3 { margin:0; font-size:18px; font-weight:600;
    color:var(--fg); letter-spacing:-0.01em; text-transform:none; }

  .post { display:none; }
  .post.on { display:block; }
  .post ol { padding-left:22px; margin:10px 0; }
  .post li { margin:12px 0; color:var(--fg-dim); }
  .post li strong { color:var(--fg); }
  .post p { color:var(--fg-dim); }

  footer { margin-top:40px; padding-top:20px;
    border-top:1px solid var(--border); font-size:11px; color:var(--muted);
    letter-spacing:0.06em; text-transform:uppercase;
    display:flex; justify-content:space-between; align-items:center; gap:10px; }
  footer .fa { color:var(--fg-dim); }

  a { color:var(--accent); text-decoration:none;
    border-bottom:1px solid transparent; transition:border-color 0.15s; }
  a:hover { border-bottom-color:var(--accent); }

  @media (max-width:520px) {
    main { padding:20px 16px; margin-top:3vh; }
    h1.title { font-size:26px; }
    .steps { flex-direction:column; }
    .step { font-size:13px; }
    button { letter-spacing:0.03em; }
  }
</style>
</head>
<body>
<main>
  <div class="brand">
    <p class="logo">Rev&nbsp;A&nbsp;Mfg</p>
    <h1 class="title">Join the <em>RevAOps</em> engine</h1>
    <p class="sub">One minute from mint to working PM copilot — CRM, memory,
    and 48 skills wired into Claude Desktop.</p>
    <p class="tagline">Manufactured where it makes sense</p>
  </div>

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

    <label for="token">Signup token <span class="muted">(one-time code from your admin —
      <a href="mailto:matt@mrdula.solutions?subject=RevAOps%20signup%20token%20request&body=Hi%20Matt%2C%0D%0A%0D%0AI%27d%20like%20to%20join%20the%20Rev%20A%20Manufacturing%20RevAOps%20engine.%20Can%20you%20send%20me%20a%20one-time%20signup%20token%3F%0D%0A%0D%0AName%3A%0D%0AWork%20email%3A%0D%0ARole%3A%0D%0A%0D%0AThanks%21">don't have one?</a>)</span></label>
    <input id="token" required autocomplete="off" placeholder="e.g. 4f2a…" />

    <button type="submit" id="btn">Mint my API key →</button>
  </form>

  <div id="result" class="result"></div>

  <div id="post" class="post">
    <div class="section-head"><h3>Step 2 — Install the plugin</h3></div>
    <div class="panel">
      <p style="margin:0 0 14px;color:var(--fg);"><strong>Pick a path. Both end with the same working engine.</strong></p>

      <div style="padding:16px 18px;border-radius:4px;background:#1a1108;border:1px solid var(--accent-dim);margin-bottom:16px;">
        <p style="margin:0 0 8px;color:var(--accent);font-weight:700;font-size:11px;letter-spacing:0.12em;text-transform:uppercase;">
          Option A — Hands-free (recommended)
        </p>
        <p style="margin:0 0 10px;color:var(--fg-dim);">Paste this one-liner into Terminal. It downloads the latest zip,
          drops it into Claude Desktop's plugins dir, writes your key, and
          relaunches Desktop — no clicking through menus, safely re-runs
          if you already had an old version.</p>
        <pre id="oneliner">curl -fsSL https://raw.githubusercontent.com/mrdulasolutions/RevOps-RevAMfg/main/plugin/scripts/desktop-install.sh \
  | REVA_API_KEY=<span style="color:var(--accent);">&lt;your nk_... key from Step 1&gt;</span> bash</pre>
        <p class="muted" style="margin:10px 0 0;">Already inside Claude?
          If you have the <strong>Control your Mac</strong> connector
          enabled (Desktop → Settings → Connectors), just say
          <code>/heal</code> in any chat and Claude runs the one-liner
          for you — truly hands-free.</p>
      </div>

      <div style="padding:16px 18px;border-radius:4px;background:var(--card-2);border:1px solid var(--border);">
        <p style="margin:0 0 8px;color:var(--fg-dim);font-weight:700;font-size:11px;letter-spacing:0.12em;text-transform:uppercase;">
          Option B — Manual upload
        </p>
        <ol style="margin:0;padding-left:20px;color:var(--fg-dim);">
          <li style="margin:8px 0;"><strong>Download</strong> <code>reva-turbo-&lt;version&gt;.zip</code> (v2.1.2+) from
            <a href="https://github.com/mrdulasolutions/RevOps-RevAMfg/releases/latest"
               target="_blank" rel="noopener">GitHub Releases</a>. Don't unzip.</li>
          <li style="margin:8px 0;"><strong>If you already have RevAOps installed</strong> (v2.0.x or earlier), go to
            <strong>Plugins → Installed → RevAOps → ⋯ → Remove</strong>,
            then quit Desktop (<code>Cmd-Q</code>) and relaunch. The
            uploader doesn't auto-upgrade — skipping this leaves you on
            a stale launcher and the engine won't load your key.</li>
          <li style="margin:8px 0;"><strong>Claude Desktop → Plugins → Personal → Local uploads → +</strong>
            and drop in the zip. Click <strong>Enable</strong>. No
            settings to fill in — you'll paste your key in Step 3.</li>
        </ol>
      </div>

      <div class="hygiene">
        <strong>Remove any legacy Nakatomi / AutoMem connectors.</strong>
        If you previously added a standalone <em>Nakatomi</em> or
        <em>AutoMem</em> MCP connector under Claude Desktop → Settings →
        Connectors, remove it now. This plugin wraps both behind the
        router with prefixed tool names (<code>crm_*</code> /
        <code>mem_*</code> / <code>reva_*</code>). Duplicates show up as
        raw <code>search_contacts</code> / <code>memory_recall</code>
        names and break intent routing.
      </div>
    </div>

    <div class="section-head"><h3>Step 3 — Run the engine &amp; paste your key</h3></div>
    <div class="panel">
      <p style="margin-top:0;">In any Claude Desktop chat, type:</p>
      <pre>/reva-turbo:revmyengine</pre>
      <p>The engine greets you and notices it doesn't have a key yet.
      Reply with:</p>
      <pre>/connect <span style="color:var(--accent);">&lt;paste your nk_... key here&gt;</span></pre>
      <p>The engine validates the key against the router, saves it to
      your local config, and tells you to quit &amp; reopen Claude
      Desktop (<code>Cmd-Q</code>, relaunch). That one restart is the
      only manual step — after it, say <em>"let's go"</em> and you're in.</p>
      <p class="muted" style="margin-bottom:0;">
        Behind the scenes: the plugin is already connected to the shared
        Rev&nbsp;A workspace, so it asks exactly one question
        (<em>what's your role?</em>) and pulls company profile,
        partners, and pipelines from the router — no local setup.
      </p>
    </div>

    <div class="section-head"><h3>Already using HubSpot, Salesforce, Attio, or Pipedrive?</h3></div>
    <div class="panel">
      <p style="margin-top:0;">You can keep your existing CRM as the
      system of record. After Step 3, run:</p>
      <pre>/integrate hubspot   <span class="muted">(or salesforce / attio / pipedrive)</span></pre>
      <p style="margin-bottom:0;">Skills will then write to your CRM
      first and shadow-write to Nakatomi + AutoMem so the shared Rev&nbsp;A
      timeline stays complete. Reads prefer your CRM and fall back to
      Nakatomi if it's unreachable. Revert any time with
      <code>/integrate nakatomi</code>.</p>
    </div>

    <p class="muted" style="margin-top:28px;">
      Need to do this from a terminal instead?
      <a href="https://github.com/mrdulasolutions/RevOps-RevAMfg#for-end-users-rev-a-pms" target="_blank" rel="noopener">CLI install flow →</a>
    </p>
  </div>

  <footer>
    <span class="fa">Rev&nbsp;A Manufacturing · RevAOps</span>
    <span>v2.1.2</span>
  </footer>
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
      <h3>You're in — welcome to Rev&nbsp;A Manufacturing</h3>
      <p class="muted" style="margin:0 0 10px;">Copy this key — it's shown once. If you lose it, ask the admin to mint a new one.</p>
      <pre>${data.api_key}</pre>
      <p style="margin:10px 0 0;"><span class="pill">workspace</span><span style="color:var(--fg-dim);">${data.workspace_slug}</span> &nbsp;
        <span class="pill">endpoint</span><code>${mcpUrl}</code></p>
      <p style="margin:16px 0 0;color:var(--fg-dim);"><strong style="color:var(--fg);">Next:</strong> install the plugin. Easiest path:
        open Terminal and paste this one-liner (already has your key):</p>
      <pre style="margin-top:10px;">curl -fsSL https://raw.githubusercontent.com/mrdulasolutions/RevOps-RevAMfg/main/plugin/scripts/desktop-install.sh | REVA_API_KEY=${data.api_key} bash</pre>
      <p style="margin:10px 0 0;color:var(--fg-dim);">Prefer clicking? See <strong>Step 2 / Option B</strong> below for the manual upload path.</p>
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
