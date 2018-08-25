#!/usr/bin/env bash
# 第1引数にアプリ名
APP_NAME=${1}
# 第2引数にherokuアプリ名
HEROKU_APP_NAME=${2}

if [ -z ${2} ]; then
  echo '引数にアプリ名とherokuのアプリ名を渡してください'
  exit
fi

cd ${APP_NAME}

# smtp設定
cnf=./config/environment.rb
findmes='Rails.application.initialize!'
cat<<'EOS' | ruby -i -e 'puts ARGF.read.gsub(/('${findmes}'.*\n)/, "\\1#{STDIN.read}")' ${cnf}

ActionMailer::Base.smtp_settings = {
  :address              => 'smtp.sendgrid.net',
  :port                 => '587',
  :authentication       => :plain,
  :user_name            => ENV['SENDGRID_USERNAME'],
  :password             => ENV['SENDGRID_PASSWORD'],
  :domain               => 'heroku.com',
  :enable_starttls_auto => true
}
EOS

# メール用の設定をする
cnf=./config/environments/production.rb
findmes='config.active_record.dump_schema_after_migration'
cat<<EOS | ruby -i -e 'puts ARGF.read.gsub(/('${findmes}'.*\n)/, "\\1#{STDIN.read}")' ${cnf}

  # mailer setting
  config.action_mailer.default_url_options = { :host => '${HEROKU_APP_NAME}.herokuapp.com', :protocol => 'https' }
EOS

# DB設定
cnf=./Gemfile
findmes='gem..sqlite3.\n'
cat<<EOS | ruby -i -e 'puts ARGF.read.gsub(/'${findmes}'/, "\\1#{STDIN.read}")' ${cnf}
gem 'sqlite3', group: :development
# 本番ではpostgressを使用する
gem 'pg', group: :production
EOS
bundle install --without production

# heroku設定(同名のアプリは上書き)
heroku destroy ${HEROKU_APP_NAME} --confirm ${HEROKU_APP_NAME}
heroku create ${HEROKU_APP_NAME}

# sendgrid(MAILアドオン追加)
heroku addons:add sendgrid:starter

# herokuへpush
git add -A
git commit -m 'setting heroku'
git push heroku master

# DB migrate
heroku run rails db:migrate
