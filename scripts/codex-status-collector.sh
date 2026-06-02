#!/usr/bin/env bash
set -euo pipefail

CODEX_HOME="${CODEX_HOME:-$HOME/.codex}"
LOG_DB="$CODEX_HOME/logs_2.sqlite"
STATE_DB="$CODEX_HOME/state_5.sqlite"
PROCESS_FILE="$CODEX_HOME/process_manager/chat_processes.json"
STATUS_FILE="$CODEX_HOME/status-widget/status.json"
STATUS_DIR="$(dirname "$STATUS_FILE")"
WORKSPACE_LABEL="Codex"

mkdir -p "$STATUS_DIR"

json_string() {
  local value="$1"
  value="${value//\\/\\\\}"
  value="${value//\"/\\\"}"
  value="${value//$'\n'/\\n}"
  printf '"%s"' "$value"
}

write_status() {
  local status="$1"
  local title="$2"
  local detail="$3"
  local progress="${4:-}"
  local state_key_file="$STATUS_DIR/.last-state-key"
  local state_key="$status|$title|$detail|$progress|$WORKSPACE_LABEL"

  if [[ -f "$state_key_file" ]] && [[ "$(cat "$state_key_file")" == "$state_key" ]]; then
    exit 0
  fi

  local updated_at
  updated_at="$(date +"%Y-%m-%dT%H:%M:%S%z")"
  updated_at="${updated_at:0:22}:${updated_at:22:2}"

  local temp_file
  temp_file="$(mktemp "$STATUS_DIR/status.XXXXXX")"

  if [[ -n "$progress" ]]; then
    cat > "$temp_file" <<JSON
{
  "detail": $(json_string "$detail"),
  "progress": $progress,
  "status": $(json_string "$status"),
  "title": $(json_string "$title"),
  "updatedAt": $(json_string "$updated_at"),
  "workspace": $(json_string "$WORKSPACE_LABEL")
}
JSON
  else
    cat > "$temp_file" <<JSON
{
  "detail": $(json_string "$detail"),
  "status": $(json_string "$status"),
  "title": $(json_string "$title"),
  "updatedAt": $(json_string "$updated_at"),
  "workspace": $(json_string "$WORKSPACE_LABEL")
}
JSON
  fi

  mv "$temp_file" "$STATUS_FILE"
  printf '%s' "$state_key" > "$state_key_file"
}

if ! pgrep -f "/Applications/Codex.app/Contents" >/dev/null 2>&1; then
  write_status "idle" "Codex 未运行" "Codex 应用当前没有运行"
  exit 0
fi

if [[ ! -f "$LOG_DB" ]]; then
  write_status "unknown" "正在等待 Codex 日志" "尚未找到 Codex 本地日志数据库"
  exit 0
fi

active_commands=0
if [[ -f "$PROCESS_FILE" ]]; then
  active_commands="$(grep -c '"command"' "$PROCESS_FILE" 2>/dev/null || true)"
fi

latest=$(
  sqlite3 -readonly -separator '	' "$LOG_DB" "
ATTACH DATABASE '$STATE_DB' AS state;
WITH recent_thread AS (
  SELECT logs.thread_id
  FROM logs
  JOIN state.threads ON state.threads.id = logs.thread_id
  WHERE logs.thread_id IS NOT NULL
    AND state.threads.thread_source = 'user'
  ORDER BY logs.ts DESC, logs.ts_nanos DESC
  LIMIT 1
),
events AS (
  SELECT
    ts,
    feedback_log_body
  FROM logs
  WHERE thread_id = (SELECT thread_id FROM recent_thread)
    AND target IN (
      'codex_otel.trace_safe',
      'codex_core::session::turn',
      'codex_core::tools::router'
    )
  ORDER BY ts DESC, ts_nanos DESC
  LIMIT 250
)
SELECT
  COALESCE((SELECT thread_id FROM recent_thread), ''),
  COALESCE((SELECT max(ts) FROM events), 0),
  COALESCE((SELECT max(ts) FROM events WHERE feedback_log_body LIKE '%event.kind=response.completed%'), 0),
  COALESCE((SELECT max(ts) FROM events WHERE feedback_log_body LIKE '%event.kind=response.failed%' OR feedback_log_body LIKE '%response.failed%' OR feedback_log_body LIKE '%error%' OR feedback_log_body LIKE '%last_error%'), 0),
  COALESCE((SELECT max(ts) FROM events WHERE feedback_log_body LIKE '%function_call%' OR feedback_log_body LIKE '%ToolCall%' OR feedback_log_body LIKE '%dispatch_tool_call%'), 0),
  COALESCE((SELECT max(ts) FROM events WHERE feedback_log_body LIKE '%stream_request%' OR feedback_log_body LIKE '%response.output_text.delta%' OR feedback_log_body LIKE '%run_sampling_request%'), 0),
  COALESCE((SELECT max(ts) FROM events WHERE feedback_log_body LIKE '%has_pending_input=true%' OR feedback_log_body LIKE '%approval%' OR feedback_log_body LIKE '%requires_action%'), 0);
"
)

IFS=$'\t' read -r thread_id latest_ts completed_ts failed_ts tool_ts stream_ts waiting_ts <<< "$latest"
now_ts="$(date +%s)"

if [[ -z "$thread_id" || "$latest_ts" == "0" ]]; then
  write_status "idle" "Codex 当前空闲" "尚未检测到当前任务"
  exit 0
fi

if [[ -f "$STATE_DB" ]]; then
  thread_context="$(
    sqlite3 -readonly -separator '	' "$STATE_DB" "
SELECT
  COALESCE(NULLIF(cwd, ''), ''),
  COALESCE(NULLIF(title, ''), '')
FROM threads
WHERE id = '$thread_id'
LIMIT 1;
"
  )"
  IFS=$'\t' read -r thread_cwd thread_title <<< "$thread_context"

  if [[ -n "${thread_cwd:-}" ]]; then
    project_name="$(basename "$thread_cwd")"
  else
    project_name="Codex"
  fi

  if [[ -n "${thread_title:-}" ]]; then
    if (( ${#thread_title} > 18 )); then
      thread_title="${thread_title:0:18}..."
    fi
    WORKSPACE_LABEL="$project_name · $thread_title"
  else
    WORKSPACE_LABEL="$project_name"
  fi
fi

age=$((now_ts - latest_ts))

if (( failed_ts > completed_ts && failed_ts >= stream_ts )); then
  write_status "failed" "Codex 任务失败" "检测到最近任务出现错误"
elif (( waiting_ts >= completed_ts && waiting_ts >= stream_ts && waiting_ts > 0 )); then
  write_status "waiting" "Codex 等待确认" "检测到任务正在等待用户输入或授权" 0.75
elif (( active_commands > 0 )); then
  write_status "running" "Codex 正在工作" "检测到任务活动" 0.35
elif (( stream_ts > completed_ts && age <= 45 )); then
  write_status "running" "Codex 正在工作" "检测到任务活动" 0.35
elif (( completed_ts > 0 && completed_ts >= failed_ts )); then
  write_status "completed" "Codex 任务已完成" "最近一次任务已完成" 1
elif (( age > 90 )); then
  write_status "idle" "Codex 当前空闲" "最近没有检测到任务活动"
else
  write_status "running" "Codex 正在工作" "检测到任务活动" 0.35
fi
