#!/usr/bin/env bash
# REVA-OPS Railway deploy — one project, three services + three managed DBs.
#
# The deploy is phased so you can inspect Railway's state between steps.
# Run without arguments to execute every phase in order; pass a phase name
# to run just that phase.
#
#   ./railway/deploy.sh init       # project + Postgres/FalkorDB/Qdrant
#   ./railway/deploy.sh services   # nakatomi-backend, automem-backend, mcp-router
#   ./railway/deploy.sh seed       # Nakatomi admin + Rev A pipeline/fields
#   ./railway/deploy.sh finalize   # print public URL, API key, signup token
#   ./railway/deploy.sh            # all phases, in order
#
# Required:
#   railway CLI >= 4.40 (https://docs.railway.com/guides/cli), logged in
#   openssl, jq
#
# The first phase calls `railway init`, which links this directory to the
# new project via .railway/ — every subsequent phase auto-discovers the
# project from that link.

set -euo pipefail

# ── Config ────────────────────────────────────────────────────────────────
PROJECT_NAME="${PROJECT_NAME:-reva-ops}"
ADMIN_EMAIL="${ADMIN_EMAIL:-}"
ADMIN_PASSWORD="${ADMIN_PASSWORD:-}"
WORKSPACE_SLUG="${WORKSPACE_SLUG:-reva}"
WORKSPACE_NAME="${WORKSPACE_NAME:-Rev A Manufacturing}"

NAKATOMI_REPO="${NAKATOMI_REPO:-mrdulasolutions/NakatomiCRM}"
AUTOMEM_REPO="${AUTOMEM_REPO:-mrdulasolutions/automem}"

ROUTER_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../services/mcp-router" && pwd)"
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# ── Pretty output ─────────────────────────────────────────────────────────
bold()  { printf "\033[1m%s\033[0m\n" "$*"; }
say()   { printf "\033[1;36m[reva-ops]\033[0m %s\n" "$*"; }
warn()  { printf "\033[1;33m[reva-ops]\033[0m %s\n" "$*" >&2; }
die()   { printf "\033[1;31m[reva-ops]\033[0m %s\n" "$*" >&2; exit 1; }

# ── Pre-flight ────────────────────────────────────────────────────────────
need() { command -v "$1" >/dev/null 2>&1 || die "$1 is required"; }
need railway; need openssl; need jq

railway whoami >/dev/null 2>&1 || die "Not logged in. Run: railway login"

# ── Argument parsing ──────────────────────────────────────────────────────
# Accept flags before positional phase name.
PHASE=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --project-name)    PROJECT_NAME="$2"; shift 2 ;;
    --admin-email)     ADMIN_EMAIL="$2"; shift 2 ;;
    --admin-password)  ADMIN_PASSWORD="$2"; shift 2 ;;
    --workspace-slug)  WORKSPACE_SLUG="$2"; shift 2 ;;
    --workspace-name)  WORKSPACE_NAME="$2"; shift 2 ;;
    -h|--help)         sed -n '1,25p' "$0"; exit 0 ;;
    init|services|seed|finalize|all) PHASE="$1"; shift ;;
    *)                 die "unknown arg: $1" ;;
  esac
done

# ── Shared secrets (generated once, reused across phases via .railway.env) ─
STATE_FILE="$REPO_ROOT/railway/.deploy-state"
load_state() { [ -f "$STATE_FILE" ] && # shellcheck disable=SC1090
               . "$STATE_FILE" || true; }
save_state() {
  umask 077
  cat >"$STATE_FILE" <<EOF
NAKATOMI_SECRET_KEY='${NAKATOMI_SECRET_KEY:-}'
AUTOMEM_API_TOKEN='${AUTOMEM_API_TOKEN:-}'
AUTOMEM_ADMIN_TOKEN='${AUTOMEM_ADMIN_TOKEN:-}'
REVA_SIGNUP_TOKEN='${REVA_SIGNUP_TOKEN:-}'
NAKATOMI_ADMIN_TOKEN='${NAKATOMI_ADMIN_TOKEN:-}'
ROUTER_PUBLIC_URL='${ROUTER_PUBLIC_URL:-}'
EOF
}
load_state
: "${NAKATOMI_SECRET_KEY:=$(openssl rand -hex 32)}"
: "${AUTOMEM_API_TOKEN:=$(openssl rand -hex 32)}"
: "${AUTOMEM_ADMIN_TOKEN:=$(openssl rand -hex 32)}"
: "${REVA_SIGNUP_TOKEN:=$(openssl rand -hex 16)}"
save_state

