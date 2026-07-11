#!/bin/bash
# ============================================================================
# Neo Starter Kit — installer
#
# Claude Code + Obsidian を「AI参謀 Neo」環境として一発でセットアップする。
# macOS専用。bash 3.2（macOS標準）で動作するよう書いてある。
#
# 使い方:
#   ./install.sh                # 対話形式でセットアップ
#   ./install.sh --yes          # 既定値ですべて進める
#   ./install.sh --dry-run      # 何も変更せず、実行予定の操作だけ表示
#
# 詳しいオプションは ./install.sh --help を参照。
# ============================================================================

set -u

# ---------------------------------------------------------------------------
# デフォルト値・グローバル変数
# ---------------------------------------------------------------------------

SOURCE_DIR="$(cd "$(dirname "$0")" && pwd)"
VAULT_ARG=""
VAULT_PATH=""
OPT_YES=0
OPT_INSTALL_DEPS=0
OPT_DRY_RUN=0
OPT_SKIP_DEPS=0
CLAUDE_MISSING=0
BACKUP_DIR=""

DEFAULT_VAULT="$HOME/Documents/NeoVault"

# ---------------------------------------------------------------------------
# ヘルパー関数
# ---------------------------------------------------------------------------

print_usage() {
  cat <<'EOF'
使い方: ./install.sh [オプション]

オプション:
  --yes             すべて既定値で進める（確認プロンプトをスキップ）
  --install-deps    未インストールの依存関係（Claude Code等）を自動インストールする
  --vault <path>    Obsidian Vaultの作成場所を指定する
  --source <dir>    キットのソースディレクトリ（既定: このスクリプトのある場所）
  --dry-run         実際には何も変更せず、実行予定の操作だけを表示する
  --skip-deps       依存関係チェックを丸ごとスキップする（CI/テスト用）
  -h, --help        このヘルプを表示する

例:
  ./install.sh
  ./install.sh --yes --vault ~/Documents/NeoVault
  ./install.sh --dry-run
EOF
}

# sed の置換文字列として安全になるよう \ と & と | をエスケープする
# （sed区切り文字に | を使う関係で、パスに | が含まれるケースも保険で潰す）
sed_escape_replacement() {
  printf '%s' "$1" | sed -e 's/[\&|]/\\&/g'
}

print_banner() {
  echo "======================================================"
  echo " 🕶️  Neo Starter Kit — セットアップ"
  echo "    Claude Code + Obsidian を \"AI参謀 Neo\" 環境にする"
  echo "======================================================"
  echo ""
}

# ---------------------------------------------------------------------------
# 1. macOSチェック
# ---------------------------------------------------------------------------

check_macos() {
  local os
  os="$(uname -s)"
  if [ "$os" != "Darwin" ]; then
    echo "エラー: このインストーラーは macOS 専用です（検出されたOS: ${os}）。"
    exit 1
  fi

  if command -v sw_vers >/dev/null 2>&1; then
    local ver major
    ver="$(sw_vers -productVersion 2>/dev/null || echo "")"
    major="${ver%%.*}"
    case "$major" in
      ''|*[!0-9]*)
        : # バージョンが取得できなければ判定をスキップ
        ;;
      *)
        if [ "$major" -lt 13 ]; then
          echo "⚠️  macOS ${ver} を検出しました。動作確認は macOS 13 (Ventura) 以降で行っています。"
          echo "   そのまま進めることはできますが、一部の挙動が異なる可能性があります。"
          echo ""
        fi
        ;;
    esac
  fi
}

# ---------------------------------------------------------------------------
# 2. 依存関係チェック
# ---------------------------------------------------------------------------

