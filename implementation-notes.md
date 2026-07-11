# Implementation Notes

## 2026-07-11 — フレームワーク半分（kit/claude framework部分 + kit/vault + install.sh + docs）を構築

作業範囲: `neo-starter-kit` のフレームワーク側全体。`kit/claude/skills/`・`docs/skills-catalog.md`・`docs/third-party-licenses.md` は別エージェントが並行で担当のため未着手（意図的にノータッチ）。

構築したもの:
- `kit/claude/`: CLAUDE.md（テンプレート化）、SOUL-full.md、rules/5本、agents/4本、output-styles/neo.md、hooks/5本（うち3本は設定ファイル参照型に書き換え）、settings.template.json、launch.example.json
- `kit/vault/`: 10個の番号付きフォルダ（`.gitkeep`含む）、`00_CEO_OS/`の2ファイルを新規執筆、`06_Logs/Decision_Log.md`新規、`_Templates/`4本（1本は1箇所編集）、`.obsidian/`5json、`vault/README.md`新規執筆
- `install.sh`: 14ステップのフル実装。macOS bash 3.2互換（連想配列・`${var,,}`不使用）。fake `$HOME` を使い、dry-run・実行・冪等性（再実行）・スペースを含むVaultパス・エラーハンドリング・対話プロンプトを個別にテスト済み
- `README.md` / `docs/FAQ.md` / `docs/roadmap.md` / `LICENSE` / `.gitignore`

git initはリポジトリ未作成のため未実施（指示通り、コミットはオーケストレーターに委ねる）。

## Deviations

### 1. CLAUDE.md「使い分けの原則」の再構成（解釈による判断）

指示文「remove the /codex-review reference; keep /supabase-security-review OUT too (v2) — reword that bullet to only reference shipped skills」がやや曖昧だったため、以下のように解釈して実装した:
- 差分レビューの箇条書きから `/codex-review` への言及を削除し、`/code-review`（組み込み）のみに絞った
- `Supabaseのセキュリティ検証 → /supabase-security-review` の箇条書き自体を丸ごと削除した（v2ロードマップ入りで同梱しないため）
- `/verify`・`/standup`・`/wrapup` の箇条書きは維持した。理由: `docs/roadmap.md` のv2候補リストにこの3つは含まれておらず、v1同梱スキルと判断した

### 2. CLAUDE.md「環境の地図」のObsidian行の説明文を簡略化

指示は「値を `{{VAULT_PATH}}` に置換」のみで説明列には言及がなかったが、元の説明文「本物。`iCloud~md~obsidian` 側はダミー」は特定の個人環境（iCloudの二重フォルダ問題）に依存した文脈であり、既定インストール先（`~/Documents/NeoVault`、iCloud外）には当てはまらないため、汎用的な説明「インストール時に指定した保管庫のパス」に差し替えた。

### 3. `audit-log.sh` — 想定されていたハードコードが実際には存在しなかった

指示は「`/Users/craftleverage/.claude/audit` のハードコードされたフォールバックを `$HOME/.claude/audit` に置換」だったが、実ファイルを確認したところ既に `$HOME/.claude/audit` を使用しており、ハードコードされたフォールバックは見当たらなかった。バイト同一のままコピーした（変更不要と判断）。「Neo通知ブランディングを維持」の指示についても、実際の通知タイトルは `"Claude Security Alert"` で "Neo" という文字列自体が元から存在しないため、変更なしでそのまま維持した。

### 4. `vault-daily-summary.sh` / `vault-project-sync.sh` の devroot パラメータ化

指示の `-v devroot="ClaudeCode"` を文字通りリテラル文字列として実装した（`neo-kit.conf` の `DEV_ROOT` から動的導出する方式も検討したが、単純さ・予測可能性を優先してリテラルにした）。また、`vault-daily-summary.sh` の `GIT_PUSHES` ブロック（指示の引用行範囲外）にも同じ `ClaudeCode` 正規表現があったため、「one-place-changeable」の趣旨に沿って同様にパラメータ化した。

いずれもsyntheticなVaultとactivityログを使い、`HOME`を差し替えたサンドボックスで実際に実行して動作を確認済み（プロジェクト振り分け・`.claude`バケットへの統合・gitコミット/push抽出のいずれも正しく動作）。

### 5. install.sh — Vault内の `.gitkeep` をインストール後に除去

