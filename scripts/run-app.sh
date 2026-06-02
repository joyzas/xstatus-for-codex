#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
APP_PATH="$HOME/Applications/xStatus for Codex.app"
EXEC_NAME="xStatus for Codex"

"$ROOT_DIR/scripts/build-app.sh" >/dev/null
mkdir -p "$HOME/Applications"
rm -rf "$APP_PATH"
cp -R "$ROOT_DIR/build/xStatus for Codex.app" "$APP_PATH"
xattr -cr "$APP_PATH"
codesign --force --deep --sign - "$APP_PATH" >/dev/null 2>&1 || true
pkill -f "$EXEC_NAME.app/Contents/MacOS/$EXEC_NAME" 2>/dev/null || true
pkill -f "Codex Status Widget.app/Contents/MacOS/Codex Status Widget" 2>/dev/null || true
open "$APP_PATH"

echo "$APP_PATH"
