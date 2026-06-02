#!/usr/bin/env bash
set -euo pipefail

STATUS="${1:-running}"
TITLE="${2:-Codex 正在工作}"
DETAIL="${3:-任务状态已更新}"
PROGRESS="${4:-}"
WORKSPACE="$(basename "$(pwd)")"
TARGET_FILE="${CODEX_STATUS_FILE:-$HOME/.codex/status-widget/status.json}"
TARGET_DIR="$(dirname "$TARGET_FILE")"
UPDATED_AT="$(date +"%Y-%m-%dT%H:%M:%S%z")"
UPDATED_AT="${UPDATED_AT:0:22}:${UPDATED_AT:22:2}"

json_string() {
  local value="$1"
  value="${value//\\/\\\\}"
  value="${value//\"/\\\"}"
  value="${value//$'\n'/\\n}"
  printf '"%s"' "$value"
}

mkdir -p "$TARGET_DIR"

if [[ -n "$PROGRESS" ]]; then
  cat > "$TARGET_FILE" <<JSON
{
  "detail": $(json_string "$DETAIL"),
  "progress": $PROGRESS,
  "status": $(json_string "$STATUS"),
  "title": $(json_string "$TITLE"),
  "updatedAt": $(json_string "$UPDATED_AT"),
  "workspace": $(json_string "$WORKSPACE")
}
JSON
else
  cat > "$TARGET_FILE" <<JSON
{
  "detail": $(json_string "$DETAIL"),
  "status": $(json_string "$STATUS"),
  "title": $(json_string "$TITLE"),
  "updatedAt": $(json_string "$UPDATED_AT"),
  "workspace": $(json_string "$WORKSPACE")
}
JSON
fi

echo "$TARGET_FILE"
