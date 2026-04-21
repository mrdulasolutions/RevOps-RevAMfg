#!/usr/bin/env bash
# reva-mcp-launch.sh — stdio MCP launcher for the REVA-TURBO plugin.
#
# Claude Desktop spawns this on startup as the `reva` MCP server. It bridges
# Desktop's stdio transport to the Rev A MCP router over HTTP via the
# `mcp-remote` npm helper.
#
# Why a launcher (and not `${user_config.*}` substitution directly in
# plugin.json like a normal plugin): non-technical PMs don't want to
# navigate Plugins → Settings in Desktop to paste a URL and a key. With
# a launcher, the revmyengine skill can write the creds to a file on
# disk after the PM pastes their `nk_...` key into chat, and Desktop
# re-picks them up on the next app start. One paste, one restart — no
# Settings hunting.
#
# Credential precedence (first match wins):
#   1. $REVA_MCP_URL / $REVA_API_KEY in the environment (CI / advanced)
#   2. ~/.reva-turbo/state/mcp-credentials.env (written by the skill)
#   3. Baked-in production default URL (key must still come from 1 or 2)
#
# If no api_key is found, we exec mcp-remote with an empty bearer token.
# The router returns 401 on initialize, Desktop shows the server as
# errored, and the revmyengine preflight catches it and walks the PM
# through the paste flow. This is the right failure mode — loud enough
# that revmyengine notices, quiet enough not to scare the PM.
set -u

CRED_FILE="${REVA_CRED_FILE:-$HOME/.reva-turbo/state/mcp-credentials.env}"

# Load creds file if present. `set -a` exports everything it defines.
if [ -f "$CRED_FILE" ]; then
  set -a
  # shellcheck disable=SC1090
  . "$CRED_FILE"
  set +a
fi

# Fall back to the Rev A production router if the PM hasn't overridden it.
# The /mcp suffix matches the router's mount point in services/mcp-router.
: "${REVA_MCP_URL:=https://mcp-router-production-460a.up.railway.app/mcp}"
: "${REVA_API_KEY:=}"

# Hand off to mcp-remote. `-y` bypasses the npx prompt, which would hang
# Desktop's stdio transport waiting for a y/n that never comes.
exec npx -y mcp-remote \
  "$REVA_MCP_URL" \
  --header "Authorization: Bearer ${REVA_API_KEY}"
