---
name: standup
description: 今日の作業をgitログからサマリー生成。Use when：「今日何やった」「スタンドアップ」「作業サマリー」「standup」。NOT for：セッション終了時の記録（/wrapup を使う）、全プロジェクト俯瞰（/neo-cockpit を使う）。
---

# standup — 日次作業サマリー

以下を実行する：

1. カレントプロジェクト（またはユーザーが指定したプロジェクト）で `git log --oneline --since="yesterday"` を実行して今日のコミットを取得
2. 変更内容を箇条書きで日本語サマリー化
3. 「完了・進行中・ブロック中」の3軸で整理して報告

未コミットの変更（`git status --porcelain`）があれば「進行中」に含めて言及する。
