#!/usr/bin/env bash
# REVA-TURBO Claude Desktop self-heal / fresh-install.
#
# Target scenario: PM is on a stale pre-2.1.1 install (plugin.json still
# uses `${user_config.*}` substitution instead of our bash launcher) and
# Claude Desktop's uploader won't overwrite it. This script removes the
# old install, drops in the latest release zip, and writes the PM's
# API key to `~/.reva-turbo/state/mcp-credentials.env` so the launcher
# picks it up on the next Claude Desktop launch.
#
# Hands-free usage (Claude Cowork / Control-your-Mac can run this via
# osascript's `do shell script`, Claude Code can run it via the Bash
# tool, and PMs on a terminal can paste it directly):
#
#   curl -fsSL https://raw.githubusercontent.com/mrdulasolutions/RevOps-RevAMfg/main/plugin/scripts/desktop-install.sh \
#     | REVA_API_KEY=nk_yourkey bash
#
# Env overrides:
#   REVA_API_KEY         (required) nk_... bearer minted at /signup
#   REVA_MCP_URL         override router URL (default: rev a production)
#   REVA_RELEASE_TAG     install a specific tag (default: latest)
#   REVA_NO_DOWNLOAD     skip zip download (testing only)
#   REVA_INSTALL_ROOT    override plugins root (default:
#                        ~/Library/Application Support/Claude/plugins/
#                        marketplaces/local-desktop-app-uploads)
#                        If the dir doesn't exist we fall back to
#                        ~/.claude/plugins/... which is where newer
#                        Desktop builds actually keep uploads.
#
# Exit codes: 0 ok, 2 bad args, 3 download failed, 4 fs failed.
set -uo pipefail

REPO="mrdulasolutions/RevOps-RevAMfg"
TAG="${REVA_RELEASE_TAG:-latest}"
DEFAULT_MCP_URL="https://mcp-router-production-460a.up.railway.app/mcp"
REVA_MCP_URL="${REVA_MCP_URL:-$DEFAULT_MCP_URL}"

# Pretty-ish output that still reads fine inside AppleScript's `do shell
# script` capture. No tput — we may not be on a tty.
say()  { printf "[reva] %s\n" "$*"; }
warn() { printf "[reva] WARN: %s\n" "$*" >&2; }
die()  { printf "[reva] ERROR: %s\n" "$*" >&2; exit "${2:-1}"; }

# ── 1. Arg sanity ────────────────────────────────────────────────────
REVA_API_KEY="${REVA_API_KEY:-}"
if [ -z "$REVA_API_KEY" ]; then
  die "REVA_API_KEY not set. Get a key at ${REVA_MCP_URL%/mcp*}/signup and re-run with REVA_API_KEY=nk_... bash." 2
fi
case "$REVA_API_KEY" in
  nk_*) ;;
  *) warn "REVA_API_KEY does not start with 'nk_' — proceeding anyway. If the router rejects the key, mint a fresh one at ${REVA_MCP_URL%/mcp*}/signup." ;;
esac

# ── 2. Find the plugins root ─────────────────────────────────────────
# Claude Desktop writes uploads to one of two paths depending on build:
#   macOS (most builds):  ~/Library/Application Support/Claude/plugins/marketplaces/local-desktop-app-uploads
#   Newer builds:         ~/.claude/plugins/marketplaces/local-desktop-app-uploads
# We try the explicit override first, then both defaults. If neither
# exists (Claude Desktop never launched) we create the Library one and
# trust Desktop to adopt it on next launch.
guess_plugins_root() {
  if [ -n "${REVA_INSTALL_ROOT:-}" ]; then
    echo "$REVA_INSTALL_ROOT"; return
  fi
  for cand in \
    "$HOME/Library/Application Support/Claude/plugins/marketplaces/local-desktop-app-uploads" \
    "$HOME/.claude/plugins/marketplaces/local-desktop-app-uploads"
  do
    [ -d "$cand" ] && { echo "$cand"; return; }
  done
  # Neither exists. Default to the Library path — that's where macOS
  # Claude Desktop keeps uploads on current builds.
  echo "$HOME/Library/Application Support/Claude/plugins/marketplaces/local-desktop-app-uploads"
}
PLUGINS_ROOT="$(guess_plugins_root)"
INSTALL_DIR="$PLUGINS_ROOT/reva-turbo"

say "plugins root: $PLUGINS_ROOT"
mkdir -p "$PLUGINS_ROOT" || die "cannot create $PLUGINS_ROOT" 4

# ── 3. Download the release zip ──────────────────────────────────────
TMPDIR_REVA="$(mktemp -d)"
trap 'rm -rf "$TMPDIR_REVA"' EXIT
ZIP="$TMPDIR_REVA/reva-turbo.zip"

if [ -z "${REVA_NO_DOWNLOAD:-}" ]; then
  if [ "$TAG" = "latest" ]; then
    # GitHub's /releases/latest redirects to the versioned URL — follow with -L.
    URL="https://github.com/$REPO/releases/latest/download/reva-turbo-$(
      curl -fsSL "https://api.github.com/repos/$REPO/releases/latest" \
        | grep -oE '"tag_name"[[:space:]]*:[[:space:]]*"[^"]+"' \
        | head -1 | sed 's/.*"\(v[^"]*\)"/\1/' | sed 's/^v//'
    ).zip"
  else
    VER="${TAG#v}"
    URL="https://github.com/$REPO/releases/download/${TAG}/reva-turbo-${VER}.zip"
  fi

  say "downloading: $URL"
  if ! curl -fsSL --retry 3 --max-time 60 "$URL" -o "$ZIP"; then
    die "download failed — check network / tag name ($TAG)" 3
  fi
