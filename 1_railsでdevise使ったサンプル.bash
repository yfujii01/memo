#!/usr/bin/env bash
# devise gemを使用したログイン機能を作成するサンプル

# 第1引数にアプリ名
APP_NAME=${1}

if [ -z ${1} ]; then
  echo '引数にアプリ名を渡してください'
  exit
fi

# アプリ作成
[ -e ${APP_NAME} ] && rm -rf ${APP_NAME}
rails new ${APP_NAME}
cd ${APP_NAME}
git add -A
git commit -m 'rails new'

# gem追加
bundle add devise
bundle add devise-i18n

# メールをブラウザで確認できるgem
## メールに日本語が混ざるとContent-Transfer-Encoding: base64
## となり、ログでの解読が困難
bundle add letter_opener --group development

# ログイン機能追加(devise installが止まるときがあるのでspring stopを念の為入れる)
bundle exec spring stop
rails g devise:install

# メール用の設定をする
## ${cnf}のファイルに対して
## ${findmes}の文言の次の行に
## ${instr}を埋め込む
cnf=./config/environments/development.rb
findmes='config.file_watcher'
cat<<'EOS' | ruby -i -e 'puts ARGF.read.gsub(/('${findmes}'.*\n)/, "\\1#{STDIN.read}")' ${cnf}

  # mailer setting
  config.action_mailer.default_url_options = { host: 'localhost', port: 3000 }

  # mail check on browser by letter_opener gem
  config.action_mailer.delivery_method = :letter_opener

EOS

# locale日本語設定
cnf=./config/application.rb
findmes='config.load_defaults'
cat<<'EOS' | ruby -i -e 'puts ARGF.read.gsub(/('${findmes}'.*\n)/, "\\1#{STDIN.read}")' ${cnf}

    config.i18n.default_locale = :ja
EOS

# トップページおよびユーザーページ作成
rails g controller Pages index show

# rootページを変更
cnf=./config/routes.rb
findmes="get.+pages\/index"
# 行挿入
cat<<'EOS' | ruby -i -e 'puts ARGF.read.gsub(/('${findmes}'.*\n)/, "\\1#{STDIN.read}")' ${cnf}
	root 'pages#index'
EOS
# 対象行削除
ruby -i -e 'puts ARGF.read.gsub(/(.+'${findmes}'.+)\n/, "")' ${cnf}

# ログイン関連機能を編集可能にする(日本語)
rails g devise:i18n:views

# ログイン関連機能を編集可能にする(英語)
# rails g devise:views

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

# ユーザー管理テーブル作成
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
cat <<EOS > ./app/models/user.rb
class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :confirmable, :lockable, :timeoutable
end
EOS

# マイグレーションファイルの編集
## ${cnf}のファイルに対して
## ${findmes}の文言を
## ${instr}に置換する
cnf=$(find . -name "*devise_create_users.rb")
findmes="#.t\."
instr="t."
ruby -i -e 'puts ARGF.read.gsub(/'${findmes}'/, "'${instr}'")' ${cnf}

findmes="#.add_index"
instr="add_index"
ruby -i -e 'puts ARGF.read.gsub(/'${findmes}'/, "'${instr}'")' ${cnf}


# ユーザー情報にユーザー名を追加
rails g migration add_columns_to_users username

# DB反映
rails db:migrate

# サインアップページにユーザー名の項目を追加する
cnf=./app/views/devise/registrations/new.html.erb
findmes=',.autofocus:.true'
ruby -i -e 'puts ARGF.read.gsub(/'${findmes}'/, "")' ${cnf}
findmes='devise_error_messages'
cat<<'EOS' | ruby -i -e 'puts ARGF.read.gsub(/('${findmes}'.*\n)/, "\\1#{STDIN.read}")' ${cnf}

  <div class="field">
    <%= f.label :ユーザー名 %><br />
    <%= f.text_field :username, autofocus: true %>
  </div>
EOS

# プロフィール編集ページにユーザー名の項目を追加する
cnf=./app/views/devise/registrations/edit.html.erb
findmes=',.autofocus:.true'
ruby -i -e 'puts ARGF.read.gsub(/'${findmes}'/, "")' ${cnf}
findmes='devise_error_messages'
cat<<'EOS' | ruby -i -e 'puts ARGF.read.gsub(/('${findmes}'.*\n)/, "\\1#{STDIN.read}")' ${cnf}

  <div class="field">
    <%= f.label :ユーザー名 %><br />
    <%= f.text_field :username, autofocus: true %>
  </div>
EOS


# DBへの登録項目にユーザー名の項目を追加する
cnf=./app/controllers/application_controller.rb
findmes='class.ApplicationController.<.ActionController::Base'
cat<<'EOS' | ruby -i -e 'puts ARGF.read.gsub(/('${findmes}'.*\n)/, "\\1#{STDIN.read}")' ${cnf}
  protect_from_forgery with: :exception
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:username])
    devise_parameter_sanitizer.permit(:account_update, keys: [:username])
  end
EOS

# ログイン情報を表示するheaderを作る
cnf=./app/views/layouts/application.html.erb
findmes='<body>'
## ヒアドキュメントでないとタグを正常に取り込めない
cat<<'EOS' | ruby -i -e 'puts ARGF.read.gsub(/('${findmes}'.*\n)/, "\\1#{STDIN.read}")' ${cnf}
    <header>
      <nav>
        <% if user_signed_in? %>
        <strong><%= link_to current_user.username, pages_show_path %></strong>
        <%= link_to 'プロフィール変更', edit_user_registration_path %>
        <%= link_to 'ログアウト', destroy_user_session_path, method: :delete %>
      <% else %>
        <%= link_to 'サインアップ', new_user_registration_path %>
        <%= link_to 'ログイン', new_user_session_path %>
        <% end %>
      </nav>
    </header>

    <p id="notice"><%= notice %></p>
    <p id="alert"><%= alert %></p>
EOS

# スマホ対応
cnf=./app/views/layouts/application.html.erb
findmes='csp_meta_tag'
cat<<'EOS' | ruby -i -e 'puts ARGF.read.gsub(/('${findmes}'.*\n)/, "\\1#{STDIN.read}")' ${cnf}
    <meta name="viewport" content="width=device-width, initial-scale=1">
EOS

# トップページ
cat << EOS >./app/views/pages/index.html.erb
<h1>ようこそ</h1>
<p>トップページです。</p>
EOS

# ユーザーページ
cat << EOS >./app/views/pages/show.html.erb
<% if current_user == nil %>
<h2>こんにちは、ログインしてください</h2>
<% else %>
<h1>こんにちは、<%= current_user.username %>さん</h1>
<% end %>
<p>ユーザー用ページです。</p>
EOS

# seed
cat << EOS >>./db/seeds.rb
user = User.new(:username => 'aaa',
                :email => 'a@a.a',
                :password => 'password'
)
user.skip_confirmation!
user.save

user = User.new(:username => 'bbb',
                :email => 'b@b.b',
                :password => 'password'
)
user.skip_confirmation!
user.save

user = User.new(:username => 'ccc',
                :email => 'c@c.c',
                :password => 'password'
)
user.skip_confirmation!
user.save
EOS



git add -A
git commit -m '雛型完成'
