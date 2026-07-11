# Neo Vault

このVaultは **Neo（AI参謀）と一緒に運用する経営OS** の保管庫。
Claude Code から Obsidian MCP 経由で読み書きされ、日々の作業ログや意思決定を自動で蓄積していく。

---

## 構造（Map of Contents）

| フォルダ | 役割 |
|---|---|
| `00_CEO_OS/` | 経営者の判断軸（`CEO.md`, `MyContext.md`）。Neoが最初に読む場所 |
| `01_Company_OS/` | 会社の運用ルール・憲法を育てていく場所（最初は空） |
| `02_Business/` | 事業ごとの文脈・戦略資料 |
| `03_Projects/` | プロジェクトごとのノート。`~/ClaudeCode/` 配下の開発プロジェクトと対応させる運用ができる |
| `04_Agents/` | 自分で作ったAIエージェントのマニュアル・役割定義 |
| `05_Tickets/` | タスク管理（Todo / Review / Done） |
| `06_Logs/` | 意思決定ログ・日次サマリー・週次レビュー・インシデント記録 |
| `07_Outputs/` | 成果物置き場（レビュー結果・生成物など） |
| `08_Inbox/` | 一次受付。とりあえず放り込む場所。後で整理すればいい |
| `09_Archive/` | 終了・凍結した資料 |
| `_Templates/` | Daily Briefing / Handoff / Ticket / Weekly Review のテンプレート |

新しいノートを作ったら、できるだけ対応するフォルダに置く。迷ったら `08_Inbox/` に入れて後で仕分ければいい。

### フォルダツリー

```
00_CEO_OS/            CEO.md, MyContext.md
01_Company_OS/        会社共通ルール（空・運用しながら育てる）
02_Business/          事業ごとの文脈
03_Projects/          プロジェクト単位のノート
04_Agents/            自作AIエージェントのマニュアル
05_Tickets/           タスク進行管理
06_Logs/
  ├ Decision_Log.md   意思決定の年表
  ├ Daily_Briefing/   日次の自動サマリー・思考整理
  ├ Weekly_Review/    週次レビュー
  ├ Incidents/        失敗・事故記録
  ├ Handoff/          引き継ぎ文書
  └ Audits/           監査・レビュー記録
07_Outputs/            成果物
  └ Attachments/       画像等の添付ファイル置き場
08_Inbox/              一次受付
09_Archive/            凍結資料
_Templates/            各種テンプレート
```

---

## 起動時にNeoが読む順序

1. `~/.claude/CLAUDE.md`（全体ルール）
2. `00_CEO_OS/CEO.md`（会社・事業の情報）
3. `00_CEO_OS/MyContext.md`（あなた自身の情報）
4. `03_Projects/`（進行中プロジェクトの文脈、該当する場合）

**この3ファイルを埋めるほど、Neoの提案は的確になる。** 特に `00_CEO_OS/` の2ファイルは、インストール後まっさきに書き込むことを勧める。

---

## Ticket と Handoff

- **Ticket**（`05_Tickets/`）＝ タスクの進行管理。`_Templates/Ticket_Template.md` を複製して使う
- **Handoff**（`06_Logs/Handoff/`）＝ 作業の引き継ぎ文書。1つのTicketの中で複数のHandoffが発生してよい
- どちらもステータス（Todo → InProgress → Review → Done など）をfrontmatterで管理する

---

## 自動記録される内容

インストール時に付属のフックスクリプトが有効になっていれば、以下が自動で溜まっていく（仕組みの詳細はキット本体の README を参照）：

- `06_Logs/Daily_Briefing/YYYY-MM-DD-activity.md` — その日実行した操作の生ログ
- `06_Logs/Daily_Briefing/YYYY-MM-DD-summary.md` — 上記から生成した人間向けサマリー（Obsidianのデイリーノート `YYYY-MM-DD.md` とは別ファイル。あなたが手で書くデイリーノートは書き換えない）
- `03_Projects/<プロジェクト名>.md` の `<!-- AUTO:BEGIN -->`〜`<!-- AUTO:END -->` 区間 — プロジェクトごとの最終作業日・変更ファイル・コミット

いずれも「あらかじめ決まった自動生成用のファイル・区画にしか書き込まない」設計になっている。存在しないノートを勝手に作ることもない。

---

## 使い方のコツ

- 完璧を目指さない。`00_CEO_OS/` から少しずつ埋めていけば十分
- `05_Tickets/` と `06_Logs/Decision_Log.md` は、後から「なぜそう決めたか」を思い出すための保険。迷ったら書く
- Obsidianはあくまで記憶装置。判断や実行はNeo（Claude Code側）が担う
