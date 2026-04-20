#!/usr/bin/env bash
# voice-check.sh — Read PM's voice profile
# Usage: bash voice-check.sh [--pm <pm-slug>]
# Output: JSON with profile_exists, pm_slug, key voice dimensions
set -euo pipefail

REVA_TURBO_CONFIG="${HOME}/.claude/skills/reva-turbo/bin/reva-turbo-config"
PM_SLUG=""

# Parse arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    --pm)
      PM_SLUG="$2"
      shift 2
      ;;
    *)
      PM_SLUG="$1"
      shift
      ;;
  esac
done

# If no PM specified, try to get default from config
if [ -z "$PM_SLUG" ] && [ -x "$REVA_TURBO_CONFIG" ]; then
  DEFAULT_PM=$("$REVA_TURBO_CONFIG" get default_pm 2>/dev/null || echo "")
  if [ -n "$DEFAULT_PM" ]; then
    # Convert name to slug: lowercase, replace spaces with hyphens
    PM_SLUG=$(echo "$DEFAULT_PM" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | tr -cd 'a-z0-9-')
  fi
fi

if [ -z "$PM_SLUG" ]; then
  echo '{"profile_exists":false,"reason":"no_pm_specified"}'
  exit 0
fi

VOICE_FILE="${HOME}/.reva-turbo/users/${PM_SLUG}/voice-profile.yaml"
PREFS_FILE="${HOME}/.reva-turbo/users/${PM_SLUG}/preferences.yaml"

if [ ! -f "$VOICE_FILE" ]; then
  echo "{\"profile_exists\":false,\"pm_slug\":\"${PM_SLUG}\",\"reason\":\"no_profile_file\"}"
  exit 0
fi

# Extract key dimensions from voice profile (simple grep-based parsing)
TONE=$(grep '^  tone:' "$VOICE_FILE" 2>/dev/null | head -1 | awk '{print $2}' || echo "5")
FORMALITY=$(grep '^  formality:' "$VOICE_FILE" 2>/dev/null | head -1 | awk '{print $2}' || echo "5")
GREETING=$(grep '^  greeting_style:' "$VOICE_FILE" 2>/dev/null | head -1 | sed 's/.*: *"//' | sed 's/"//' || echo "Hi")
SIGNOFF=$(grep '^  signoff_style:' "$VOICE_FILE" 2>/dev/null | head -1 | sed 's/.*: *"//' | sed 's/"//' || echo "Best regards,")
EMAIL_LEN=$(grep '^  email_length:' "$VOICE_FILE" 2>/dev/null | head -1 | sed 's/.*: *"//' | sed 's/"//' || echo "medium")
DETAIL=$(grep '^  detail_level:' "$VOICE_FILE" 2>/dev/null | head -1 | sed 's/.*: *"//' | sed 's/"//' || echo "standard")
HAS_PREFS="false"
[ -f "$PREFS_FILE" ] && HAS_PREFS="true"

echo "{\"profile_exists\":true,\"pm_slug\":\"${PM_SLUG}\",\"tone\":${TONE},\"formality\":${FORMALITY},\"greeting\":\"${GREETING}\",\"signoff\":\"${SIGNOFF}\",\"email_length\":\"${EMAIL_LEN}\",\"detail_level\":\"${DETAIL}\",\"has_preferences\":${HAS_PREFS}}"
