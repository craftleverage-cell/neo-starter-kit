---
handoff_id: H-YYYYMMDD-XX
ticket: T-YYYYMMDD-XX
from_agent: <渡す側>
to_agent: <受ける側>
created: <YYYY-MM-DD>
status: ready  # draft | ready | in_progress | waiting_human | done | blocked

# === Workflow_Scenarios v1.0 メタデータ（Ticket から継承・必須） ===
category: <1-9>           # 親 Ticket と同じ
risk_level: <P0 | P1 | P2 | P3>
timebox: <immediate | same_day | week | month | quarter>
approval_type: [none, start, external_send, payment_contract, production, strategic]
expected_output_type: <ticket-update | decision-log-entry | incident-log | final-output | review-comment | sandbox-note>
---

# Handoff: <タイトル>

## 渡すもの

- 成果物の場所: <パス>
- 関連 Ticket: <T-XXX>

## やってほしいこと

明確に、命令形で。

- <例: 「`Outputs/1_Draft/T-XXX/auth.ts` をレビューし、Codex_Review_Agent の観点でコメントせよ」>

## 守ってほしい制約

- <例: 「実装の変更はせず、レビューコメントのみ」>
- <例: 「3時間以内に Reviews/ に出力」>

## 文脈（読むべきファイル）

1. `04_Agents/<to_agent>.md`
2. <該当 Ticket>
3. <該当 Decision Log エントリ>

## 完了基準

- [ ] <基準1>
- [ ] <基準2>

## 戻し先

完了後は **どこに置き、どのステータスに移動するか**：

- 成果物: <パス>
- Ticket 移動: `<from-status>` → `<to-status>`

## 不明点があったら

- <to_agent> はこの Handoff を保留し、`06_Logs/Handoff/_questions/` に質問ファイルを置く
- 勝手な推測はしない
