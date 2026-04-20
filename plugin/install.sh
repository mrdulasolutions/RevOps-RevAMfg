#!/usr/bin/env bash
# REVA-TURBO one-line installer.
#
# Usage (fresh install, update, or reinstall — all idempotent):
#   curl -fsSL https://raw.githubusercontent.com/mrdulasolutions/RevOps-RevAMfg/main/plugin/install.sh | bash
#
# With an existing REVA-OPS Railway backend:
#   curl -fsSL https://.../plugin/install.sh | \
#     REVA_MCP_URL=https://<router>.up.railway.app/mcp \
#     REVA_API_KEY=nk_... \
#     bash
#
# What it does:
#   1. Clones (or fast-forwards) the repo to $REVA_TURBO_DIR (default ~/reva-turbo)
#   2. Creates ~/.reva-turbo/ state dirs
#   3. Symlinks the plugin into ~/.claude/skills/reva-turbo so Claude Code loads it
#   4. Makes bin scripts executable
#   5. npm-installs docx converter deps (if npm is present)
#   6. Writes default config.yaml
#   7. (If REVA_MCP_URL set) registers the REVA MCP server in ~/.claude/mcp.json
#
# Env overrides:
#   REVA_TURBO_DIR      Override clone location (default: ~/reva-turbo)
#   REVA_TURBO_REPO     Override repo URL (default: mrdulasolutions/RevOps-RevAMfg)
#   REVA_TURBO_REF      Override branch/tag (default: main)
#   REVA_TURBO_NO_NPM   If set, skip npm install (docx reports disabled)
#   REVA_TURBO_SKIP_GIT If set, skip clone/pull (use current $REVA_TURBO_DIR as-is; for CI)
#   REVA_MCP_URL        Public MCP URL (from railway/deploy.sh output)
#   REVA_API_KEY        Nakatomi bearer token (nk_...)

set -euo pipefail

REPO="${REVA_TURBO_REPO:-https://github.com/mrdulasolutions/RevOps-RevAMfg.git}"
REF="${REVA_TURBO_REF:-main}"
REVA_TURBO_DIR="${REVA_TURBO_DIR:-$HOME/reva-turbo}"
STATE_DIR="$HOME/.reva-turbo"
SKILLS_DIR="$HOME/.claude/skills/reva-turbo"
MCP_CONFIG="$HOME/.claude/mcp.json"

say() { printf "\033[1;36m[reva-turbo]\033[0m %s\n" "$*"; }
die() { printf "\033[1;31m[reva-turbo]\033[0m %s\n" "$*" >&2; exit 1; }

command -v git >/dev/null 2>&1 || die "git is required but not installed"

say "Installing REVA-TURBO ($REF) -> $REVA_TURBO_DIR"

# Detect whether we're pointing at the v2 monorepo (plugin/ lives as a subdir)
# or the flat v1 layout. Works for both during the transition.
find_plugin_root() {
  if [ -d "$1/plugin" ] && [ -d "$1/plugin/skills" ]; then
    echo "$1/plugin"
  else
    echo "$1"
  fi
}

# ── Step 1: clone or update ─────────────────────────────────────────────
if [ -n "${REVA_TURBO_SKIP_GIT:-}" ]; then
  say "REVA_TURBO_SKIP_GIT set — using existing tree at $REVA_TURBO_DIR"
  [ -d "$REVA_TURBO_DIR" ] || die "$REVA_TURBO_DIR does not exist"
elif [ -d "$REVA_TURBO_DIR/.git" ]; then
  say "Existing checkout found — updating"
  git -C "$REVA_TURBO_DIR" fetch --quiet origin "$REF"
  git -C "$REVA_TURBO_DIR" checkout --quiet "$REF"
  git -C "$REVA_TURBO_DIR" pull --ff-only --quiet origin "$REF" || die "git pull failed — resolve conflicts in $REVA_TURBO_DIR"
elif [ -e "$REVA_TURBO_DIR" ]; then
  die "$REVA_TURBO_DIR exists and is not a git checkout. Move or remove it, or set REVA_TURBO_DIR."
else
  git clone --quiet --branch "$REF" "$REPO" "$REVA_TURBO_DIR"
fi

PLUGIN_ROOT="$(find_plugin_root "$REVA_TURBO_DIR")"
say "Plugin root: $PLUGIN_ROOT"

