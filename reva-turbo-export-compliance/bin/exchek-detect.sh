#!/usr/bin/env bash
# exchek-detect.sh — Detect ExChek engine installation and tier
# Usage: bash exchek-detect.sh
# Output: JSON with installed (true/false), tier (enterprise/community/none), path
set -euo pipefail

EXCHEK_INSTALLED="false"
EXCHEK_TIER="none"
EXCHEK_PATH=""

# Check primary locations
for CHECK_DIR in \
  "$HOME/.claude/skills/exchek" \
  "$HOME/.claude/skills/exchekinc" \
  "$HOME/.claude/skills/ExChek" \
  "$HOME/.claude/skills/exchek-skills"; do
  if [ -d "$CHECK_DIR" ]; then
    EXCHEK_INSTALLED="true"
    EXCHEK_PATH="$CHECK_DIR"
    # Check tier
    if [ -f "$CHECK_DIR/.enterprise" ] || \
       ([ -f "$CHECK_DIR/LICENSE" ] && grep -qi "enterprise" "$CHECK_DIR/LICENSE" 2>/dev/null); then
      EXCHEK_TIER="enterprise"
    else
      EXCHEK_TIER="community"
    fi
    break
  fi
done

# Check for exchek-classify subdirectory pattern
if [ "$EXCHEK_INSTALLED" = "false" ]; then
  CLASSIFY_DIR=$(find "$HOME/.claude/skills" -maxdepth 3 -name "exchek-classify" -type d 2>/dev/null | head -1)
  if [ -n "$CLASSIFY_DIR" ]; then
    EXCHEK_INSTALLED="true"
    EXCHEK_PATH="$(dirname "$CLASSIFY_DIR")"
    EXCHEK_TIER="community"
  fi
fi

# Output JSON
echo "{\"installed\":$EXCHEK_INSTALLED,\"tier\":\"$EXCHEK_TIER\",\"path\":\"$EXCHEK_PATH\"}"
