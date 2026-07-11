#!/bin/bash
# neo-cockpit scan: ~/ClaudeCode 全プロジェクトの状態を読み取り専用で集約する
# 出力はそのまま LLM が読む前提。副作用なし・ネットワークなし・秘密ファイル非接触。
set -u
BASE="$HOME/ClaudeCode"
# ディレクトリ名はホームパスの絶対パスから自動生成される（例: /Users/yourname → -Users-yourname）
MEM="$HOME/.claude/projects/$(echo "$HOME" | tr '/' '-')/memory"
NOW=$(date +%s)

echo "=== NEO COCKPIT SCAN $(date '+%Y-%m-%d %H:%M') ==="
echo ""
echo "--- projects ---"
for d in "$BASE"/*/; do
  name=$(basename "$d")
  case "$name" in .*) continue ;; esac
  if [ -d "${d}.git" ]; then
    ts=$(git -C "$d" log -1 --format=%at 2>/dev/null || echo "$NOW")
    days=$(( (NOW - ts) / 86400 ))
    last=$(git -C "$d" log -1 --format='%ad %s' --date=short 2>/dev/null)
    dirty=$(git -C "$d" status --porcelain 2>/dev/null | wc -l | tr -d ' ')
    branch=$(git -C "$d" branch --show-current 2>/dev/null)
    echo "[$name] ${days}d_ago branch=${branch:-?} dirty=$dirty last=\"$last\""
  else
    echo "[$name] no_git newest_file=$(ls -t "$d" 2>/dev/null | head -1)"
  fi
done

echo ""
echo "--- memory (30日以内に更新されたファイル) ---"
find "$MEM" -maxdepth 1 -name '*.md' -mtime -30 2>/dev/null | while read -r f; do
  echo "$(date -r "$f" '+%Y-%m-%d') $(basename "$f")"
done | sort -r

echo ""
echo "--- infra health ---"
for h in audit-log.sh pre-bash-guard.sh; do
  if [ -e "$HOME/.claude/hooks/$h" ]; then
    echo "$h: OK"
  else
    echo "$h: MISSING (settings.jsonにフック設定が残っていれば幽霊フック)"
  fi
done
for s in vault-activity-log.sh vault-daily-summary.sh vault-project-sync.sh; do
  [ -e "$HOME/.claude/hooks/$s" ] || echo "$s: MISSING (Obsidian自動記録フック要確認)"
done
[ -e "$HOME/.claude/neo-kit.conf" ] || echo "neo-kit.conf: MISSING (初期セットアップ未完了の可能性。Vaultパス等の設定を確認)"
echo ""
echo "=== END SCAN ==="
