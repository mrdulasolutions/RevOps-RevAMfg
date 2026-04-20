#!/usr/bin/env bash
# Build reva-turbo-<version>.zip for Claude Desktop "Personal → Local uploads".
#
# The ZIP unpacks with `.claude-plugin/plugin.json` at the archive root, which
# is what Desktop's plugin loader expects. We explicitly exclude dev cruft
# (`.git`, `node_modules`, `.DS_Store`) and the build artifacts dir itself
# so the bundle stays small and deterministic.
#
# Usage:
#   ./build-bundle.sh           # -> dist/reva-turbo-<version>.zip
#   ./build-bundle.sh clean     # remove dist/
set -euo pipefail

PLUGIN_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VERSION="$(cat "$PLUGIN_ROOT/VERSION" | tr -d '[:space:]')"
DIST="$PLUGIN_ROOT/dist"
OUT="$DIST/reva-turbo-${VERSION}.zip"

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

# Build from inside PLUGIN_ROOT so paths in the archive are relative to the plugin root.
# Explicit excludes keep the bundle small and reproducible.
cd "$PLUGIN_ROOT"
zip -rq "$OUT" . \
  -x "dist/*" \
  -x "*.git/*" -x "*.git" \
  -x "*/node_modules/*" -x "node_modules/*" \
  -x "*.DS_Store" \
  -x "build-bundle.sh" \
  -x "*.pyc" -x "*__pycache__*"

SIZE="$(du -h "$OUT" | cut -f1)"
echo "Built $OUT ($SIZE)"
echo
echo "Upload via Claude Desktop → Plugins → Personal → Local uploads → +"
