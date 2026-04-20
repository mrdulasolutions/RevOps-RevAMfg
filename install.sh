#!/usr/bin/env bash
# REVA-TURBO one-line installer.
#
# Usage (fresh install, update, or reinstall — all idempotent):
#   curl -fsSL https://raw.githubusercontent.com/mrdulasolutions/RevOps-RevAMfg/main/install.sh | bash
#
# Or from a local clone:
#   bash install.sh
#
# What it does:
#   1. Clones (or fast-forwards) the repo to $REVA_TURBO_DIR (default ~/reva-turbo)
#   2. Creates ~/.reva-turbo/ state dirs
#   3. Symlinks the repo into ~/.claude/skills/reva-turbo so Claude Code loads it
#   4. Makes bin scripts executable
#   5. npm-installs docx converter deps (if npm is present)
#   6. Writes default config.yaml
#
# Env overrides:
#   REVA_TURBO_DIR      Override clone location (default: ~/reva-turbo)
#   REVA_TURBO_REPO     Override repo URL (default: mrdulasolutions/RevOps-RevAMfg)
#   REVA_TURBO_REF      Override branch/tag (default: main)
#   REVA_TURBO_NO_NPM   If set, skip npm install (docx reports disabled)
#   REVA_TURBO_SKIP_GIT If set, skip clone/pull (use current $REVA_TURBO_DIR as-is; for CI)

set -euo pipefail

REPO="${REVA_TURBO_REPO:-https://github.com/mrdulasolutions/RevOps-RevAMfg.git}"
REF="${REVA_TURBO_REF:-main}"
REVA_TURBO_DIR="${REVA_TURBO_DIR:-$HOME/reva-turbo}"
STATE_DIR="$HOME/.reva-turbo"
SKILLS_DIR="$HOME/.claude/skills/reva-turbo"

say() { printf "\033[1;36m[reva-turbo]\033[0m %s\n" "$*"; }
die() { printf "\033[1;31m[reva-turbo]\033[0m %s\n" "$*" >&2; exit 1; }

command -v git >/dev/null 2>&1 || die "git is required but not installed"

say "Installing REVA-TURBO ($REF) -> $REVA_TURBO_DIR"

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

# ── Step 2: state dirs ──────────────────────────────────────────────────
mkdir -p "$STATE_DIR"/{sessions,analytics,state,reports/REVA-TURBO-Reports,contributor-logs,users}

# ── Step 3: symlink into Claude Code skills ─────────────────────────────
mkdir -p "$HOME/.claude/skills"
if [ -L "$SKILLS_DIR" ]; then
  # Already a symlink — point it at the current checkout
  rm "$SKILLS_DIR"
elif [ -d "$SKILLS_DIR" ]; then
  backup="${SKILLS_DIR}.bak.$(date +%Y%m%d%H%M%S)"
  say "Backing up existing $SKILLS_DIR -> $backup"
  mv "$SKILLS_DIR" "$backup"
fi
ln -s "$REVA_TURBO_DIR" "$SKILLS_DIR"

# ── Step 4: chmod ───────────────────────────────────────────────────────
chmod +x "$REVA_TURBO_DIR/bin/"* 2>/dev/null || true
find "$REVA_TURBO_DIR/skills" -type f -name '*.sh' -exec chmod +x {} \; 2>/dev/null || true
find "$REVA_TURBO_DIR/skills" -type d -name 'bin' -exec chmod -R +x {} \; 2>/dev/null || true

# ── Step 5: docx converter deps ─────────────────────────────────────────
if [ -z "${REVA_TURBO_NO_NPM:-}" ] && command -v npm >/dev/null 2>&1; then
  pkg_dir="$REVA_TURBO_DIR/skills/reva-turbo-docx/scripts"
  if [ -f "$pkg_dir/package.json" ]; then
    ( cd "$pkg_dir" && npm install --silent --no-fund --no-audit --loglevel=error >/dev/null 2>&1 ) \
      && say "docx converter deps installed" \
      || say "docx deps failed (non-fatal; run 'cd $pkg_dir && npm install' manually)"
  fi
else
  say "Skipping npm install (docx report generation disabled)"
fi

# ── Step 6: default config ──────────────────────────────────────────────
CONFIG_CMD="$REVA_TURBO_DIR/bin/reva-turbo-config"
if [ ! -f "$STATE_DIR/config.yaml" ]; then
  "$CONFIG_CMD" set telemetry off
  "$CONFIG_CMD" set proactive true
  "$CONFIG_CMD" set report_format docx
  "$CONFIG_CMD" set crm_type none
  if [ "$(uname)" = "Darwin" ]; then
    "$CONFIG_CMD" set platform mac
  else
    "$CONFIG_CMD" set platform linux
  fi
  say "Default config written to $STATE_DIR/config.yaml"
fi

# ── Done ────────────────────────────────────────────────────────────────
VERSION="$(cat "$REVA_TURBO_DIR/VERSION" 2>/dev/null | tr -d '[:space:]' || echo unknown)"
cat <<EOF

  ════════════════════════════════════════════════════════
   REVA-TURBO v$VERSION installed
  ════════════════════════════════════════════════════════

   Skills:   $SKILLS_DIR -> $REVA_TURBO_DIR
   State:    $STATE_DIR
   Reports:  $STATE_DIR/reports/REVA-TURBO-Reports/

   Next: restart Claude Code, then run
       /reva-turbo:revmyengine

   Recommended model: Sonnet 4.6 (Opus 4.7 over-engineers
   routine PM tasks — see .claude/settings.json).

EOF
