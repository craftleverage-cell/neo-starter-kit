---
name: security-audit
description: "Claude Code許可設定のレッドチーム/ブルーチーム型セキュリティ監査"
---

# Security Audit — Claude Code 許可設定監査

ブラックハッカー（攻撃者）とホワイトハッカー（防御者）の2エージェントを並列で走らせ、
現在のClaude Code許可設定を攻防両面から診断するスキル。

## 実行手順

### Step 1: 現状収集

以下のファイルを読み取る:

- `~/.claude/settings.json`
- `~/.claude/settings.local.json`
- `~/.claude/hooks/` 配下の全スクリプト
- `~/.claude/audit/` の直近ログ（あれば）

### Step 2: 2エージェント並列診断

**必ず2つのSubAgentを同時に（並列で）起動すること。**

#### Agent 1: ブラックハッカー（レッドチーム）

攻撃者の視点で、以下の観点から迂回・悪用手口を洗い出す:

```
攻撃観点チェックリスト:
1. deny迂回 — 許可コマンド経由でのネットワーク通信（Python urllib等）
2. 機密ファイルアクセス — .env, secrets/, .ssh/ の読み取り迂回
3. 任意コード実行 — python -c, npx, pip setup.py, git hooks等
4. ファイル破壊 — rm以外の削除パス（python shutil, git clean等）
5. サプライチェーン攻撃 — pip/npm タイポスクワッティング
6. git悪用 — force push, credential漏洩, config改竄
7. 権限昇格 — Edit + Bash 組み合わせチェーン
8. Edit/Write悪用 — .zshrc, LaunchAgents, CLAUDE.md改竄
9. hooks悪用 — PATH汚染、hook設定の改竄
```

各攻撃ベクトルについて報告:
- 攻撃名
- 危険度（Critical / High / Medium / Low）
- 具体的な攻撃コマンド例
- 影響範囲
- 推奨対策

#### Agent 2: ホワイトハッカー（ブルーチーム）

防御者の視点で、以下の観点から評価・強化策を提案する:

```
防御観点チェックリスト:
1. deny/askルールの有効性評価（迂回可能なルールの指摘）
2. 不足している防御の洗い出し
3. hooks活用の改善提案（検知パターン追加等）
4. 多層防御の評価
5. 監査ログの異常パターン分析
6. acceptEditsのリスク緩和策
7. 利便性とのバランス評価
```

各提案について報告:
- カテゴリ（防御層 / 不足点 / 強化提案）
- 優先度（Critical / High / Medium / Low）
- 具体的な内容
- 実装方法（設定変更 / hook追加 / 運用ルール）
- 利便性への影響（高 / 中 / 低 / なし）

### Step 3: 結果統合

両エージェントの結果を統合し、以下を出力する:

1. **リスク優先度マトリクス** — 全脆弱性を優先度順に一覧化
2. **前回からの変化** — `memory/security-audit.md` の前回監査結果と比較（初回実行時はこのファイルは存在しないため新規作成し、比較はスキップ。以後は前回分と比較する）
3. **アクションプラン** — 具体的な修正内容を優先度順に提示
4. **構造的限界** — 設定だけでは対応できないリスクの明示

### Step 4: 監査ログ確認

`~/.claude/audit/` の直近ログを確認し、以下をチェック:

- 異常な頻度のBashコマンド
- 機密ファイルへのアクセス痕跡（ALERT行）
- 見慣れないツール使用パターン

### Step 5: 修正実施（ユーザー承認後）

アクションプランに基づき、以下を更新:
- `settings.json` / `settings.local.json` のパーミッション
- hookスクリプトの検知パターン
- `memory/security-audit.md` に監査結果を追記

## 前回の監査記録

詳細は `~/.claude/projects/<ホームパスから自動生成>/memory/security-audit.md`（ディレクトリ名はホームパスから自動生成。実際の名前は `~/.claude/projects/` 配下を確認）を参照（未作成の場合は初回監査時に新規作成する）。

## 注意事項

- 設定変更前に必ずユーザーの承認を取る
- deny > ask > allow の優先順位を意識する
- 監査結果は必ず `memory/security-audit.md` に記録する
