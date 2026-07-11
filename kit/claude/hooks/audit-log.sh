#!/bin/bash
# PostToolUse hook: 全ツール使用の監査ログ記録
# macOS通知つき（機密ファイルアクセス検知時）

INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // "unknown"')

LOG_DIR="$HOME/.claude/audit"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/$(date '+%Y-%m-%d').log"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

case "$TOOL_NAME" in
  Bash)
    CMD=$(echo "$INPUT" | jq -r '.tool_input.command // "N/A"' | head -c 1000)
    echo "[$TIMESTAMP] BASH: $CMD" >> "$LOG_FILE"
    ;;
  Edit|Write)
    FILE=$(echo "$INPUT" | jq -r '.tool_input.file_path // "N/A"')
    echo "[$TIMESTAMP] $TOOL_NAME: $FILE" >> "$LOG_FILE"

    # 機密ファイルへのアクセス検知 → macOS通知
    if echo "$FILE" | grep -qE "(\.env|secrets/|\.ssh/|\.zshrc|\.zprofile|\.gitconfig|\.git/hooks|LaunchAgents|settings\.json|settings\.local\.json)"; then
      osascript -e "display notification \"$FILE was modified\" with title \"Claude Security Alert\" sound name \"Basso\"" 2>/dev/null
      echo "[$TIMESTAMP] ALERT: Sensitive file touched - $TOOL_NAME: $FILE" >> "$LOG_FILE"
    fi
    ;;
  Read)
    FILE=$(echo "$INPUT" | jq -r '.tool_input.file_path // "N/A"')
    echo "[$TIMESTAMP] READ: $FILE" >> "$LOG_FILE"
    ;;
  *)
    echo "[$TIMESTAMP] $TOOL_NAME" >> "$LOG_FILE"
    ;;
esac

# ログローテーション: 30日以上前を削除
find "$LOG_DIR" -name "*.log" -mtime +30 -delete 2>/dev/null

exit 0
