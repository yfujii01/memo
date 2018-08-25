APP_NAME = hoge
HEROKU_APP_NAME = f01hoge

all:
	@make 1
	@make 2
	@make 3

1:
	bash 1_railsでdevise使ったサンプル.bash ${APP_NAME}

2:
	bash 2_item追加.bash ${APP_NAME}

3:
	bash 3_heroku設定.bash ${APP_NAME} ${HEROKU_APP_NAME}

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
	cd ${APP_NAME} && git status -s | grep ^"??" | awk {'print $$2'} | xargs rm -rf
	cd ${APP_NAME} && rails db:migrate:reset

