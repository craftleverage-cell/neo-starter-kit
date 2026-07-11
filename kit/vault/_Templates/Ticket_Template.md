---
id: T-YYYYMMDD-XX
title: <タイトル>
status: Todo  # Todo | InProgress | Review | HumanApproval | Done | Dropped
created: <YYYY-MM-DD>
updated: <YYYY-MM-DD>
estimated: <例: 2h>

# === Workflow_Scenarios v1.0 メタデータ（7軸・必須） ===
category: <1-9>           # Workflow_Scenarios の Cat 1-9（戦略/実験/保守/成果物/外部/管理/Incident/AI環境/定型）
trigger_source: <CEO | Customer | Market | System | AI | Calendar>
risk_level: <P0 | P1 | P2 | P3>
scope: <Personal | Project | Business | Company>
timebox: <immediate | same_day | week | month | quarter>
approval_type: [none, start, external_send, payment_contract, production, strategic]  # 該当を残す
output_type: <ticket | decision_log | incident_log | final_output | sandbox_note>
owner_agent: <COO | CEO_Assistant | BusinessOwner | ClaudeCode | Research | Writing | QA | Codex>

# === 旧フィールド（後方互換） ===
priority: P2  # P0 緊急 / P1 重要 / P2 通常 / P3 後回し（risk_level と同期）
business: Cross  # A | B | New | Cross | Personal（scope と併用可）
---

## 背景

なぜこの Ticket が生まれたか。元になった会話・Inbox・Decision の参照。

- 参照元: <Inbox or Decision_Log のリンク>

## ゴール

完了の定義。曖昧さを残さない。

- <例: 「○○の機能が動作し、ローカルでテストが通る状態」>

## 受け入れ基準

- [ ] <基準1>
- [ ] <基準2>
- [ ] <基準3>

## スコープ外（やらないこと）

- <例: 「本番DBへのマイグレーション」>

## 関連ファイル

- <ファイルパスへのリンク>

## 作業ログ

```
YYYY-MM-DD HH:MM <Agent>: 開始
YYYY-MM-DD HH:MM <Agent>: <進捗>
```

## レビュー

- Codex Review: `07_Outputs/Reviews/T-XXX/codex_review.md`
- QA Review: `07_Outputs/Reviews/T-XXX/qa_review.md`

## 人間承認

- 承認日:
- 承認者: 人間CEO
- コメント:

## クローズ後

- Decision_Log への記録: <リンク>
- Memory への学び追記: <Agent>/memory.md
