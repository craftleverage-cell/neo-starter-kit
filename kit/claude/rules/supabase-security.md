# Supabase Security Rules (Detailed)

## 目的
Supabase実装では、機能より先にセキュリティを満たす。危険な実装は不採用。

## 1. キー管理
- クライアントで許可: `NEXT_PUBLIC_SUPABASE_URL`, `NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY`（または anon）
- サーバー専用: `SUPABASE_SECRET_KEY`, `SUPABASE_SERVICE_ROLE_KEY`, DB password, JWT secret
- 禁止: `NEXT_PUBLIC_*` と secret/service_role の混在

## 2. クライアント分離
- `lib/supabase/client.ts`（公開キー）
- `lib/supabase/server.ts`（秘密キー）
- 秘密キー利用は API Routes / Server Actions / Edge Functions / バックエンド処理のみ

## 3. DB設計
- ユーザー所有テーブルは `user_id uuid references auth.users(id)` を必須化
- `created_at`, `updated_at` を持たせる
- `user_id` にインデックス作成

## 4. RLS
- すべてのユーザー向けテーブルでRLS有効化
- `select/insert/update/delete` のPolicyを揃える
- `using` と `with check` を適切設定
- 禁止: `using (true)` の安易な使用

## 5. 認証・認可
- サーバー処理先頭で `auth.getUser()` 必須
- クライアント入力の `user_id` を信用しない
- 管理者判定はサーバー側DBロールで検証（localStorage判定禁止）

## 6. クエリ
- RLSがあっても `.eq("user_id", user.id)` の所有者条件を明示
- 所有者条件なしの更新/削除/参照を禁止

## 7. Storage
- 機密は private bucket 前提
- パスは `{user_id}/...` 必須
- Storage RLSで folder先頭と `auth.uid()` を照合
- 署名URL長期有効化禁止

## 8. Auth設定
- 本番 Redirect URL は最小許可（ワイルドカード禁止）
- OAuth callback / メール確認 / Rate Limit を確認

## 9. ログ・エラー
- クライアントへ内部情報（SQL, stack trace, secret）を返さない
- ログは最小限、secret/PII出力禁止

## 10. 環境変数
- `.env.local` はGit管理禁止
- `.env.example` はキー名のみ（実値禁止）

## 11. マイグレーション
- テーブル、インデックス、RLS、Policy、grant/revoke をSQLで一体管理

## 12. 実装後の報告（必須）
- 変更内容
- RLS: OK/要確認
- secret露出: なし/要確認
- Auth確認: OK/要確認
- Storage RLS: OK/対象外/要確認
- 管理者チェック: OK/対象外/要確認
- 手動確認項目: Redirect URL / Rate Limits / Storage visibility / DB Policies
