#!/usr/bin/env bash
# tradeinsights-check.sh — Check TradeInsights.ai API availability
# Usage: bash tradeinsights-check.sh
# Output: JSON with available (true/false), api_key_configured (true/false)
set -euo pipefail

REVA-TURBO_CONFIG="${HOME}/.claude/skills/reva-turbo/bin/reva-turbo-config"
TI_API_KEY=""
TI_AVAILABLE="false"

# Check for API key in config
if [ -x "$REVA-TURBO_CONFIG" ]; then
  TI_API_KEY=$("$REVA-TURBO_CONFIG" get tradeinsights_api_key 2>/dev/null || echo "")
fi

if [ -n "$TI_API_KEY" ] && [ "$TI_API_KEY" != "" ]; then
  TI_AVAILABLE="true"
fi

echo "{\"available\":$TI_AVAILABLE,\"api_key_configured\":$([ -n \"$TI_API_KEY\" ] && echo 'true' || echo 'false')}"