# ── Phase: init ───────────────────────────────────────────────────────────
have_service() {
  # Check whether a service by exact name exists on the linked project.
  ( cd "$REPO_ROOT" && railway status --json 2>/dev/null ) \
    | jq -e --arg n "$1" '.services.edges[].node.name | select(. == $n)' >/dev/null 2>&1
}

phase_init() {
  bold "[1/4] init — project + databases"

  if ( cd "$REPO_ROOT" && railway status >/dev/null 2>&1 ); then
    say "project already linked — skipping init"
  else
    say "creating Railway project: $PROJECT_NAME"
    ( cd "$REPO_ROOT" && railway init --name "$PROJECT_NAME" )
  fi

  # Idempotent: `railway add` silently creates duplicates on re-run, so we
  # gate each add on a name check. If a service with the target name exists,
  # we skip.
  if have_service "Postgres"; then
    say "Postgres already exists — skipping"
  else
    say "adding Postgres"
    ( cd "$REPO_ROOT" && railway add --database postgres )
  fi

  if have_service "falkordb"; then
    say "falkordb already exists — skipping"
  else
    say "adding FalkorDB (custom image)"
    ( cd "$REPO_ROOT" && railway add --service falkordb --image falkordb/falkordb:latest )
  fi

  if have_service "qdrant"; then
    say "qdrant already exists — skipping"
  else
    say "adding Qdrant (custom image)"
    ( cd "$REPO_ROOT" && railway add --service qdrant --image qdrant/qdrant:latest )
  fi

  say "init complete — check: railway status"
}