# ── Step 2: state dirs ──────────────────────────────────────────────────
mkdir -p "$STATE_DIR"/{sessions,analytics,state,reports/REVA-TURBO-Reports,contributor-logs,users}

# ── Step 3: symlink into Claude Code skills ─────────────────────────────
mkdir -p "$HOME/.claude/skills"
if [ -L "$SKILLS_DIR" ]; then
  rm "$SKILLS_DIR"
elif [ -d "$SKILLS_DIR" ]; then
  backup="${SKILLS_DIR}.bak.$(date +%Y%m%d%H%M%S)"
  say "Backing up existing $SKILLS_DIR -> $backup"
  mv "$SKILLS_DIR" "$backup"
fi
ln -s "$PLUGIN_ROOT" "$SKILLS_DIR"

# ── Step 4: chmod ───────────────────────────────────────────────────────
chmod +x "$PLUGIN_ROOT/bin/"* 2>/dev/null || true
find "$PLUGIN_ROOT/skills" -type f -name '*.sh' -exec chmod +x {} \; 2>/dev/null || true
find "$PLUGIN_ROOT/skills" -type d -name 'bin' -exec chmod -R +x {} \; 2>/dev/null || true

# ── Step 5: docx converter deps ─────────────────────────────────────────
if [ -z "${REVA_TURBO_NO_NPM:-}" ] && command -v npm >/dev/null 2>&1; then
  pkg_dir="$PLUGIN_ROOT/skills/reva-turbo-docx/scripts"
  if [ -f "$pkg_dir/package.json" ]; then
    ( cd "$pkg_dir" && npm install --silent --no-fund --no-audit --loglevel=error >/dev/null 2>&1 ) \
      && say "docx converter deps installed" \
      || say "docx deps failed (non-fatal; run 'cd $pkg_dir && npm install' manually)"
  fi
else
  say "Skipping npm install (docx report generation disabled)"
fi

# ── Step 6: default config ──────────────────────────────────────────────
CONFIG_CMD="$PLUGIN_ROOT/bin/reva-turbo-config"
if [ -x "$CONFIG_CMD" ] && [ ! -f "$STATE_DIR/config.yaml" ]; then
  "$CONFIG_CMD" set telemetry off
  "$CONFIG_CMD" set proactive true
  "$CONFIG_CMD" set report_format docx
  "$CONFIG_CMD" set crm_type reva-mcp
  if [ "$(uname)" = "Darwin" ]; then
    "$CONFIG_CMD" set platform mac
  else
    "$CONFIG_CMD" set platform linux
  fi
  say "Default config written to $STATE_DIR/config.yaml"
fi

# If REVA_MCP_URL / REVA_API_KEY provided, persist them to config too
if [ -n "${REVA_MCP_URL:-}" ] && [ -x "$CONFIG_CMD" ]; then
  "$CONFIG_CMD" set reva_mcp_url "$REVA_MCP_URL"
  say "Saved reva_mcp_url to config.yaml"
fi
if [ -n "${REVA_API_KEY:-}" ] && [ -x "$CONFIG_CMD" ]; then
  "$CONFIG_CMD" set reva_api_key "$REVA_API_KEY"
  say "Saved reva_api_key to config.yaml"
fi

# ── Step 6a: interactive signup wizard ──────────────────────────────────
# If REVA_MCP_URL is set but REVA_API_KEY is not, offer to mint one. The
# router hosts /signup that takes {name, email, password, signup_token}
# and returns an API key. We POST directly so the whole flow happens in
# the terminal.
if [ -n "${REVA_MCP_URL:-}" ] && [ -z "${REVA_API_KEY:-}" ] && [ -t 0 ]; then
  # Derive the signup URL from the MCP URL (strip trailing /mcp* suffix).
  SIGNUP_URL="${REVA_MCP_URL%/mcp*}/signup"
  say "No REVA_API_KEY provided — running signup wizard."
  say "  Signup endpoint: $SIGNUP_URL"

  printf "Your name            : "; read -r REVA_NAME
  printf "Work email           : "; read -r REVA_EMAIL
  printf "Password (12+ chars) : "; stty -echo 2>/dev/null; read -r REVA_PASSWORD; stty echo 2>/dev/null; printf "\n"
  printf "Signup token         : "; read -r REVA_TOKEN

  if [ -z "${REVA_NAME}" ] || [ -z "${REVA_EMAIL}" ] || [ -z "${REVA_PASSWORD}" ] || [ -z "${REVA_TOKEN}" ]; then
    say "Signup skipped — one or more fields empty. Re-run with REVA_API_KEY=... to finish."
  elif command -v python3 >/dev/null 2>&1; then
    REVA_API_KEY="$(python3 - "$SIGNUP_URL" "$REVA_NAME" "$REVA_EMAIL" "$REVA_PASSWORD" "$REVA_TOKEN" <<'PY'
