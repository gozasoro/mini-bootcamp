# Mini Bootcamp
Mini Bootcampはプログラミングスクール運営者向けのプログラミングテスト作成サービスです。
受講生自身でプログラムの動作をチェック・確認ができるので、課題チェックの仕事を軽減します！

## OmniAuth
`credentials.yml.enc`にGitHubのclient_idとclient_secretを記載します。
```
# 開発用
dev:
  client_id:
  client_secret:
# 本番用
github:
  client_id:
  client_secret:
```

## 管理者設定
`credentials.yml.enc`に管理者のGitHub usernameを記載します。
```
admin: foo,bar #複数設定する場合はカンマで区切る
```
記載されている場合、ユーザー登録時にUserモデルの`admin`カラムが`true`になります。
- 登録後に管理者に設定
`bin/rake "admin:add[username]"`
- 管理者から削除
`bin/rake "admin:remove[username]"`
