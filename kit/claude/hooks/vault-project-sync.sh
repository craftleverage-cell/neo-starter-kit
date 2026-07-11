#!/bin/bash
# Vault Project Sync
# SessionEnd hook for Claude Code — reads today's auto activity log and
# refreshes the "⚙ 自動更新ゾーン" (AUTO:BEGIN..AUTO:END) inside each
# existing project note under 03_Projects/.
#
# Source : 06_Logs/Daily_Briefing/YYYY-MM-DD-activity.md  (append-only op log)
# Output : 03_Projects/<dir>.md                            (AUTO zone only, in-place)
#
# Pure text analysis. No LLM / API calls. Idempotent. Safe to run many times.
#
# Rules (do NOT break):
#   - Only touch notes that ALREADY exist as 03_Projects/<dir>.md
#     where <dir> is a <devroot>/<dir> directory seen in today's Edit/Write.
#   - Only the bytes BETWEEN <!-- AUTO:BEGIN --> and <!-- AUTO:END --> are
#     replaced. Everything else (manual parts) is preserved byte-for-byte.
#   - Notes without the AUTO markers are skipped.
#   - Projects NOT in today's log are not touched (last-synced date is kept).
#
# Purpose: 現役プロジェクトノートに機械的な作業実態を自動反映

set -uo pipefail

# UTF-8 / NFC 配慮（日本語ファイルパス対策）。バイト処理は LC_ALL=C で行う。
export LANG="${LANG:-en_US.UTF-8}"

CONF="$HOME/.claude/neo-kit.conf"
[ -f "$CONF" ] || exit 0
. "$CONF"
[ -n "${VAULT_PATH:-}" ] && [ -d "$VAULT_PATH" ] || exit 0
VAULT="$VAULT_PATH"

# 開発ルートのディレクトリ名（プロジェクト判定用）。ここ1箇所を変えれば
# 下の awk 全体（PROJECTS / FILES / COMMITS 抽出）に反映される。
DEVROOT="ClaudeCode"

LOG_DIR="$VAULT/06_Logs/Daily_Briefing"
PROJ_DIR="$VAULT/03_Projects"
DATE=$(date +%F)
NOW=$(date +%H:%M)
ACTIVITY="$LOG_DIR/${DATE}-activity.md"

# Vault 未同期 / 当日ログ無し / プロジェクト置き場無し は静かに退避
[ -d "$LOG_DIR" ]  || exit 0
[ -d "$PROJ_DIR" ] || exit 0
[ -f "$ACTIVITY" ] || exit 0

# 本文行（"- **HH:MM:SS** ..." のみ）を LC_ALL=C awk で取り出す。
# （この Vault のログは locale 依存で grep -E が空振りすることがあるため awk を使う）
LINES=$(LC_ALL=C awk '/^- \*\*[0-9][0-9]:[0-9][0-9]:[0-9][0-9]\*\* / {print}' "$ACTIVITY")
[ -n "$LINES" ] || exit 0