check_dependencies() {
  if [ "$OPT_SKIP_DEPS" -eq 1 ]; then
    echo "（--skip-deps 指定のため、依存関係チェックをスキップします）"
    echo ""
    return 0
  fi

  echo "--- 依存関係を確認しています ---"
  echo ""

  # --- Claude Code CLI ---
  if command -v claude >/dev/null 2>&1; then
    echo "✅ Claude Code（claude コマンド）が見つかりました"
    CLAUDE_MISSING=0
  else
    echo "⚠️  Claude Code（claude コマンド）が見つかりません"
    echo "   これがNeo環境の本体です。以下のコマンドでインストールできます:"
    echo "     curl -fsSL https://claude.ai/install.sh | bash"
    echo "   ※ Claude Codeの利用には有料プラン（Pro/Max等）または API キーが必要です"
    CLAUDE_MISSING=1

    if [ "$OPT_DRY_RUN" -eq 1 ]; then
      echo "   (dry-run: インストールは実行しません)"
    else
      local do_install="n"
      if [ "$OPT_YES" -eq 1 ]; then
        if [ "$OPT_INSTALL_DEPS" -eq 1 ]; then
          do_install="y"
        else
          do_install="n"
        fi
      else
        printf "   今すぐインストールしますか？ [y/N]: "
        read -r do_install
      fi

      case "$do_install" in
        y|Y|yes|YES)
          echo "   インストールを実行します..."
          curl -fsSL https://claude.ai/install.sh | bash
          if command -v claude >/dev/null 2>&1; then
            echo "   ✅ インストールが完了しました"
            CLAUDE_MISSING=0
          else
            echo "   インストールコマンドを実行しました。ターミナルを開き直すと使えるようになっているはずです"
            CLAUDE_MISSING=1
          fi
          ;;
        *)
          echo "   スキップしました。後で手動インストールしてください。"
          ;;
      esac
    fi
  fi
  echo ""

  # --- Node.js / npx ---
  if command -v node >/dev/null 2>&1 && command -v npx >/dev/null 2>&1; then
    echo "✅ Node.js（node/npx）が見つかりました"
  else
    echo "⚠️  Node.js が見つかりません（Obsidian連携などで使用します）"
    if command -v brew >/dev/null 2>&1; then
      echo "   Homebrewでインストールできます: brew install node"
    else
      echo "   公式サイトからインストールしてください: https://nodejs.org"
    fi
  fi
  echo ""

  # --- Obsidian.app ---
  if [ -d "/Applications/Obsidian.app" ]; then
    echo "✅ Obsidian が見つかりました"
  else
    echo "⚠️  Obsidian が見つかりません（/Applications/Obsidian.app）"
    if command -v brew >/dev/null 2>&1; then
      echo "   Homebrewでインストールできます: brew install --cask obsidian"
    else
      echo "   公式サイトからインストールしてください: https://obsidian.md/download"
    fi
  fi
  echo ""

  # --- jq ---
  # pre-bash-guard.sh（危険コマンド検知）・audit-log.sh（監査ログ）・
  # vault-activity-log.sh（Vault自動記録）はすべて jq でフックの入力JSONを
  # パースしている。jq が無いとこれらは黙って機能しなくなる（安全機能の無効化）。
  if command -v jq >/dev/null 2>&1; then
    echo "✅ jq が見つかりました"
  else
    echo "⚠️  jq が見つかりません"
    echo "   jq が無いと、危険コマンドを検知してブロックする安全機能（pre-bash-guard.sh）や"
    echo "   監査ログ・Vault自動記録（audit-log.sh / vault-activity-log.sh）が動作しません。"

    if [ "$OPT_DRY_RUN" -eq 1 ]; then
      echo "   (dry-run: インストールは実行しません)"
    else
      local do_install_jq="n"
      if [ "$OPT_YES" -eq 1 ]; then
        if [ "$OPT_INSTALL_DEPS" -eq 1 ]; then
          do_install_jq="y"
        else
          do_install_jq="n"
        fi
      elif command -v brew >/dev/null 2>&1; then
        printf "   今すぐ brew install jq を実行しますか？ [y/N]: "
        read -r do_install_jq
      fi

      case "$do_install_jq" in
        y|Y|yes|YES)
          if command -v brew >/dev/null 2>&1; then
            echo "   インストールを実行します..."
            brew install jq
          else
            echo "   Homebrewが見つからないため自動インストールできません。https://jqlang.org/download/ からインストールしてください。"
          fi
          ;;
        *)
          if command -v brew >/dev/null 2>&1; then
            echo "   スキップしました。手動でインストールする場合: brew install jq"
          else
            echo "   Homebrewが見つかりません。手動でインストールしてください: https://jqlang.org/download/"
          fi
          ;;
      esac

      if ! command -v jq >/dev/null 2>&1; then
        echo ""
        echo "   ⚠️  重要: jq をインストールしないまま使うと、危険コマンドのブロックと監査ログが"
        echo "   『エラーにならず素通しされる』状態になります。できるだけ早くインストールしてください。"
      fi
    fi
  fi
  echo ""
}