import json, sys, urllib.request, urllib.error
url, name, email, password, token = sys.argv[1:]
body = json.dumps({
    "display_name": name, "email": email,
    "password": password, "signup_token": token,
}).encode()
req = urllib.request.Request(url, data=body, headers={"Content-Type": "application/json"}, method="POST")
try:
    with urllib.request.urlopen(req, timeout=30) as r:
        data = json.loads(r.read())
        print(data["api_key"])
except urllib.error.HTTPError as e:
    body = e.read().decode(errors="replace")
    sys.stderr.write(f"signup failed: {e.code} {body}\n")
    sys.exit(1)
except Exception as e:
    sys.stderr.write(f"signup failed: {e}\n")
    sys.exit(1)
PY
)"
    if [ -n "$REVA_API_KEY" ]; then
      say "✓ API key minted and will be saved to ~/.claude/mcp.json"
      [ -x "$CONFIG_CMD" ] && "$CONFIG_CMD" set reva_api_key "$REVA_API_KEY"
    else
      say "Signup failed — see error above. Retry later with REVA_API_KEY=... set."
    fi
  else
    say "python3 not found — cannot run signup wizard. Visit $SIGNUP_URL in your browser instead."
  fi
fi

# ── Step 7: register REVA MCP in Claude Code's mcp.json ─────────────────
# Only when both URL and key are set. We write JSON by hand (no jq
# dependency) using a tiny Python one-liner if Python is available, else
# falling back to a simple append-or-replace pattern.
if [ -n "${REVA_MCP_URL:-}" ] && [ -n "${REVA_API_KEY:-}" ]; then
  if command -v python3 >/dev/null 2>&1; then
    mkdir -p "$(dirname "$MCP_CONFIG")"
    python3 - "$MCP_CONFIG" "$REVA_MCP_URL" "$REVA_API_KEY" <<'PY'
import json, os, sys
path, url, key = sys.argv[1], sys.argv[2], sys.argv[3]
cfg = {}
if os.path.exists(path):
    try:
        with open(path) as f:
            cfg = json.load(f)
    except Exception:
        cfg = {}
cfg.setdefault("mcpServers", {})
cfg["mcpServers"]["reva"] = {
    "type": "http",
    "url": url,
    "headers": {"Authorization": f"Bearer {key}"},
}
with open(path, "w") as f:
    json.dump(cfg, f, indent=2)
PY
    say "Registered REVA MCP server in $MCP_CONFIG"
  else
    say "python3 not found — skipping MCP registration. Add manually:"
    cat <<EOF

    "reva": {
      "type": "http",
      "url": "$REVA_MCP_URL",
      "headers": { "Authorization": "Bearer $REVA_API_KEY" }
    }

EOF
  fi
else
  say "REVA_MCP_URL / REVA_API_KEY not set — skipping MCP registration."
  say "  (Deploy the backend with railway/deploy.sh, then re-run with those env vars.)"
fi

# ── Done ────────────────────────────────────────────────────────────────
VERSION="$(cat "$PLUGIN_ROOT/VERSION" 2>/dev/null | tr -d '[:space:]' || echo unknown)"
cat <<EOF

  ════════════════════════════════════════════════════════
   REVA-TURBO v$VERSION installed
  ════════════════════════════════════════════════════════

   Plugin:    $SKILLS_DIR -> $PLUGIN_ROOT
   State:     $STATE_DIR
   Reports:   $STATE_DIR/reports/REVA-TURBO-Reports/
$( [ -n "${REVA_MCP_URL:-}" ] && echo "   MCP:       $REVA_MCP_URL" )

   Next: restart Claude Code, then run
       /reva-turbo:revmyengine

   Recommended model: Sonnet 4.6 (Opus 4.7 over-engineers
   routine PM tasks — see .claude/settings.json).

EOF
