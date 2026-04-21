#!/usr/bin/env bash
# Build reva-turbo-<version>.zip for Claude Desktop "Personal → Local uploads".
#
# The archive contains a single top-level directory `reva-turbo/` with the
# plugin's `.claude-plugin/plugin.json` at `reva-turbo/.claude-plugin/plugin.json`.
# This is the convention Desktop's uploader recognizes — a flat zip with the
# manifest at the archive root triggers "wrong format" on upload.
#
# We explicitly exclude dev cruft (`.git`, `node_modules`, `.DS_Store`,
# `__MACOSX`) and the build artifacts dir itself so the bundle stays small
# and deterministic.
#
# Usage:
#   ./build-bundle.sh           # -> dist/reva-turbo-<version>.zip
#   ./build-bundle.sh clean     # remove dist/
set -euo pipefail

PLUGIN_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VERSION="$(cat "$PLUGIN_ROOT/VERSION" | tr -d '[:space:]')"
DIST="$PLUGIN_ROOT/dist"
OUT="$DIST/reva-turbo-${VERSION}.zip"
PLUGIN_SLUG="reva-turbo"

if [ "${1:-}" = "clean" ]; then
  rm -rf "$DIST"
  echo "Cleaned $DIST"
  exit 0
fi

command -v zip >/dev/null 2>&1 || { echo "zip is required but not installed" >&2; exit 1; }

# Sanity: manifest must exist and declare the version we're stamping
if ! grep -q "\"version\": \"$VERSION\"" "$PLUGIN_ROOT/.claude-plugin/plugin.json"; then
  echo "VERSION ($VERSION) does not match .claude-plugin/plugin.json" >&2
  exit 1
fi

mkdir -p "$DIST"
rm -f "$OUT"

# Stage the plugin into a temp dir under the canonical slug, then zip that
# directory. This produces `reva-turbo/.claude-plugin/plugin.json` inside the
# archive — not a flat root — which is what Desktop's loader expects.
STAGE="$(mktemp -d -t reva-turbo-bundle)"
trap 'rm -rf "$STAGE"' EXIT

# rsync copies everything except the exclusions. We deliberately bring in
# dotfiles (.claude-plugin/, .claude/) — they're part of the plugin.
rsync -a \
  --exclude 'dist/' \
  --exclude '.git/' \
  --exclude '.git' \
  --exclude 'node_modules/' \
  --exclude '.DS_Store' \
  --exclude '__MACOSX' \
  --exclude 'build-bundle.sh' \
  --exclude '*.pyc' \
  --exclude '__pycache__/' \
  "$PLUGIN_ROOT/" "$STAGE/$PLUGIN_SLUG/"

# Belt-and-suspenders: strip stray AppleDouble and .DS_Store files the
# rsync filter might miss on nested mounts.
find "$STAGE" \( -name '.DS_Store' -o -name '._*' \) -delete 2>/dev/null || true

( cd "$STAGE" && zip -rq "$OUT" "$PLUGIN_SLUG" )

SIZE="$(du -h "$OUT" | cut -f1)"
TOP_ENTRIES="$(unzip -l "$OUT" | awk 'NR>3 && $NF!="" {print $NF}' | awk -F/ '{print $1}' | sort -u)"
echo "Built $OUT ($SIZE)"
echo "Top-level entries:  $TOP_ENTRIES"
echo
echo "Upload via Claude Desktop → Plugins → Personal → Local uploads → +"
