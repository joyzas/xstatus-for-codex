#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
APP_PATH="$ROOT_DIR/build/xStatus for Codex.app"
EXEC_PATH="$APP_PATH/Contents/MacOS/xStatus for Codex"

if ! pgrep -f "/Applications/Codex.app/Contents" >/dev/null 2>&1; then
  pkill -f "$EXEC_PATH" 2>/dev/null || true
  pkill -f "Codex Status Widget.app/Contents/MacOS/Codex Status Widget" 2>/dev/null || true
  exit 0
fi

if pgrep -f "$EXEC_PATH" >/dev/null 2>&1; then
  exit 0
fi

if [[ ! -d "$APP_PATH" ]]; then
  "$ROOT_DIR/scripts/build-app.sh" >/dev/null
fi

open "$APP_PATH"
