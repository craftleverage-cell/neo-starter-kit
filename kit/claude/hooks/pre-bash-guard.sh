#!/bin/bash
# PreToolUse hook: Bash コマンド実行前のセキュリティチェック
#
# 検査内容（exit 2 でブロック）:
#   1. 機密パス（~/.ssh/, ~/.claude/hooks/, ~/Library/LaunchAgents/）への
#      書き込み・改竄系操作（>, tee, cp, mv, rm, chmod, chown, ln）
#      → どんな許可設定があっても通さないハードブロック
#   2. インライン任意コード実行: python -c / -m / node -e / bash -c (heredoc) /
#      curl|sh / base64 -d | sh / /dev/tcp/ 等
#   3. python *.py の中身に urllib/requests/subprocess/os.system 等の危険パターン

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

[ -z "$COMMAND" ] && exit 0

# ===== ハードブロック (1): 機密パスへの破壊・改竄 =====
# 許可設定があっても hook が exit 2 で強制的に弾く
PROTECTED_PATHS="(${HOME}/\.ssh/|${HOME}/\.claude/hooks/|${HOME}/Library/LaunchAgents/|~/\.ssh/|~/\.claude/hooks/)"
DESTRUCTIVE_OPS='(>|>>|\btee\b|\bcp\b|\bmv\b|\brm\b|\bchmod\b|\bchown\b|\bln\b)'

if echo "$COMMAND" | grep -qE "$PROTECTED_PATHS"; then
  if echo "$COMMAND" | grep -qE "$DESTRUCTIVE_OPS"; then
    echo "SECURITY: Write/modify on protected path is hard-blocked." >&2
    echo "Path: $(echo "$COMMAND" | grep -oE "$PROTECTED_PATHS[^[:space:]]*" | head -1)" >&2
    exit 2
  fi
fi

# ===== ハードブロック (2): インライン任意コード実行 =====
INLINE_EXEC_PATTERNS='(python3?[[:space:]]+-c[[:space:]]|python3?[[:space:]]+-m[[:space:]]+(http\.server|urllib|socket|base64|smtpd)|node[[:space:]]+-e[[:space:]]|bash[[:space:]]+-c[[:space:]]|/dev/tcp/|base64[[:space:]]+-d[[:space:]].*\|[[:space:]]*(sh|bash|python|zsh)|curl[^|]*\|[[:space:]]*(sh|bash|zsh)|wget[^|]*\|[[:space:]]*(sh|bash|zsh)|launchctl[[:space:]]+(load|bootstrap)|defaults[[:space:]]+write[[:space:]]+.*LoginItems)'

if echo "$COMMAND" | grep -qE "$INLINE_EXEC_PATTERNS"; then
  echo "SECURITY: Inline code execution pattern detected." >&2
  echo "Command: $(echo "$COMMAND" | head -c 200)" >&2
  echo "Review carefully before allowing." >&2
  exit 2
fi

# ===== Python スクリプト実行時の内容検査 (既存ロジック) =====
SCRIPT_PATH=""
if echo "$COMMAND" | grep -qE '^python3?\s+\S+\.py'; then
  SCRIPT_PATH=$(echo "$COMMAND" | sed -E 's/^python3?\s+//' | awk '{print $1}')
fi

if [[ -n "$SCRIPT_PATH" && -f "$SCRIPT_PATH" ]]; then
  # macOS の grep は -P (PCRE) 非対応。-E (ERE) のみで網羅する。
  DANGER_RE='(urllib|requests\.(get|post|put|delete|patch)|httpx\.|http\.client|socket\.(socket|connect)|subprocess\.(call|run|Popen|check_output)|os\.system|os\.popen|shutil\.rmtree|os\.remove|os\.unlink|os\.rmdir|__import__|eval\(|exec\(|\.env|secret|id_rsa|\.ssh|authorized_keys|\.aws)'

  if grep -qE "$DANGER_RE" "$SCRIPT_PATH" 2>/dev/null; then
    MATCHES=$(grep -nE "$DANGER_RE" "$SCRIPT_PATH" | head -5)
    echo "SECURITY: Script '$SCRIPT_PATH' contains suspicious patterns:" >&2
    echo "$MATCHES" >&2
    echo "" >&2
    echo "Review the script content before allowing execution." >&2
    exit 2
  fi
fi

exit 0