# ---------------------------------------------------------------------------
# 3. Vaultパスの決定
# ---------------------------------------------------------------------------

ask_vault_path() {
  local chosen=""

  while :; do
    if [ -n "$VAULT_ARG" ]; then
      chosen="$VAULT_ARG"
    elif [ "$OPT_YES" -eq 1 ]; then
      chosen="$DEFAULT_VAULT"
    else
      echo "--- Obsidian Vaultの作成場所 ---"
      printf "保存先を入力してください（そのままEnterで既定値） [%s]: " "$DEFAULT_VAULT"
      read -r chosen
      [ -z "$chosen" ] && chosen="$DEFAULT_VAULT"
    fi

    # 先頭の ~ を展開
    case "$chosen" in
      "~")
        chosen="$HOME"
        ;;
      "~/"*)
        chosen="$HOME/${chosen#\~/}"
        ;;
    esac

    case "$chosen" in
      /*)
        : # 絶対パスでOK
        ;;
      *)
        echo "エラー: Vaultパスは絶対パス（/ または ~ から始まる）で指定してください: $chosen"
        exit 1
        ;;
    esac

    local parent
    parent="$(dirname "$chosen")"
    if [ ! -d "$parent" ]; then
      echo "エラー: 親ディレクトリが存在しません: $parent"
      echo "先にこのディレクトリを作成してから再実行してください。"
      exit 1
    fi

    # $HOME/.claude 配下、またはキットのソースディレクトリ（SOURCE_DIR）配下を
    # Vaultにするのは禁止する。設定ファイル・フックスクリプト・インストーラー本体と
    # Obsidian Vaultのノート群が同じ場所に混ざると、双方が壊れる原因になる。
    local forbidden=""
    case "$chosen" in
      "$HOME/.claude"|"$HOME/.claude"/*)
        forbidden="$HOME/.claude"
        ;;
    esac
    if [ -z "$forbidden" ]; then
      case "$chosen" in
        "$SOURCE_DIR"|"$SOURCE_DIR"/*)
          forbidden="$SOURCE_DIR（キットのソースディレクトリ）"
          ;;
      esac
    fi

    if [ -n "$forbidden" ]; then
      echo "エラー: Vaultの保存先に「$chosen」は指定できません（$forbidden の配下のため）。"
      echo "Claude Codeの設定ディレクトリ・キットのソースディレクトリとは別の場所を指定してください。"
      if [ -n "$VAULT_ARG" ] || [ "$OPT_YES" -eq 1 ]; then
        exit 1
      fi
      echo "別の場所を入力し直してください。"
      echo ""
      chosen=""
      continue
    fi

    break
  done

  VAULT_PATH="$chosen"
  echo ""
}

# ---------------------------------------------------------------------------
# 4. プレフライト確認
# ---------------------------------------------------------------------------

preflight_summary() {
  echo "--- インストール内容の確認 ---"
  printf "  %-26s -> %s\n" "設定・ルール・エージェント" "$HOME/.claude/"
  printf "  %-26s -> %s\n" "設定ファイル(conf)"         "$HOME/.claude/neo-kit.conf"
  printf "  %-26s -> %s\n" "settings.json"              "$HOME/.claude/settings.json"
  printf "  %-26s -> %s\n" "開発ルート"                  "$HOME/ClaudeCode/"
  printf "  %-26s -> %s\n" "Obsidian Vault"             "$VAULT_PATH"
  echo ""

  if [ "$OPT_DRY_RUN" -eq 1 ]; then
    echo "（--dry-run のため、以降はすべて「実行予定」の表示のみです）"
    echo ""
  fi

  if [ "$OPT_YES" -eq 1 ]; then
    return 0
  fi

  printf "この内容でインストールを進めますか？ [y/N]: "
  local ans="n"
  read -r ans
  case "$ans" in
    y|Y|yes|YES)
      echo ""
      return 0
      ;;
    *)
      echo "中止しました。"
      exit 0
      ;;
  esac
}

# ---------------------------------------------------------------------------
# 5. バックアップ
# ---------------------------------------------------------------------------

do_backup() {
  echo "--- 既存設定のバックアップ ---"

  if [ ! -d "$HOME/.claude" ]; then
    echo "（既存の ~/.claude が無いためバックアップは不要です）"
    echo ""
    return 0
  fi

  local ts
  ts="$(date +%Y%m%d-%H%M%S)"
  BACKUP_DIR="$HOME/.claude/backups/neo-kit-$ts"

  if [ "$OPT_DRY_RUN" -eq 1 ]; then
    echo "[dry-run] バックアップ先: $BACKUP_DIR"
    echo "[dry-run] 対象: CLAUDE.md, SOUL-full.md, rules/, agents/, output-styles/neo.md, hooks/, settings.json"
    echo ""
    return 0
  fi

  mkdir -p "$BACKUP_DIR/output-styles"

  local t
  for t in CLAUDE.md SOUL-full.md rules agents "output-styles/neo.md" hooks settings.json; do
    local src="$HOME/.claude/$t"
    if [ -e "$src" ]; then
      cp -R "$src" "$BACKUP_DIR/$t"
      echo "  バックアップ: $t"
    fi
  done

  echo "  -> $BACKUP_DIR"
  echo ""
}

# ---------------------------------------------------------------------------
# 6. kit/claude/ のコアファイルをインストール
# ---------------------------------------------------------------------------

install_claude_core() {
  echo "--- ~/.claude/ にコアファイルを配置しています ---"

  if [ "$OPT_DRY_RUN" -eq 1 ]; then
    echo "[dry-run] CLAUDE.md / SOUL-full.md / rules/ / agents/ / output-styles/neo.md / hooks/ を配置します"
    echo ""
    return 0
  fi

  mkdir -p "$HOME/.claude/rules" "$HOME/.claude/agents" "$HOME/.claude/output-styles" "$HOME/.claude/hooks" "$HOME/.claude/skills"

  cp "$SOURCE_DIR/kit/claude/CLAUDE.md" "$HOME/.claude/CLAUDE.md"
  cp "$SOURCE_DIR/kit/claude/SOUL-full.md" "$HOME/.claude/SOUL-full.md"
  cp -R "$SOURCE_DIR/kit/claude/rules/." "$HOME/.claude/rules/"
  cp -R "$SOURCE_DIR/kit/claude/agents/." "$HOME/.claude/agents/"
  cp "$SOURCE_DIR/kit/claude/output-styles/neo.md" "$HOME/.claude/output-styles/neo.md"
  cp -R "$SOURCE_DIR/kit/claude/hooks/." "$HOME/.claude/hooks/"

  echo "  OK: CLAUDE.md / SOUL-full.md / rules / agents / output-styles / hooks"
  echo ""
}

install_skills_noclobber() {
  echo "--- スキルをインストールしています（既存スキルは上書きしません） ---"

  local skills_src="$SOURCE_DIR/kit/claude/skills"
  if [ ! -d "$skills_src" ]; then
    echo "  （スキルのソースが見つかりません。スキップします）"
    echo ""
    return 0
  fi

  if [ "$OPT_DRY_RUN" -eq 0 ]; then
    mkdir -p "$HOME/.claude/skills"
  fi

  local installed=0
  local skipped=0
  local skipped_names=""
  local d name dest

  for d in "$skills_src"/*/; do
    [ -d "$d" ] || continue
    name="$(basename "$d")"
    dest="$HOME/.claude/skills/$name"

    if [ "$OPT_DRY_RUN" -eq 1 ]; then
      if [ -d "$dest" ]; then
        echo "  [dry-run] スキップ（既存）: $name"
      else
        echo "  [dry-run] インストール: $name"
      fi
      continue
    fi

    if [ -d "$dest" ]; then
      skipped=$((skipped + 1))
      skipped_names="$skipped_names $name"
    else
      cp -R "$d" "$dest"
      installed=$((installed + 1))
    fi
  done

  if [ "$OPT_DRY_RUN" -eq 0 ]; then
    echo "  インストール: ${installed} 件 / スキップ（既存のため）: ${skipped} 件"
    if [ -n "$skipped_names" ]; then
      echo "  スキップしたスキル:$skipped_names"
    fi
  fi
  echo ""
}

