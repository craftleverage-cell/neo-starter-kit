#!/bin/bash
# Vault Daily Summary Generator
# SessionEnd hook for Claude Code — reads today's auto activity log and
# regenerates a human-readable daily summary (Markdown) in the Vault.
#
# Source : 06_Logs/Daily_Briefing/YYYY-MM-DD-activity.md          (append-only op log)
# Output : 06_Logs/Daily_Briefing/YYYY-MM-DD-summary.md           (idempotent full rewrite)
#
# NOTE: The output filename is deliberately NOT YYYY-MM-DD.md — that path is
# Obsidian's own Daily Note (see kit/vault/.obsidian/daily-notes.json). Using
# the same name would silently overwrite the user's hand-written daily note
# every SessionEnd. Keep this suffix distinct from the Daily Notes format.
#
# Pure text analysis. No LLM / API calls. Safe to run many times per day.
#
# Purpose: その日の作業を人間が読める粒度で自動要約

set -uo pipefail

# UTF-8 / NFC 配慮（日本語ファイルパス対策）
export LC_ALL="${LC_ALL:-en_US.UTF-8}"
export LANG="${LANG:-en_US.UTF-8}"

CONF="$HOME/.claude/neo-kit.conf"
[ -f "$CONF" ] || exit 0
. "$CONF"
[ -n "${VAULT_PATH:-}" ] && [ -d "$VAULT_PATH" ] || exit 0
VAULT="$VAULT_PATH"

# 開発ルートのディレクトリ名（プロジェクト判定用）。conf の DEV_ROOT を優先し、
# 無ければ既定の "ClaudeCode" を使う。ここ1箇所を変えれば下の awk 全体に反映される。
DEVROOT="ClaudeCode"

LOG_DIR="$VAULT/06_Logs/Daily_Briefing"
DATE=$(date +%F)
ACTIVITY="$LOG_DIR/${DATE}-activity.md"
SUMMARY="$LOG_DIR/${DATE}-summary.md"

# Vault 未同期 / 当日ログ無しは静かに退避
if [ ! -d "$LOG_DIR" ]; then
  exit 0
fi
if [ ! -f "$ACTIVITY" ]; then
  exit 0
fi

# ---- ヘルパ: 各種抽出は awk/grep のみで実施（パース対象は activity ログの本文行のみ）----

# 本文行（"- **HH:MM:SS** ..." のみ）
LINES=$(grep -E '^- \*\*[0-9]{2}:[0-9]{2}:[0-9]{2}\*\* ' "$ACTIVITY" 2>/dev/null)

# 該当無しなら最小限のサマリだけ出して終了（冪等）
TOTAL=$(printf '%s\n' "$LINES" | grep -c . 2>/dev/null)
if [ -z "$LINES" ] || [ "$TOTAL" -eq 0 ]; then
  cat > "$SUMMARY" <<EOF
---
date: ${DATE}
type: daily-summary
auto_generated: true
source: sessionend-hook
related: "[[${DATE}-activity]]"
---

# ${DATE} 作業サマリ

