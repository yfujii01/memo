# devise gemを使用したログイン機能を作成するサンプル

rails new アプリ名

cd アプリ名

bundle add devise

rails g devise:install

# 最後から2行目にメール用の設定をする
cnf=config/environments/development.rb
ln=`grep -n config.file_watcher ${cnf}  | sed -e 's/:.*//g' | head -1`
cat << 'EOS' | sed -i ${ln}'r /dev/stdin' ${cnf}

  # mailer setting
  config.action_mailer.default_url_options = { host: 'localhost', port: 3000 }
EOS
cnf=''

rails g controller Pages index show

# rootページを変更
sed -i 's@get '\''pages/index'\''@root '\''pages#index'\''@' config/routes.rb

rails g devise:views

# app/views/devise/shared/_links.html.erb (リンク用パーシャル)
# app/views/devise/confirmations/new.html.erb (認証メールの再送信画面)
# app/views/devise/passwords/edit.html.erb (パスワード変更画面)
# app/views/devise/passwords/new.html.erb (パスワードを忘れた際、メールを送る画面)
# app/views/devise/registrations/edit.html.erb (ユーザー情報変更画面)
# app/views/devise/registrations/new.html.erb (ユーザー登録画面)
# app/views/devise/sessions/new.html.erb (ログイン画面)
# app/views/devise/unlocks/new.html.erb (ロック解除メール再送信画面)
# app/views/devise/mailer/confirmation_instructions.html.erb (メール用アカウント認証文)
# app/views/devise/mailer/password_change.html.erb （メール用パスワード変更完了文）
# app/views/devise/mailer/reset_password_instructions.html.erb (メール用パスワードリセット文)
# app/views/devise/mailer/unlock_instructions.html.erb (メール用ロック解除文)

rails g devise User