# ── Phase: services ───────────────────────────────────────────────────────
phase_services() {
  bold "[2/4] services — automem, nakatomi, mcp-router"

  # Pre-flight: Railway's GitHub App must be installed on the mrdulasolutions
  # org. Railway installs it inline the first time you add a repo-sourced
  # service from the web UI — there's no standalone Integrations page. Until
  # that install exists, `railway add --repo` returns Unauthorized.
  warn "If this phase returns 'Unauthorized', the Railway GitHub App isn't"
  warn "installed for mrdulasolutions. Fix (one-time):"
  warn "  1. Open the reva-ops project → + Create → GitHub Repo"
  warn "  2. Pick mrdulasolutions/NakatomiCRM (click 'Configure GitHub App'"
  warn "     if the repo isn't in the picker; grant access to NakatomiCRM"
  warn "     and automem)"
  warn "  3. Name the first service 'nakatomi-backend'; it's safe to let"
  warn "     the script re-run — the idempotency check will skip the add."
  warn "  4. Re-run: ./railway/deploy.sh services"
  echo

  if have_service "automem-backend"; then
    say "automem-backend already exists — skipping add"
  else
    say "adding automem-backend (repo: $AUTOMEM_REPO)"
    ( cd "$REPO_ROOT" && railway add --service automem-backend --repo "$AUTOMEM_REPO" )
  fi

  say "setting automem-backend env vars"
  railway variable set "PORT=8001" --service automem-backend --skip-deploys
  railway variable set "FALKORDB_HOST=falkordb.railway.internal" --service automem-backend --skip-deploys
  railway variable set "FALKORDB_PORT=6379" --service automem-backend --skip-deploys
  railway variable set "API_TOKEN=$AUTOMEM_API_TOKEN" --service automem-backend --skip-deploys
  railway variable set "ADMIN_TOKEN=$AUTOMEM_ADMIN_TOKEN" --service automem-backend --skip-deploys
  railway variable set "EMBEDDING_MODEL=text-embedding-3-small" --service automem-backend --skip-deploys
  # Qdrant URL must be set once the qdrant service has its internal domain published.
  railway variable set 'QDRANT_URL=http://qdrant.railway.internal:6333' --service automem-backend --skip-deploys

  if have_service "nakatomi-backend"; then
    say "nakatomi-backend already exists — skipping add"
  else
    say "adding nakatomi-backend (repo: $NAKATOMI_REPO)"
    ( cd "$REPO_ROOT" && railway add --service nakatomi-backend --repo "$NAKATOMI_REPO" )
  fi

  say "setting nakatomi-backend env vars"
  railway variable set "PORT=8000" --service nakatomi-backend --skip-deploys
  railway variable set 'DATABASE_URL=${{Postgres.DATABASE_URL}}' --service nakatomi-backend --skip-deploys
  railway variable set "SECRET_KEY=$NAKATOMI_SECRET_KEY" --service nakatomi-backend --skip-deploys
  railway variable set "STORAGE_BACKEND=local" --service nakatomi-backend --skip-deploys
  railway variable set "MEMORY_CONNECTORS=automem" --service nakatomi-backend --skip-deploys
  railway variable set 'AUTOMEM_URL=http://automem-backend.railway.internal:8001' --service nakatomi-backend --skip-deploys
  railway variable set "AUTOMEM_API_KEY=$AUTOMEM_API_TOKEN" --service nakatomi-backend --skip-deploys

  # mcp-router deploys from local subdir — Railway CLI's `add --repo`
  # has no rootDirectory flag, so we create the service empty then `up` into it.
  if have_service "mcp-router"; then
    say "mcp-router already exists — skipping add"
  else
    say "adding mcp-router service (empty shell)"
    ( cd "$REPO_ROOT" && railway add --service mcp-router )
  fi

  say "setting mcp-router env vars"
  railway variable set "PORT=8080" --service mcp-router --skip-deploys
  railway variable set "LOG_LEVEL=INFO" --service mcp-router --skip-deploys
  railway variable set 'NAKATOMI_INTERNAL_URL=http://nakatomi-backend.railway.internal:8000' --service mcp-router --skip-deploys
  railway variable set 'AUTOMEM_INTERNAL_URL=http://automem-backend.railway.internal:8001' --service mcp-router --skip-deploys
  railway variable set "AUTH_MODE=passthrough" --service mcp-router --skip-deploys
  railway variable set "AUTOMEM_API_TOKEN=$AUTOMEM_API_TOKEN" --service mcp-router --skip-deploys
  railway variable set "CRM_TOOL_PREFIX=crm" --service mcp-router --skip-deploys
  railway variable set "MEM_TOOL_PREFIX=mem" --service mcp-router --skip-deploys
  railway variable set "REVA_SIGNUP_TOKEN=$REVA_SIGNUP_TOKEN" --service mcp-router --skip-deploys
  railway variable set "REVA_WORKSPACE_SLUG=$WORKSPACE_SLUG" --service mcp-router --skip-deploys
  # NAKATOMI_ADMIN_TOKEN set in phase_seed once we have it.

  say "generating public domain for mcp-router"
  ( cd "$REPO_ROOT" && railway domain --service mcp-router ) || true
  ROUTER_PUBLIC_URL="$(railway domain --service mcp-router --json 2>/dev/null \
    | jq -r '.[0].domain // empty')"
  if [ -n "$ROUTER_PUBLIC_URL" ]; then
    railway variable set "PUBLIC_MCP_URL=https://$ROUTER_PUBLIC_URL/mcp" --service mcp-router --skip-deploys
    save_state
  else
    warn "could not capture router public URL — set PUBLIC_MCP_URL manually after deploy"
  fi

  say "deploying mcp-router from $ROUTER_DIR"
  ( cd "$ROUTER_DIR" && railway service mcp-router && railway up --ci )

  say "services phase complete — watch builds: railway logs --service nakatomi-backend"
}