# ---------------------------------------------------------------------------
# 7. neo-kit.conf を生成
# ---------------------------------------------------------------------------

generate_conf() {
  echo "--- 設定ファイル (neo-kit.conf) を生成しています ---"

  if [ "$OPT_DRY_RUN" -eq 1 ]; then
    echo "[dry-run] $HOME/.claude/neo-kit.conf を生成します（VAULT_PATH=$VAULT_PATH）"
    echo ""
    return 0
  fi

  cat > "$HOME/.claude/neo-kit.conf" <<EOF
VAULT_PATH="$VAULT_PATH"
DEV_ROOT="$HOME/ClaudeCode"
EOF
  chmod 644 "$HOME/.claude/neo-kit.conf"
  echo "  OK: $HOME/.claude/neo-kit.conf"
  echo ""
}

# ---------------------------------------------------------------------------
# 8. settings.json を生成
# ---------------------------------------------------------------------------

generate_settings_json() {
  echo "--- settings.json を生成しています ---"

  local dest="$HOME/.claude/settings.json"
  local template="$SOURCE_DIR/kit/claude/settings.template.json"

  if [ "$OPT_DRY_RUN" -eq 1 ]; then
    echo "[dry-run] $dest を生成します（テンプレート: $template）"
    echo ""
    return 0
  fi

  if [ ! -f "$template" ]; then
    echo "  エラー: テンプレートが見つかりません: $template"
    echo ""
    return 1
  fi

  if [ -f "$dest" ]; then
    if [ -f "$dest.pre-neo-kit" ]; then
      echo "  $dest.pre-neo-kit は既に存在するため上書きしません（初回実行時のオリジナルを保持）"
    else
      cp "$dest" "$dest.pre-neo-kit"
      echo "  既存の settings.json を保存しました: $dest.pre-neo-kit"
    fi
    echo "  差分を見るには: diff \"$dest.pre-neo-kit\" \"$dest\""
  fi

  local home_esc vault_esc
  home_esc="$(sed_escape_replacement "$HOME")"
  vault_esc="$(sed_escape_replacement "$VAULT_PATH")"

  sed -e "s|{{HOME}}|$home_esc|g" -e "s|{{VAULT_PATH}}|$vault_esc|g" "$template" > "$dest"

  if command -v python3 >/dev/null 2>&1; then
    if python3 -m json.tool "$dest" > /dev/null 2>&1; then
      echo "  OK: settings.json は正しいJSON形式です"
    else
      echo "  ⚠️  settings.json のJSON検証に失敗しました。内容を確認してください: $dest"
    fi
  else
    echo "  ⚠️  python3 が見つからないため JSON検証をスキップしました"
  fi

  echo "  OK: $dest"
  echo ""
}

