# devise gemを使用したログイン機能を作成するサンプル

rails new アプリ名

cd アプリ名

# gem追加
bundle add devise

# ログイン機能追加
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

# 初期設定	機能	概要
# o	database_authenticatable	サインイン時にユーザーの正当性を検証するためにパスワードを暗号化してDBに登録します。認証方法としてはPOSTリクエストかHTTP Basic認証が使えます。
# o	registerable	登録処理を通してユーザーをサインアップします。また、ユーザーに自身のアカウントを編集したり削除することを許可します。
# o	recoverable	パスワードをリセットし、それを通知します。
# o	rememberable	保存されたcookieから、ユーザーを記憶するためのトークンを生成・削除します。
# o	trackable	サインイン回数や、サインイン時間、IPアドレスを記録します。
# o	validatable	Emailやパスワードのバリデーションを提供します。独自に定義したバリデーションを追加することもできます。
# x	confirmable	メールに記載されているURLをクリックして本登録を完了する、といったよくある登録方式を提供します。また、サインイン中にアカウントが認証済みかどうかを検証します。
# x	lockable	一定回数サインインを失敗するとアカウントをロックします。ロック解除にはメールによる解除か、一定時間経つと解除するといった方法があります。
# x	timeoutable	一定時間活動していないアカウントのセッションを破棄します。
# x	omniauthable	intridea/omniauthをサポートします。TwitterやFacebookなどの認証を追加したい場合はこれを使用します。

# Userモデルの編集
cat <<EOS > app/models/user.rb
class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :confirmable, :lockable, :timeoutable
end
EOS

# マイグレーションファイルの編集
cnf=$(find . -name "*devise_create_users.rb")
sed -i 's/      # t/      t/g' ${cnf}
sed -i 's/    # add_index /    add_index /g' ${cnf}
cnf=''

# DB反映
rails db:migrate
