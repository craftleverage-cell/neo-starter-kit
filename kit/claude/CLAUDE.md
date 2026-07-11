# ユーザーグローバル CLAUDE.md（憲法）

全プロジェクト共通の最上位ルール。プロジェクト固有ルールは各プロジェクト直下の CLAUDE.md が上書きする。

## 絶対規約

- `.env` / `.env.local` / credentials 類は**読まない**（存在・パーミッション確認のみ）。実値の確認は社長に委ねる
- 破壊的操作（削除・上書き・移動）は「git commit → 実行 → 検証」の順を厳守
- 秘密情報（APIキー・トークン）をログ・報告・コミットに含めない
- GAS の Web App は `clasp push` のみ。`clasp deploy` は使わない（デプロイ設定が壊れる）

## 環境の地図

| 場所 | 用途 |
|---|---|
| `~/ClaudeCode/` | 開発の唯一のルート。新規プロジェクトは必ずここに kebab-case で作成 |
| `~/ClaudeCode/_archive/` | 終了プロジェクト・完成済み成果物 |
| `{{VAULT_PATH}}` | Obsidian Vault（インストール時に指定した保管庫のパス） |
| `~/.claude/projects/<ホームパスから自動生成>/memory/` | セッション跨ぎメモリ（MEMORY.md がインデックス） |

> ※ `<ホームパスから自動生成>` は固定値ではない。Claude Code がホームディレクトリの絶対パスから自動生成するディレクトリ名（例: `/Users/yourname` → `-Users-yourname`）。実際のディレクトリ名はインストール後に `~/.claude/projects/` 配下を確認すること。

## ルール索引（詳細は ~/.claude/rules/）

- `SOUL.md` — 人格・応対原則（Neo）
- `dev.md` — 開発規約（Python標準・プロジェクト構成・.env管理）
- `orchestration.md` — SubAgent委譲・並列化の方針
- `supabase-security.md` — Supabase実装のセキュリティ規約（実装前に必読）
- `unknowns.md` — 未知発見の運用規約（盲点チェック・試作ファースト・逸脱ログ・クイズ関所）

## 使い分けの原則

- 差分レビュー → `/code-review`（組み込み）
- 本番デプロイ・重要マージの直前 → `/code-review ultra`（クラウド多段レビュー。社長のコマンド実行が必要なので、Neoは該当タイミングで実行を促す）
- 朝一・プロジェクト切替 → `/neo-cockpit`、新領域に入る前の盲点チェック → `/blindspot`
- 検証ループ → `/verify`、日次サマリー → `/standup`、セッション締め → `/wrapup`
- 調査は3ファイル以上を跨ぐなら Explore エージェントに並列委譲する
- モデル運用：設計・レビュー = Fable/Opus、実装 = Sonnet、定型・大量処理 = Haiku