# ---------------------------------------------------------------------------
# 9. CLAUDE.md の {{VAULT_PATH}} を置換
# ---------------------------------------------------------------------------

generate_claude_md() {
  echo "--- CLAUDE.md にVaultパスを反映しています ---"

  local dest="$HOME/.claude/CLAUDE.md"

  if [ "$OPT_DRY_RUN" -eq 1 ]; then
    echo "[dry-run] $dest の {{VAULT_PATH}} を $VAULT_PATH に置換します"
    echo ""
    return 0
  fi

  if [ ! -f "$dest" ]; then
    echo "  ⚠️  $dest が見つかりません（前段の配置に失敗している可能性があります）"
    echo ""
    return 1
  fi

  local vault_esc tmp
  vault_esc="$(sed_escape_replacement "$VAULT_PATH")"
  tmp="$(mktemp "${TMPDIR:-/tmp}/neo-kit-claude-md.XXXXXX")"
  sed -e "s|{{VAULT_PATH}}|$vault_esc|g" "$dest" > "$tmp" && mv "$tmp" "$dest"

  echo "  OK: $dest"
  echo ""
}

# ---------------------------------------------------------------------------
# 10. 開発ルートの準備
# ---------------------------------------------------------------------------

mkdir_dev_root() {
  echo "--- 開発ルート (~/ClaudeCode) を準備しています ---"
  if [ "$OPT_DRY_RUN" -eq 1 ]; then
    echo "[dry-run] mkdir -p $HOME/ClaudeCode"
    echo ""
    return 0
  fi
  mkdir -p "$HOME/ClaudeCode"
  echo "  OK: $HOME/ClaudeCode"
  echo ""
}