# ---- 当日 Edit/Write された <devroot>/<dir> を抽出（出現順保持・重複除去）----
PROJECTS=$(printf '%s\n' "$LINES" | LC_ALL=C awk -v devroot="$DEVROOT" '
  {
    if (match($0, /`(Edit|Write)` /)) {
      path = substr($0, RSTART + RLENGTH)
      gsub(/[[:space:]]+$/, "", path)
      if (match(path, devroot "/[^/]+/")) {
        seg = substr(path, RSTART, RLENGTH)   # "<devroot>/<dir>/"
        sub("^" devroot "/", "", seg)
        sub(/\/$/, "", seg)
        if (seg != "") print seg
      }
    }
  }
' | awk '!seen[$0]++')

[ -n "$PROJECTS" ] || exit 0

# ---- 各プロジェクトを処理 ----
while IFS= read -r proj; do
  [ -z "$proj" ] && continue
  NOTE="$PROJ_DIR/${proj}.md"

  # ノートが無いPJは何もしない（誤爆防止）
  [ -f "$NOTE" ] || continue

  # AUTO マーカーが無いノートはスキップ（安全）
  if ! grep -q '<!-- AUTO:BEGIN -->' "$NOTE" 2>/dev/null; then
    continue
  fi
  if ! grep -q '<!-- AUTO:END -->' "$NOTE" 2>/dev/null; then
    continue
  fi

  # このPJの当日 Edit/Write ファイル一覧（重複除去）と件数
  FILES=$(printf '%s\n' "$LINES" | LC_ALL=C awk -v P="$proj" -v devroot="$DEVROOT" '
    {
      if (match($0, /`(Edit|Write)` /)) {
        path = substr($0, RSTART + RLENGTH)
        gsub(/[[:space:]]+$/, "", path)
        pat = devroot "/" P "/"
        if (index(path, pat) > 0) print path
      }
    }
  ' | awk '!seen[$0]++')

  FCOUNT=$(printf '%s\n' "$FILES" | grep -c . 2>/dev/null)
  [ -z "$FCOUNT" ] && FCOUNT=0

  # 代表ファイル上位5〜8件（末尾2階層に短縮）
  TOPFILES=$(printf '%s\n' "$FILES" | grep -v '^[[:space:]]*$' | head -8 | LC_ALL=C awk '
    {
      p = $0
      n = split(p, a, "/")
      if (n >= 2) short = a[n-1] "/" a[n]
      else        short = p
      print short
    }
  ')

  # このPJの当日 git コミット subject（heredoc 形式に対応・末尾UTF-8切れを iconv で除去）
  COMMITS=$(printf '%s\n' "$LINES" | LC_ALL=C awk -v P="$proj" -v devroot="$DEVROOT" '
    index($0, "git ") > 0 && index($0, " commit") > 0 {
      line = $0
      # このPJのコミットだけに絞る（-C パス or パス文字列に <devroot>/<dir> を含む）
      pat = devroot "/" P
      if (index(line, pat) == 0) next

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
        gsub(/^[[:space:]]+/, "", rest)
        gsub(/[[:space:]]+$/, "", rest)
        if (rest != "") msg = rest
      }
      if (msg == "") next
      # 末尾のバッククォート / 空白ゴミを除去（activity ログの短縮アーティファクト）
      gsub(/[[:space:]]*`+[[:space:]]*$/, "", msg)
      gsub(/[[:space:]]+$/, "", msg)
      # heredoc 本体が潰れて続く場合に備え二重スペースで subject を切る
      if (match(msg, /  /)) msg = substr(msg, 1, RSTART - 1)
      if (length(msg) > 120) msg = substr(msg, 1, 117) "..."
      if (msg != "") print msg
    }
  ' | awk '!seen[$0]++')

  # 末尾の UTF-8 不正バイト（head -c 200 由来の切れ）を除去
  if [ -n "$COMMITS" ]; then
    COMMITS=$(printf '%s\n' "$COMMITS" | iconv -f UTF-8 -t UTF-8//IGNORE 2>/dev/null | sed -E 's/[[:space:]]+$//')
  fi

  # ---- AUTO 区間に入れる本文を組み立て ----
  AUTO_BODY=$(
    echo "- 最終作業日: ${DATE}"
    echo "- 当日の変更: ${FCOUNT} ファイル"
    if [ "$FCOUNT" -gt 0 ] && [ -n "$TOPFILES" ]; then
      echo "- 代表ファイル:"
      printf '%s\n' "$TOPFILES" | while IFS= read -r f; do
        [ -z "$f" ] && continue
        echo "    - \`${f}\`"
      done
    fi
    echo "- 当日のgitコミット:"
    if [ -z "$COMMITS" ]; then
      echo "    - なし"
    else
      printf '%s\n' "$COMMITS" | while IFS= read -r c; do
        [ -z "$c" ] && continue
        echo "    - ${c}"
      done
    fi
    echo "- last_auto_sync: ${DATE} ${NOW}"
  )

  # ---- AUTO:BEGIN..AUTO:END の間だけを置換（マーカー外は不変・冪等・atomic）----
  TMP="$(mktemp "${TMPDIR:-/tmp}/vault-project-sync.XXXXXX")" || continue
  # AUTO_BODY を一時ファイルに書き、awk から読む（クォート/特殊文字の事故防止）
  BODYTMP="$(mktemp "${TMPDIR:-/tmp}/vault-project-body.XXXXXX")" || { rm -f "$TMP"; continue; }
  printf '%s\n' "$AUTO_BODY" > "$BODYTMP"

  LC_ALL=C awk -v bodyfile="$BODYTMP" '
    BEGIN {
      inzone = 0
      # 置換本文を読み込む
      body = ""
      while ((getline ln < bodyfile) > 0) {
        body = body ln "\n"
      }
      close(bodyfile)
    }
    {
      if ($0 ~ /<!-- AUTO:BEGIN -->/) {
        print $0          # BEGIN マーカー行はそのまま
        printf "%s", body # 置換本文（末尾改行込み）
        inzone = 1
        next
      }
      if ($0 ~ /<!-- AUTO:END -->/) {
        print $0          # END マーカー行はそのまま
        inzone = 0
        next
      }
      if (inzone == 1) {
        next              # 旧 AUTO 本文は捨てる
      }
      print $0            # マーカー外＝手動パートは完全保存
    }
  ' "$NOTE" > "$TMP"

  rm -f "$BODYTMP"

  # 念のため: マーカーが両方残っているか検証してから上書き（壊れた出力で潰さない）
  if grep -q '<!-- AUTO:BEGIN -->' "$TMP" && grep -q '<!-- AUTO:END -->' "$TMP"; then
    mv -f "$TMP" "$NOTE"
  else
    rm -f "$TMP"
  fi

done <<< "$PROJECTS"

exit 0
