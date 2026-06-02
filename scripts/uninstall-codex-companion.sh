#!/usr/bin/env bash
set -euo pipefail

AGENT_ID="local.xstatus.codex.companion"
COLLECTOR_AGENT_ID="local.xstatus.codex.collector"
OLD_AGENT_ID="local.codex.status-widget.companion"
OLD_COLLECTOR_AGENT_ID="local.codex.status-widget.collector"
PLIST_PATH="$HOME/Library/LaunchAgents/$AGENT_ID.plist"
COLLECTOR_PLIST_PATH="$HOME/Library/LaunchAgents/$COLLECTOR_AGENT_ID.plist"
OLD_PLIST_PATH="$HOME/Library/LaunchAgents/$OLD_AGENT_ID.plist"
OLD_COLLECTOR_PLIST_PATH="$HOME/Library/LaunchAgents/$OLD_COLLECTOR_AGENT_ID.plist"
SUPPORT_DIR="$HOME/Library/Application Support/CodexStatusWidget"
UID_VALUE="$(id -u)"

launchctl bootout "gui/$UID_VALUE" "$PLIST_PATH" >/dev/null 2>&1 || true
launchctl bootout "gui/$UID_VALUE" "$COLLECTOR_PLIST_PATH" >/dev/null 2>&1 || true
launchctl bootout "gui/$UID_VALUE" "$OLD_PLIST_PATH" >/dev/null 2>&1 || true
launchctl bootout "gui/$UID_VALUE" "$OLD_COLLECTOR_PLIST_PATH" >/dev/null 2>&1 || true
rm -f "$PLIST_PATH"
rm -f "$COLLECTOR_PLIST_PATH"
rm -f "$OLD_PLIST_PATH"
rm -f "$OLD_COLLECTOR_PLIST_PATH"
rm -rf "$SUPPORT_DIR"

echo "已移除 xStatus for Codex 伴随启动"