# ---------------------------------------------------------------------------
# 11. Vaultのインストール
# ---------------------------------------------------------------------------

install_vault() {
  echo "--- Obsidian Vault を準備しています ---"
  echo "  場所: $VAULT_PATH"

  local vault_src="$SOURCE_DIR/kit/vault"

  if [ "$OPT_DRY_RUN" -eq 1 ]; then
    if [ -d "$VAULT_PATH" ]; then
      echo "[dry-run] 既存のフォルダを検出。既存ファイルを上書きしない差分コピーを行います"
    else
      echo "[dry-run] Vault一式（.obsidian含む）を新規コピーします"
    fi
    echo ""
    return 0
  fi

  if [ ! -d "$VAULT_PATH" ]; then
    mkdir -p "$VAULT_PATH"
    cp -R "$vault_src/." "$VAULT_PATH/"
    # .gitkeep はgit用の空フォルダ維持マーカーなので、Vault側には残さない
    find "$VAULT_PATH" -name ".gitkeep" -type f -delete 2>/dev/null
    echo "  OK: 新規Vaultを作成しました"
  else
    echo "  既存のフォルダを検出。既存ファイルは上書きせず、不足分だけコピーします..."
    local copied=0
    local skipped=0
    local rel src_f dst_f dst_dir

    while IFS= read -r rel; do
      src_f="$vault_src/$rel"
      dst_f="$VAULT_PATH/$rel"
      dst_dir="$(dirname "$dst_f")"
      mkdir -p "$dst_dir"

      case "$rel" in
        */.gitkeep|.gitkeep)
          continue
          ;;
      esac

      if [ -e "$dst_f" ]; then
        skipped=$((skipped + 1))
      else
        cp "$src_f" "$dst_f"
        copied=$((copied + 1))
      fi
    done < <(cd "$vault_src" && find . -type f)

    echo "  コピー: ${copied} 件 / スキップ（既存のため）: ${skipped} 件"
  fi
  echo ""
}

# ---------------------------------------------------------------------------
# 12. フックスクリプトに実行権限
# ---------------------------------------------------------------------------

chmod_hooks() {
  echo "--- フックスクリプトに実行権限を付与しています ---"
  if [ "$OPT_DRY_RUN" -eq 1 ]; then
    echo "[dry-run] chmod +x $HOME/.claude/hooks/*.sh"
    echo ""
    return 0
  fi
  chmod +x "$HOME/.claude/hooks/"*.sh 2>/dev/null
  echo "  OK"
  echo ""
}

# ---------------------------------------------------------------------------
# 13. 検証
# ---------------------------------------------------------------------------