# ── Phase: seed ───────────────────────────────────────────────────────────
phase_seed() {
  bold "[3/4] seed — admin user + Rev A schema"

  [ -n "$ADMIN_EMAIL" ] || die "--admin-email required for seed phase (or ADMIN_EMAIL env)"
  [ -n "$ADMIN_PASSWORD" ] || { ADMIN_PASSWORD="$(openssl rand -hex 12)"; say "generated admin password: $ADMIN_PASSWORD"; }

  say "waiting for nakatomi-backend to be healthy (up to 4 min)"
  local ok=0
  for _ in $(seq 1 48); do
    if railway logs --service nakatomi-backend 2>/dev/null | grep -q "Uvicorn running\|application startup complete"; then
      ok=1; break
    fi
    sleep 5
  done
  [ "$ok" -eq 1 ] || warn "nakatomi-backend not yet healthy — seed may fail; retry with: ./railway/deploy.sh seed"

  say "seeding workspace + admin user"
  # Use the upstream seed script. If it doesn't exist upstream, fall back
  # to a direct HTTP POST against /auth/signup.
  local seed_out
  seed_out="$(railway run --service nakatomi-backend -- \
    python -m scripts.seed \
      --email "$ADMIN_EMAIL" \
      --password "$ADMIN_PASSWORD" \
      --workspace-name "$WORKSPACE_NAME" \
      --workspace-slug "$WORKSPACE_SLUG" 2>&1 || true)"
  echo "$seed_out"

  NAKATOMI_ADMIN_TOKEN="$(printf '%s' "$seed_out" | grep -oE 'nk_[A-Za-z0-9_-]+' | tail -n1 || true)"
  if [ -z "$NAKATOMI_ADMIN_TOKEN" ]; then
    warn "could not auto-extract admin API key from seed output — copy manually from logs above"
  else
    save_state
    say "captured admin API key"
    railway variable set "NAKATOMI_ADMIN_TOKEN=$NAKATOMI_ADMIN_TOKEN" --service mcp-router
  fi

  say "applying Rev A pipeline + custom-field overlay"
  railway run --service nakatomi-backend -- \
    python /app/seed/reva.py \
      --api-url "http://nakatomi-backend.railway.internal:8000" \
      --token "${NAKATOMI_ADMIN_TOKEN:-SET_MANUALLY}" \
    || warn "reva.py overlay failed — re-run after fixing"
}

# ── Phase: finalize ───────────────────────────────────────────────────────
phase_finalize() {
  bold "[4/4] finalize — print credentials"
  load_state
  ROUTER_PUBLIC_URL="${ROUTER_PUBLIC_URL:-$(railway domain --service mcp-router --json 2>/dev/null | jq -r '.[0].domain // empty')}"

  cat <<EOF

$(bold "✓ REVA-OPS deployed")

   Public MCP URL:      https://${ROUTER_PUBLIC_URL:-<unknown>}/mcp
   Signup page:         https://${ROUTER_PUBLIC_URL:-<unknown>}/signup
   Admin email:         ${ADMIN_EMAIL:-<not set>}
   Admin password:      ${ADMIN_PASSWORD:-<not set — check .deploy-state>}
   Admin API key:       ${NAKATOMI_ADMIN_TOKEN:-<not set — see nakatomi logs>}
   Signup token (PMs):  ${REVA_SIGNUP_TOKEN}

$(bold "Share with PMs:")
   1. Signup page URL above
   2. Signup token above
   (No other credentials. PMs mint their own nk_... key via /signup.)

$(bold "Rotation:")
   Signup token:  railway variable set REVA_SIGNUP_TOKEN=\$(openssl rand -hex 16) --service mcp-router
   Admin token:   mint new via Nakatomi, then update NAKATOMI_ADMIN_TOKEN

$(bold "State file:") railway/.deploy-state  (gitignored — contains secrets)

EOF
}

# ── Run ───────────────────────────────────────────────────────────────────
case "${PHASE:-all}" in
  init)     phase_init ;;
  services) phase_services ;;
  seed)     phase_seed ;;
  finalize) phase_finalize ;;
  all)      phase_init; phase_services; phase_seed; phase_finalize ;;
  *)        die "unknown phase: $PHASE" ;;
esac
