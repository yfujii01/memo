APP_NAME = hoge
HEROKU_APP_NAME = f01hoge

all:
	@make 1_build
	@make 2

1:
	@make 1_build
	@make open_local

1_build:
	bash 1_railsでdevise使ったサンプル.bash ${APP_NAME}

2:
	@make 2_build
	@make open_heroku

2_build:
	bash 2_heroku設定.bash ${APP_NAME} ${HEROKU_APP_NAME}

3:
	@make 3_build
	@make open_local

3_build:
	@make reset
	bash 3_item追加.bash ${APP_NAME}

open_local:
	@make close_local
	cd ${APP_NAME} && rails db:migrate:reset
	cd ${APP_NAME} && rails db:seed
	cd ${APP_NAME} && rails s -d
	open http://localhost:3000

close_local:
	ps aux > ps.log
	cat ps.log | grep localhost:3000 | awk '{print $$2}' | xargs kill -9
	rm ps.log

open_heroku:
	cd ${APP_NAME} && heroku open

reset:
	cd ${APP_NAME} && git checkout .
	cd ${APP_NAME} && git status -s | grep ^"??" | awk {'print $2'} | xargs rm -rf
	cd ${APP_NAME} && rails db:migrate:reset

