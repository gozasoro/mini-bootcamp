# Mini Bootcamp
Mini Bootcampはプログラミングスクール運営者向けのプログラミングテスト作成サービスです。
受講生自身でプログラムの動作をチェック・確認ができるので、課題チェックの仕事を軽減します！

[![Image from Gyazo](https://i.gyazo.com/061849a8eb0654a790ec42fa7fd5b6dd.gif)](https://gyazo.com/061849a8eb0654a790ec42fa7fd5b6dd)

## インストール
```
$ bin/setup
$ bundle exec foreman start
```

## 動作環境
- Ruby 3.0.2
- Rails 6.1.4

コードの実行・判定に[Docker](https://www.docker.com/)を使用しているのでインストールが必要です(Linux版Docker, Docker Desktop for Mac)。
また、railsからDockerを動かすために[docker-api gem](https://github.com/upserve/docker-api)を使用しています。

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
