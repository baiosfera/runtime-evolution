#!/usr/bin/env bash
set -euo pipefail

PORT="${SERVER_PORT:-8085}"
API_KEY="${GLOBAL_API_KEY:-}"
INST="${EVOLUTION_INSTANCE:-${PROJECT_NAME:-default}}"
if [ -z "$INST" ] || [[ "$INST" == *'${'* ]]; then
  INST="default"
fi

ensure_default_instance() {
  if [ -z "$API_KEY" ] || [[ "$API_KEY" == *'${'* ]]; then
    echo "• [Evolution] GLOBAL_API_KEY unset; skipping auto-instance creation."
    return 0
  fi

  local i=0
  while [ "$i" -lt 45 ]; do
    if curl -fsS "http://127.0.0.1:${PORT}/server/ok" >/dev/null 2>&1; then
      break
    fi
    i=$((i + 1))
    sleep 1
  done

  local all_json
  all_json=$(curl -fsS -H "apikey: ${API_KEY}" "http://127.0.0.1:${PORT}/instance/all" 2>/dev/null || echo "[]")
  if printf '%s' "$all_json" | grep -q "\"name\":\"${INST}\""; then
    echo "• [Evolution] Instance '${INST}' already present."
    return 0
  fi

  local payload
  payload=$(printf '{"name":"%s","token":"%s"}' "$INST" "$API_KEY")
  if curl -fsS -X POST "http://127.0.0.1:${PORT}/instance/create" \
    -H "apikey: ${API_KEY}" \
    -H "Content-Type: application/json" \
    -d "$payload" >/dev/null 2>&1; then
    echo "• [Evolution] Created initial instance '${INST}' ready for QR/pair linking."
  else
    echo "• [Evolution] Instance bootstrap deferred (check DB or API key)." >&2
  fi
}

ensure_default_instance &
exec ./evolution
