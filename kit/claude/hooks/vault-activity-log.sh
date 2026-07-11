#!/bin/bash
# Vault Activity Log Hook
# PostToolUse hook for Claude Code — appends executed tool activity
# to today's Vault activity log file.
#
# Format: 06_Logs/Daily_Briefing/YYYY-MM-DD-activity.md
# Receives Claude Code hook JSON on stdin.
#
# Purpose: 意識しなくても記憶が残っていく仕組み

set -uo pipefail

CONF="$HOME/.claude/neo-kit.conf"
[ -f "$CONF" ] || exit 0
. "$CONF"
[ -n "${VAULT_PATH:-}" ] && [ -d "$VAULT_PATH" ] || exit 0
VAULT="$VAULT_PATH"

LOG_DIR="$VAULT/06_Logs/Daily_Briefing"
TODAY=$(date +%Y-%m-%d)
LOG_FILE="$LOG_DIR/${TODAY}-activity.md"
TIME=$(date +%H:%M:%S)

# Vault が同期されていない/見つからない時は静かに退避
if [ ! -d "$LOG_DIR" ]; then
  exit 0
fi

# stdin の JSON を読む
INPUT=$(cat)

# パース失敗時は何もしない
if ! TOOL=$(echo "$INPUT" | jq -r '.tool_name // "unknown"' 2>/dev/null); then
  exit 0
fi

# ツール別にサマリを構築
SUMMARY=""
case "$TOOL" in
  Bash)
    CMD=$(echo "$INPUT" | jq -r '.tool_input.command // ""' 2>/dev/null | head -c 200 | tr '\n' ' ')
    [ -z "$CMD" ] && exit 0
    # `` で囲んだコマンド全文（短縮済み）
    SUMMARY="\`Bash\` \`${CMD}\`"
    ;;
  Edit)
    FILE=$(echo "$INPUT" | jq -r '.tool_input.file_path // ""' 2>/dev/null)
    [ -z "$FILE" ] && exit 0
    SUMMARY="\`Edit\` ${FILE}"
    ;;
  Write)
    FILE=$(echo "$INPUT" | jq -r '.tool_input.file_path // ""' 2>/dev/null)
    [ -z "$FILE" ] && exit 0
    SUMMARY="\`Write\` ${FILE}"
    ;;
  Agent)
    DESC=$(echo "$INPUT" | jq -r '.tool_input.description // .tool_input.subagent_type // "agent"' 2>/dev/null)
    AGENT_TYPE=$(echo "$INPUT" | jq -r '.tool_input.subagent_type // ""' 2>/dev/null)
    if [ -n "$AGENT_TYPE" ]; then
      SUMMARY="\`Agent[${AGENT_TYPE}]\` ${DESC}"
    else
      SUMMARY="\`Agent\` ${DESC}"
    fi
    ;;
  Skill)
    SKILL=$(echo "$INPUT" | jq -r '.tool_input.skill // ""' 2>/dev/null)
    [ -z "$SKILL" ] && exit 0
    SUMMARY="\`Skill\` /${SKILL}"
    ;;
  TaskCreate)
    SUBJ=$(echo "$INPUT" | jq -r '.tool_input.subject // ""' 2>/dev/null)
    [ -z "$SUBJ" ] && exit 0
    SUMMARY="\`Task+\` ${SUBJ}"
    ;;
  # Read系・検索系・タスク更新は記録対象外（ノイズ削減）
  Read|Grep|Glob|LS|ListMcpResources|ReadMcpResource|WebSearch|WebFetch|TaskUpdate|TaskList|TaskGet|ToolSearch)
    exit 0
    ;;
  *)
    # 未知ツールは名前だけ
    SUMMARY="\`${TOOL}\`"
    ;;
esac

# ログファイル初期化（無ければ作る）
if [ ! -f "$LOG_FILE" ]; then
  cat > "$LOG_FILE" <<EOF
---
date: ${TODAY}
type: activity-log
auto_generated: true
source: postuse-hook
related:
  - "[[$(date -v-1d +%Y-%m-%d)]]"
---

# Activity Log — ${TODAY}

> Neo（ClaudeCode_Agent）が実行したツール操作の自動記録。
> Read/Grep/Glob 等の検索系は除外。Bash/Edit/Write/Agent/Skill/Task+ を記録。
> 人間向け Daily Briefing（思考整理）は別ファイル（\`${TODAY}-summary.md\`）。

## ツール実行ログ

EOF
fi

# 1行追記
echo "- **${TIME}** ${SUMMARY}" >> "$LOG_FILE"

exit 0