else
  warn "REVA_NO_DOWNLOAD set — expecting a preseeded $ZIP"
  [ -f "$ZIP" ] || die "REVA_NO_DOWNLOAD set but no zip at $ZIP" 3
fi

# Sanity: zip must contain reva-turbo/.claude-plugin/plugin.json
if ! unzip -l "$ZIP" 2>/dev/null | grep -q 'reva-turbo/\.claude-plugin/plugin\.json'; then
  die "downloaded zip does not look like a reva-turbo release" 3
fi

# ── 4. Quit Claude Desktop if it's running ───────────────────────────
# Desktop locks files while running. osascript exits quietly if the
# app isn't open, so this is safe to run unconditionally.
if command -v osascript >/dev/null 2>&1; then
  if osascript -e 'tell application "System Events" to (name of processes) contains "Claude"' 2>/dev/null | grep -qi true; then
    say "quitting Claude Desktop (will relaunch at end)"
    osascript -e 'tell application "Claude" to quit' 2>/dev/null || true
    # Give it up to 6s to actually exit.
    for _ in 1 2 3 4 5 6; do
      osascript -e 'tell application "System Events" to (name of processes) contains "Claude"' 2>/dev/null | grep -qi true || break
      sleep 1
    done
  fi
fi

# ── 5. Remove stale install, extract new one ─────────────────────────
if [ -d "$INSTALL_DIR" ]; then
  say "removing stale install: $INSTALL_DIR"
  # Preserve the PM's credential file if for some reason it lives inside
  # the plugin dir. Canonically it lives at ~/.reva-turbo/state/ but
  # defense-in-depth.
  BACKUP="$TMPDIR_REVA/preserved-creds"
  if [ -f "$INSTALL_DIR/.reva-turbo/state/mcp-credentials.env" ]; then
    mkdir -p "$BACKUP"
    cp "$INSTALL_DIR/.reva-turbo/state/mcp-credentials.env" "$BACKUP/"
  fi
  rm -rf "$INSTALL_DIR" || die "could not remove $INSTALL_DIR — check permissions" 4
fi

say "extracting release into $PLUGINS_ROOT"
if ! unzip -q "$ZIP" -d "$PLUGINS_ROOT"; then
  die "unzip failed" 4
fi

# Make sure bin scripts are executable (zip preserves bits but some
# extraction tools drop them).
chmod +x "$INSTALL_DIR/bin/"* 2>/dev/null || true
chmod +x "$INSTALL_DIR/scripts/"*.sh 2>/dev/null || true

# ── 6. Write the credentials file ────────────────────────────────────
STATE_DIR="$HOME/.reva-turbo/state"
mkdir -p "$STATE_DIR"
CRED_FILE="$STATE_DIR/mcp-credentials.env"

# mode 600 — contains a bearer token.
cat > "$CRED_FILE" <<EOF
# REVA MCP credentials — auto-written by desktop-install.sh
# Read by plugin/bin/reva-mcp-launch.sh at Claude Desktop startup.
# Safe to delete; mint a new key at ${REVA_MCP_URL%/mcp*}/signup
REVA_MCP_URL="$REVA_MCP_URL"
REVA_API_KEY="$REVA_API_KEY"
EOF
chmod 600 "$CRED_FILE" || warn "could not chmod 600 $CRED_FILE"

# Sanity ping the router — catches a typo'd key before the PM restarts
# Claude Desktop and gets a silent MCP failure instead.
say "pinging router with the new key"
PING_URL="${REVA_MCP_URL%/mcp*}/healthz"
if command -v curl >/dev/null 2>&1; then
  PING_STATUS="$(curl -fsSL -o /dev/null -w '%{http_code}' --max-time 10 \
    -H "Authorization: Bearer $REVA_API_KEY" "$PING_URL" 2>/dev/null || echo "000")"
  case "$PING_STATUS" in
    200|204) say "router reachable (HTTP $PING_STATUS)" ;;
    401|403) warn "router rejected the key ($PING_STATUS). Mint a fresh one at ${REVA_MCP_URL%/mcp*}/signup and re-run." ;;
    000)     warn "router unreachable — no network? will retry on Desktop launch." ;;
    *)       warn "router returned HTTP $PING_STATUS — install continues, but double-check the URL." ;;
  esac
fi

# ── 7. Relaunch Claude Desktop ───────────────────────────────────────
if command -v open >/dev/null 2>&1; then
  say "relaunching Claude Desktop"
  open -a "Claude" 2>/dev/null || open -a "Claude Desktop" 2>/dev/null || \
    warn "could not relaunch Claude automatically — open it yourself."
fi

cat <<EOF

  ════════════════════════════════════════════════════════
   REVA-TURBO installed on Claude Desktop
  ════════════════════════════════════════════════════════

   Plugin dir:  $INSTALL_DIR
   Creds file:  $CRED_FILE
   MCP URL:     $REVA_MCP_URL

   In Claude Desktop, run:
       /reva-turbo:revmyengine

   The engine will greet you and say 'let's go' to start.

EOF
