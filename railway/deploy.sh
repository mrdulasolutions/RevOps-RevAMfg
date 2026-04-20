#!/usr/bin/env bash
# REVA-OPS Railway deploy — one Railway project, router + nakatomi + automem.
#
# Requires: railway CLI (>=4.0) logged in, jq, openssl.
#
# Usage:
#   ./railway/deploy.sh --project-name reva-ops --admin-email you@reva.com
#
# On success, prints the public MCP URL and the seeded admin API key.

set -euo pipefail

PROJECT_NAME="reva-ops"
ADMIN_EMAIL=""
ADMIN_PASSWORD=""
WORKSPACE_SLUG="reva"
WORKSPACE_NAME="Rev A Manufacturing"
REGION="us-east4-eqdc4a"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --project-name)    PROJECT_NAME="$2"; shift 2 ;;
    --admin-email)     ADMIN_EMAIL="$2"; shift 2 ;;
    --admin-password)  ADMIN_PASSWORD="$2"; shift 2 ;;
    --workspace-slug)  WORKSPACE_SLUG="$2"; shift 2 ;;
    --workspace-name)  WORKSPACE_NAME="$2"; shift 2 ;;
    --region)          REGION="$2"; shift 2 ;;
    -h|--help)
      sed -n '1,20p' "$0"; exit 0 ;;
    *)
      echo "unknown flag: $1" >&2; exit 2 ;;
  esac
done

if [[ -z "$ADMIN_EMAIL" ]]; then
  echo "--admin-email required" >&2; exit 2
fi
if [[ -z "$ADMIN_PASSWORD" ]]; then
  ADMIN_PASSWORD=$(openssl rand -hex 12)
  echo "→ generated admin password: $ADMIN_PASSWORD"
fi

command -v railway >/dev/null || { echo "railway CLI not installed" >&2; exit 1; }
command -v jq       >/dev/null || { echo "jq not installed" >&2; exit 1; }
command -v openssl  >/dev/null || { echo "openssl not installed" >&2; exit 1; }

echo "→ creating project: $PROJECT_NAME"
railway init --name "$PROJECT_NAME"

echo "→ provisioning plugins (Postgres, FalkorDB, Qdrant)"
railway add --database postgres
# FalkorDB + Qdrant are custom images — provisioned via the template import.
# If your Railway version of the CLI lacks template import, run:
#   railway up --service falkordb --docker-image falkordb/falkordb:latest
#   railway up --service qdrant   --docker-image qdrant/qdrant:latest

echo "→ deploying services from railway/template.yaml"
railway up --config railway/template.yaml

echo "→ waiting for nakatomi-backend to report healthy"
for _ in $(seq 1 30); do
  if railway status --service nakatomi-backend --json 2>/dev/null | jq -e '.status == "SUCCESS"' >/dev/null; then
    break
  fi
  sleep 5
done

echo "→ seeding admin user + Rev A pipeline/custom fields"
NAKATOMI_INTERNAL="http://nakatomi-backend.railway.internal:8000"
railway run --service nakatomi-backend -- \
  python -m scripts.seed \
    --email "$ADMIN_EMAIL" --password "$ADMIN_PASSWORD" \
    --workspace-name "$WORKSPACE_NAME" --workspace-slug "$WORKSPACE_SLUG"

# Capture the API key that the seed script prints (stdout).
API_KEY=$(railway logs --service nakatomi-backend --lines 100 \
  | grep -oE 'nk_[A-Za-z0-9_-]+' | tail -n1 || true)

# Apply Rev A schema overlay
railway run --service nakatomi-backend -- \
  python -c "import httpx, json; import subprocess" >/dev/null 2>&1 || true

railway run --service mcp-router -- \
  sh -c "pip install httpx >/dev/null && python /app/../nakatomi-backend/seed/reva.py \
    --api-url $NAKATOMI_INTERNAL --token $API_KEY" || \
  echo "⚠ seed/reva.py apply failed — run manually after deploy"

PUBLIC_URL=$(railway domain --service mcp-router --json 2>/dev/null | jq -r '.[0].domain' || echo "unknown")

cat <<EOF

✓ REVA-OPS deployed

   Public MCP URL:   https://$PUBLIC_URL/mcp
   Admin email:      $ADMIN_EMAIL
   Admin password:   $ADMIN_PASSWORD
   API key:          ${API_KEY:-<check 'railway logs --service nakatomi-backend'>}

Point the REVA-TURBO plugin at the new stack:

   curl -fsSL https://raw.githubusercontent.com/mrdulasolutions/RevOps-RevAMfg/main/plugin/install.sh \\
     | REVA_MCP_URL=https://$PUBLIC_URL/mcp REVA_API_KEY=$API_KEY bash

EOF