verify_install() {
  echo "--- インストール結果を確認しています ---"

  if [ "$OPT_DRY_RUN" -eq 1 ]; then
    echo "[dry-run] 検証はスキップします"
    echo ""
    return 0
  fi

  if command -v claude >/dev/null 2>&1; then
    local v
    v="$(claude --version 2>/dev/null)"
    echo "✅ claude コマンド（${v:-バージョン不明}）"
  else
    echo "⚠️  claude コマンドが見つかりません（後述の手順でインストールしてください）"
  fi

  if command -v python3 >/dev/null 2>&1; then
    if python3 -m json.tool "$HOME/.claude/settings.json" > /dev/null 2>&1; then
      echo "✅ settings.json は正しいJSON形式です"
    else
      echo "⚠️  settings.json のJSON検証に失敗しました"
    fi
  else
    echo "⚠️  python3 が無いため settings.json の検証をスキップしました"
  fi

  local all_exec=1
  local h
  for h in pre-bash-guard.sh audit-log.sh vault-activity-log.sh vault-daily-summary.sh vault-project-sync.sh; do
    if [ ! -x "$HOME/.claude/hooks/$h" ]; then
      all_exec=0
      echo "⚠️  実行権限が無いフック: $h"
    fi
  done
  [ "$all_exec" -eq 1 ] && echo "✅ 全フックスクリプトに実行権限があります"

  if [ -d "$VAULT_PATH/00_CEO_OS" ] && [ -d "$VAULT_PATH/06_Logs" ]; then
    echo "✅ Vaultフォルダ構成を確認しました"
  else
    echo "⚠️  Vaultフォルダ構成の確認に失敗しました: $VAULT_PATH"
  fi
  echo ""
}

# ---------------------------------------------------------------------------
# 14. 次にやること
# ---------------------------------------------------------------------------

print_next_steps() {
  echo "======================================================"
  echo " セットアップ完了"
  echo "======================================================"
  echo ""
  echo "次にやること:"
  echo ""
  echo "  ① ターミナルで claude と入力 → ブラウザでログイン（Claude有料プラン必須）"
  if [ "$CLAUDE_MISSING" -eq 1 ]; then
    echo "     ※ claude コマンドが未インストールです。先に以下を実行してください:"
    echo "        curl -fsSL https://claude.ai/install.sh | bash"
  fi
  echo "  ② Obsidianを起動 → 「保管庫として開く」→ 以下のフォルダを選択"
  echo "        ${VAULT_PATH}"
  echo "  ③ claude 内で /neo-cockpit を試してみる"
  echo "  ④ ${VAULT_PATH}/00_CEO_OS/CEO.md に会社情報を書くと、Neoの提案精度が上がる"
  echo ""
  echo "  🕶️ I know kung fu. — 環境は整った。"
  echo ""
}

# ---------------------------------------------------------------------------
# 引数パース
# ---------------------------------------------------------------------------

parse_args() {
  while [ $# -gt 0 ]; do
    case "$1" in
      --yes)
        OPT_YES=1
        shift
        ;;
      --install-deps)
        OPT_INSTALL_DEPS=1
        shift
        ;;
      --dry-run)
        OPT_DRY_RUN=1
        shift
        ;;
      --skip-deps)
        OPT_SKIP_DEPS=1
        shift
        ;;
      --vault)
        if [ $# -lt 2 ]; then
          echo "エラー: --vault にはパスを指定してください"
          exit 1
        fi
        VAULT_ARG="$2"
        shift 2
        ;;
      --source)
        if [ $# -lt 2 ]; then
          echo "エラー: --source にはディレクトリを指定してください"
          exit 1
        fi
        SOURCE_DIR="$2"
        shift 2
        ;;
      -h|--help)
        print_usage
        exit 0
        ;;
      *)
        echo "不明なオプション: $1"
        echo ""
        print_usage
        exit 1
        ;;
    esac
  done
}

# ---------------------------------------------------------------------------
# main
# ---------------------------------------------------------------------------

main() {
  parse_args "$@"

  if [ ! -d "$SOURCE_DIR/kit/claude" ] || [ ! -d "$SOURCE_DIR/kit/vault" ]; then
    echo "エラー: キットのソースディレクトリが見つかりません: $SOURCE_DIR"
    echo "  neo-starter-kit をクローンしたディレクトリ内で実行するか、--source <dir> を指定してください。"
    exit 1
  fi

  print_banner
  check_macos
  check_dependencies
  ask_vault_path
  preflight_summary
  do_backup
  install_claude_core
  install_skills_noclobber
  generate_conf
  generate_settings_json
  generate_claude_md
  mkdir_dev_root
  install_vault
  chmod_hooks
  verify_install
  print_next_steps
}

main "$@"