明示的な指示はなかったが、`.gitkeep` はgit用の空フォルダ維持マーカーであり、ユーザーのVaultにそのまま配置すると意味のないファイルとしてObsidian上に見えてしまう。新規コピー時・差分コピー時のどちらでも、コピー後に `.gitkeep` ファイルのみ削除し、フォルダ自体は残す実装にした。

### 6. install.sh — Node.js/Obsidianの依存関係チェックは「提案表示のみ」

指示文中、Claude Codeの欠落時は「ASK y/n to run it now」と明記されていたが、Node.js/Obsidianについては「offer brew install ... if brew exists, else print URL」という表現に留まっていた。この差異を意図的な設計判断と解釈し、対話的インストール実行プロンプトはClaude Codeのみに実装し、Node.js/Obsidianはコマンド・URLの提示のみ（自動実行なし）とした。

### 7. settings.template.json — sed置換値の追加エスケープ

指示は「`|` をsed区切り文字に使う・スペースを含むパスはクォート注意」のみだったが、`$HOME` やVaultパスに `&` や `|` が含まれる稀なケース（例:「R&D Vault」）でも壊れないよう、置換文字列側で `\`・`&`・`|` をエスケープする `sed_escape_replacement()` を実装した。スペース・`&`・`|`・バックスラッシュを含むテストケースで動作確認済み。

### 8. README.md — curlワンライナーに技術的な補足を追加

指示された「中身を確認してから実行したい人はcloneを」という信頼面の注記に加え、`install.sh` が同じ場所の `kit/` フォルダに依存する設計上、リポジトリを手元に置かずにcurlワンライナー単体を実行すると必ずエラーで止まる、という技術的な制約も明記した。ユーザーの混乱を避けるための追記。

### 9. 最終sweepと「CraftLeverage」「craftleverage-cell」の扱い（解決済み）

指示された最終sweep対象語には `craftleverage`（大文字小文字無視）が含まれる一方、同じ指示書内で以下2箇所は明示的に `craftleverage` を含む文字列の使用を指示されている:

- `LICENSE` の著作権者を `CraftLeverage` にする（指示に明記）
- `README.md` のインストール手順で `github.com/craftleverage-cell/neo-starter-kit` を使う（指示のURL仮置き値、およびStep 0で `craftleverage-cell/claude-dotfiles` の存在・非公開を確認済み＝実在するGitHub organizationと判断）

この2つは指示书内で矛盾しているため、独断でどちらかを消さず、両方を指示通り実装した上でこのファイルに明記する。sweep結果としてこの2箇所（LICENSE 1件・README.md内のURL 2件）がヒットするのは意図的・想定内。他のヒットが無いことは別途確認済み（本体の報告を参照）。

→ **2026-07-11 同日、オーナー判断で確定**: LICENSEの「CraftLeverage」とREADMEの「github.com/craftleverage-cell/neo-starter-kit」URLは公開ブランド／組織名でありリークではない。両方ともそのまま維持。プレースホルダーへの差し替えは行わない。

### 10. スコープ変更対応（2026-07-11 同日・オーナー指示）

キットの方針が「フレームワークのみ（framework only）」に変更された。スキル担当エージェントが `kit/claude/skills/` を9本（neo-cockpit / wrapup / standup / devplan / grilling / blindspot / verify / security-audit / skill-creator-max）に削減済みであることを確認（ちょうど9ディレクトリ・過不足なし）。これに合わせてフレームワーク側ドキュメントを更新:

- **README.md**: 「31本」の記述を全廃。①イントロに「環境と仕事の回し方のフレームワークのみ。制作系・調査系・業務ナレッジ系スキルは含まれず、各自が `skill-creator-max` で育てる設計」というポジショニングを追加。④のスキル行を9本＋4分類（運用リズム系／計画系／品質系／拡張）の内訳表に差し替え、skills-catalog.md へリンク。⑤のステップ5に `/neo-cockpit` を明記
- **docs/roadmap.md**: 事業を推測させる固有スキル名のv2候補リストを全削除し、抽象的な項目（汎用開発スキル追加の検討／Windows対応の検討／英語版README）のみに差し替え
- **docs/FAQ.md**: 「スキルが動きません」を9本前提（APIキー不要・依存は実質gitのみ）に書き換え。「制作系・調査系のスキルが欲しい」というQ&Aを新設し、`skill-creator-max` での自作へ誘導
- **kit/claude/CLAUDE.md**: 使い分けの原則・ルール索引を点検。削除済みスキルへの言及はゼロであることを確認。同梱スキルの発見性向上のため `/neo-cockpit`・`/blindspot` の1行を使い分けの原則に追加（軽微な加筆）
