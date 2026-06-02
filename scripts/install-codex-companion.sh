#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
AGENT_ID="local.xstatus.codex.companion"
COLLECTOR_AGENT_ID="local.xstatus.codex.collector"
OLD_AGENT_ID="local.codex.status-widget.companion"
OLD_COLLECTOR_AGENT_ID="local.codex.status-widget.collector"
PLIST_PATH="$HOME/Library/LaunchAgents/$AGENT_ID.plist"
COLLECTOR_PLIST_PATH="$HOME/Library/LaunchAgents/$COLLECTOR_AGENT_ID.plist"
SUPPORT_DIR="$HOME/Library/Application Support/CodexStatusWidget"
SCRIPT_PATH="$SUPPORT_DIR/codex-companion.sh"
COLLECTOR_SCRIPT_PATH="$SUPPORT_DIR/codex-status-collector.sh"
USER_APP_DIR="$HOME/Applications"
USER_APP_PATH="$USER_APP_DIR/xStatus for Codex.app"
OLD_USER_APP_PATH="$USER_APP_DIR/Codex Status Widget.app"
UID_VALUE="$(id -u)"

mkdir -p "$HOME/Library/LaunchAgents"
mkdir -p "$SUPPORT_DIR"
mkdir -p "$USER_APP_DIR"
"$ROOT_DIR/scripts/build-app.sh" >/dev/null

launchctl bootout "gui/$UID_VALUE" "$HOME/Library/LaunchAgents/$OLD_AGENT_ID.plist" >/dev/null 2>&1 || true
launchctl bootout "gui/$UID_VALUE" "$HOME/Library/LaunchAgents/$OLD_COLLECTOR_AGENT_ID.plist" >/dev/null 2>&1 || true
rm -f "$HOME/Library/LaunchAgents/$OLD_AGENT_ID.plist" "$HOME/Library/LaunchAgents/$OLD_COLLECTOR_AGENT_ID.plist"
pkill -f "xStatus for Codex.app/Contents/MacOS/xStatus for Codex" 2>/dev/null || true
pkill -f "Codex Status Widget.app/Contents/MacOS/Codex Status Widget" 2>/dev/null || true

rm -rf "$USER_APP_PATH"
rm -rf "$OLD_USER_APP_PATH"
cp -R "$ROOT_DIR/build/xStatus for Codex.app" "$USER_APP_PATH"
xattr -cr "$USER_APP_PATH"
codesign --force --deep --sign - "$USER_APP_PATH" >/dev/null 2>&1 || true

cat > "$SCRIPT_PATH" <<SCRIPT
#!/usr/bin/env bash
set -euo pipefail

APP_PATH="$USER_APP_PATH"
EXEC_PATH="\$APP_PATH/Contents/MacOS/xStatus for Codex"

if ! pgrep -f "/Applications/Codex.app/Contents" >/dev/null 2>&1; then
  pkill -f "xStatus for Codex.app/Contents/MacOS/xStatus for Codex" 2>/dev/null || true
  exit 0
fi

if pgrep -f "\$EXEC_PATH" >/dev/null 2>&1; then
  exit 0
fi

open "\$APP_PATH"
SCRIPT

chmod +x "$SCRIPT_PATH"
cp "$ROOT_DIR/scripts/codex-status-collector.sh" "$COLLECTOR_SCRIPT_PATH"
chmod +x "$COLLECTOR_SCRIPT_PATH"

cat > "$PLIST_PATH" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>$AGENT_ID</string>
  <key>ProgramArguments</key>
  <array>
    <string>/bin/bash</string>
    <string>$SCRIPT_PATH</string>
  </array>
  <key>RunAtLoad</key>
  <true/>
  <key>StartInterval</key>
  <integer>15</integer>
  <key>StandardOutPath</key>
  <string>/tmp/$AGENT_ID.out.log</string>
  <key>StandardErrorPath</key>
  <string>/tmp/$AGENT_ID.err.log</string>
</dict>
</plist>
PLIST

launchctl bootout "gui/$UID_VALUE" "$PLIST_PATH" >/dev/null 2>&1 || true
launchctl bootstrap "gui/$UID_VALUE" "$PLIST_PATH"
launchctl enable "gui/$UID_VALUE/$AGENT_ID"
launchctl kickstart -k "gui/$UID_VALUE/$AGENT_ID"

cat > "$COLLECTOR_PLIST_PATH" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>$COLLECTOR_AGENT_ID</string>
  <key>ProgramArguments</key>
  <array>
    <string>/bin/bash</string>
    <string>$COLLECTOR_SCRIPT_PATH</string>
  </array>
  <key>RunAtLoad</key>
  <true/>
  <key>StartInterval</key>
  <integer>3</integer>
  <key>StandardOutPath</key>
  <string>/tmp/$COLLECTOR_AGENT_ID.out.log</string>
  <key>StandardErrorPath</key>
  <string>/tmp/$COLLECTOR_AGENT_ID.err.log</string>
</dict>
</plist>
PLIST

launchctl bootout "gui/$UID_VALUE" "$COLLECTOR_PLIST_PATH" >/dev/null 2>&1 || true
launchctl bootstrap "gui/$UID_VALUE" "$COLLECTOR_PLIST_PATH"
launchctl enable "gui/$UID_VALUE/$COLLECTOR_AGENT_ID"
launchctl kickstart -k "gui/$UID_VALUE/$COLLECTOR_AGENT_ID"

echo "$PLIST_PATH"