> 本日の操作ログ（\`${DATE}-activity.md\`）から自動生成。

記録された作業はありません。
EOF
  exit 0
fi

# 稼働時間（最初/最後のタイムスタンプ HH:MM）
FIRST_TS=$(printf '%s\n' "$LINES" | head -1 | sed -E 's/^- \*\*([0-9]{2}:[0-9]{2}):[0-9]{2}\*\*.*/\1/')
LAST_TS=$(printf '%s\n' "$LINES" | tail -1 | sed -E 's/^- \*\*([0-9]{2}:[0-9]{2}):[0-9]{2}\*\*.*/\1/')

# ---- プロジェクト別: Edit / Write されたファイルパスを解析 ----
# 出力: "<project>\t<filepath>" を集めて後段でグルーピング
PROJECT_TSV=$(printf '%s\n' "$LINES" | LC_ALL=C awk -v devroot="$DEVROOT" '
  # Edit / Write 行から file path を取り出す
  # 形式: - **HH:MM:SS** `Edit` /path   または  `Write` /path
  {
    line = $0
    # `Edit` または `Write` の直後 ~ 行末をパス候補とする
    if (match(line, /`(Edit|Write)` /)) {
      path = substr(line, RSTART + RLENGTH)
      # 末尾空白除去
      gsub(/[[:space:]]+$/, "", path)
      if (path == "") next

      proj = "(その他)"
      if (match(path, devroot "/[^/]+/")) {
        seg = substr(path, RSTART, RLENGTH)        # "<devroot>/<proj>/"
        sub("^" devroot "/", "", seg)
        sub(/\/$/, "", seg)
        proj = seg
      } else if (path ~ /\.claude\//) {
        # フック/設定関連の操作はここにまとめる（旧: 専用ワークスペース分岐は廃止）
        proj = "claude-config"
      } else {
        # それ以外は最上位ディレクトリ名（/Users/<x>/<top>/...）
        p = path
        sub(/^\//, "", p)
        n = split(p, parts, "/")
        # /Users/<user>/<top>/... を想定し、可能なら3番目を採用
        if (n >= 3 && parts[1] == "Users") {
          proj = parts[3]
        } else if (n >= 1) {
          proj = parts[1]
        }
      }
      printf "%s\t%s\n", proj, path
    }
  }
')

# プロジェクト一覧（出現順を保持しつつ重複除去）
PROJECTS=$(printf '%s\n' "$PROJECT_TSV" | grep -v '^[[:space:]]*$' | cut -f1 | awk '!seen[$0]++')

# ---- git コミット: Bash 行から git commit を抽出 ----
# -m "..." 形式があれば subject を、heredoc 形式なら直後の非空行を subject とみなす。
# activity ログでは heredoc 本文は記録されず1行に潰れているため、`-m "$(cat <<'EOF'` の
# 直後に続く語を拾えるだけ拾う。確実に取れない場合は "(メッセージ抽出不可)" とする。
GIT_COMMITS=$(printf '%s\n' "$LINES" | LC_ALL=C awk '
  index($0, "git ") > 0 && index($0, " commit") > 0 {
    line = $0
    msg = ""
    # パターン1: -m "..."（ダブルクォート、heredocでない）
    if (match(line, /-m "[^"]+"/)) {
      msg = substr(line, RSTART + 4, RLENGTH - 5)
    }
    # パターン2: -m '"'"'...'"'"'（シングルクォート）
    else if (match(line, /-m '"'"'[^'"'"']+'"'"'/)) {
      msg = substr(line, RSTART + 4, RLENGTH - 5)
    }
    # パターン3: heredoc 形式 -m "$(cat <<'"'"'EOF'"'"'  ...subject...
    else if (match(line, /-m "\$\(cat <<'"'"'?EOF'"'"'?/)) {
      rest = substr(line, RSTART + RLENGTH)
      # 先頭の空白/記号を除去して最初の意味のあるトークン群を subject とする
      gsub(/^[[:space:]]+/, "", rest)
      # 末尾のバッククォート由来ゴミを軽く除去
      gsub(/[[:space:]]+$/, "", rest)
      if (rest != "") msg = rest
    }
    if (msg == "") msg = "(メッセージ抽出不可)"
    # 末尾のバッククォート / 空白ゴミを除去（activity ログの短縮アーティファクト）
    gsub(/[[:space:]]*`+[[:space:]]*$/, "", msg)
    gsub(/[[:space:]]+$/, "", msg)
    # 1行 subject だけ残す（heredoc 本体が潰れて続く場合に備え二重スペースで切る）
    if (match(msg, /  /)) msg = substr(msg, 1, RSTART - 1)
    # 長すぎる subject は短縮
    if (length(msg) > 120) msg = substr(msg, 1, 117) "..."
    if (msg != "") print msg
  }
' | awk '!seen[$0]++')

# activity ログ側の head -c 200 で UTF-8 が途中で切れ "" が残ることがあるため、
# 不正な末尾バイトを iconv//IGNORE で除去してから末尾の "…" を付ける（情報源由来の制約）。
if [ -n "$GIT_COMMITS" ]; then
  GIT_COMMITS=$(printf '%s\n' "$GIT_COMMITS" | iconv -f UTF-8 -t UTF-8//IGNORE 2>/dev/null | sed -E 's/[[:space:]]+$//')
fi

# push したリポジトリ（git ... push を含む Bash 行から -C のパスを拾う）
GIT_PUSHES=$(printf '%s\n' "$LINES" | LC_ALL=C awk -v devroot="$DEVROOT" '
  index($0, "git ") > 0 && index($0, " push") > 0 {
    line = $0
    repo = ""
    if (match(line, /-C [^ ]+/)) {
      repo = substr(line, RSTART + 3, RLENGTH - 3)
      # <devroot>/<proj> まで縮める
      if (match(repo, devroot "/[^/]+")) {
        repo = substr(repo, RSTART)
      }
    }
    if (repo == "") repo = "(repo不明)"
    print repo
  }
' | awk '!seen[$0]++')

# ---- 使ったスキル / エージェント ----
# Skill 行: `Skill` /name
SKILLS=$(printf '%s\n' "$LINES" | LC_ALL=C awk '
  match($0, /`Skill` \/[^ ]+/) {
    s = substr($0, RSTART + 9, RLENGTH - 9)
    print s
  }
' | sort | uniq -c | sort -rn | sed -E 's/^[[:space:]]*([0-9]+)[[:space:]]+(.*)$/\2 (\1回)/')

# Agent 行: `Agent[type]` desc または `Agent` desc
AGENTS=$(printf '%s\n' "$LINES" | LC_ALL=C awk '
  match($0, /`Agent(\[[^]]+\])?`/) {
    tag = substr($0, RSTART, RLENGTH)        # `Agent[Explore]` 等
    gsub(/`/, "", tag)
    rest = substr($0, RSTART + RLENGTH)
    gsub(/^[[:space:]]+/, "", rest)
    gsub(/[[:space:]]+$/, "", rest)
    if (rest == "") rest = "(説明なし)"
    printf "%s — %s\n", tag, rest
  }
' | awk '!seen[$0]++')

# ---- カウント類 ----
EDIT_CNT=$(printf '%s\n' "$LINES" | grep -c '`Edit`' 2>/dev/null)
WRITE_CNT=$(printf '%s\n' "$LINES" | grep -c '`Write`' 2>/dev/null)
BASH_CNT=$(printf '%s\n' "$LINES" | grep -c '`Bash`' 2>/dev/null)

# ---- SUMMARY を丸ごと生成（一時ファイル→mv で安全に上書き）----
TMP="$(mktemp "${TMPDIR:-/tmp}/vault-daily-summary.XXXXXX")" || exit 0

{
  cat <<EOF
---
date: ${DATE}
type: daily-summary
auto_generated: true
source: sessionend-hook
related: "[[${DATE}-activity]]"
---

# ${DATE} 作業サマリ

> 本日の操作ログ（\`${DATE}-activity.md\`）から自動生成。人間が読むための要約。

## 稼働サマリ

- 稼働時間: ${FIRST_TS} – ${LAST_TS}
- 総アクティビティ件数: ${TOTAL} 件（Bash ${BASH_CNT} / Edit ${EDIT_CNT} / Write ${WRITE_CNT}）

## プロジェクト別の作業
EOF

  if [ -z "$PROJECTS" ]; then
    echo
    echo "ファイル編集（Edit/Write）の記録はありません。"
  else
    while IFS= read -r proj; do
      [ -z "$proj" ] && continue
      # このプロジェクトのファイル一覧（重複除去）
      FILES=$(printf '%s\n' "$PROJECT_TSV" | LC_ALL=C awk -F'\t' -v p="$proj" '$1==p {print $2}' | awk '!seen[$0]++')
      FCOUNT=$(printf '%s\n' "$FILES" | grep -c . 2>/dev/null)
      echo
      echo "### ${proj}（${FCOUNT} ファイル）"
      printf '%s\n' "$FILES" | while IFS= read -r f; do
        [ -z "$f" ] && continue
        echo "- \`${f}\`"
      done
    done <<< "$PROJECTS"
  fi

  echo
  echo "## git コミット"
  if [ -z "$GIT_COMMITS" ]; then
    echo
    echo "コミットなし。"
  else
    echo
    printf '%s\n' "$GIT_COMMITS" | while IFS= read -r c; do
      [ -z "$c" ] && continue
      echo "- ${c}"
    done
    if [ -n "$GIT_PUSHES" ]; then
      echo
      echo "push 先リポジトリ:"
      printf '%s\n' "$GIT_PUSHES" | while IFS= read -r r; do
        [ -z "$r" ] && continue
        echo "- \`${r}\`"
      done
    fi
  fi

  echo
  echo "## 使ったスキル / エージェント"
  if [ -z "$SKILLS" ] && [ -z "$AGENTS" ]; then
    echo
    echo "なし。"
  else
    if [ -n "$AGENTS" ]; then
      echo
      echo "### エージェント"
      printf '%s\n' "$AGENTS" | while IFS= read -r a; do
        [ -z "$a" ] && continue
        echo "- ${a}"
      done
    fi
    if [ -n "$SKILLS" ]; then
      echo
      echo "### スキル"
      printf '%s\n' "$SKILLS" | while IFS= read -r s; do
        [ -z "$s" ] && continue
        echo "- ${s}"
      done
    fi
  fi
} > "$TMP"

mv -f "$TMP" "$SUMMARY"

exit 0
