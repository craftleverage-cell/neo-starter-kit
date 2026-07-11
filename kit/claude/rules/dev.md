# 開発規約

## 言語・ランタイム

| 用途 | 標準 |
|---|---|
| バックエンド | Python 3.9+ |
| フロントエンド | 未定（プロジェクト毎に選定） |
| パッケージ管理 | `pip` + `venv`（または `uv`） |
| ランタイム管理 | pyenv（バージョン固定） |

## プロジェクト構成の基本

```
[project-root]/
├── CLAUDE.md          ← プロジェクト固有ルール（必須）
├── config/
│   ├── .env           ← APIキー（chmod 600・gitignore必須）
│   └── settings.py    ← 設定値の一元管理
├── modules/           ← 機能モジュール群
├── scripts/           ← 実行スクリプト群
├── tests/             ← ユニットテスト群
├── assets/            ← 静的リソース
├── outputs/           ← 生成物（gitignore推奨）
├── docs/              ← ドキュメント
│   └── strategy/      ← 事業戦略・方針
├── requirements.txt
└── .gitignore
```

## セキュリティルール

- `.env` は必ず `.gitignore` に含める
- APIキーはコードにハードコードしない
- `chmod 600 config/.env` を徹底

## コーディング方針

- モジュールは単一責任原則に従う
- 設定値はすべて `config/settings.py` に集約
- テストは `tests/` に必ず作成
- ログは適切なレベル（DEBUG/INFO/ERROR）で出力

## Git運用

- コミット前に `.env` が含まれていないか確認
- コミットメッセージは日本語可
- `outputs/` は基本的にgitignore
