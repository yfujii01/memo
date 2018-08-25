#!/usr/bin/env bash
# 第1引数にアプリ名
APP_NAME=${1}

if [ -z ${1} ]; then
  echo '引数にアプリ名を渡してください'
  exit
fi

cd ${APP_NAME}

# itemを追加
rails g scaffold post title:string body:text
rails g migration AddUserRefToPosts user:references

# userモデルにpostsを紐付ける(1:N)
cnf=./app/models/user.rb
findmes='class.User.<.ApplicationRecord'
cat<<'EOS' | ruby -i -e 'puts ARGF.read.gsub(/('${findmes}'.*\n)/, "\\1#{STDIN.read}")' ${cnf}
  has_many :posts, dependent: :destroy
EOS

# 投稿
cnf=./app/views/posts/_form.html.erb
findmes='actions'
cat<<'EOS' | ruby -i -e 'puts ARGF.read.gsub(/(\n.*'${findmes}')/, "#{STDIN.read}\\1")' ${cnf}
  <%= form.hidden_field :user_id, value: current_user.id %>
EOS

# 投稿へのリンクをメニューに追加
cnf=./app/views/layouts/application.html.erb
findmes='プロフィール変更'
cat<<'EOS' | ruby -i -e 'puts ARGF.read.gsub(/(\n.*'${findmes}')/, "#{STDIN.read}\\1")' ${cnf}
  <%= link_to 'ポスト', posts_path %>
EOS

# db migrate
rails db:migrate
