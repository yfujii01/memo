APP_NAME = hoge
HEROKU_APP_NAME = f01hoge

all:
	@make 1_build
	@make 2

1:
	@make 1_build
	@make local_open

1_build:
	bash 1_railsでdevise使ったサンプル.bash ${APP_NAME}

local_open:
	open http://localhost:3000
	cd ${APP_NAME} && rails s

2:
	@make 2_build
	@make heroku_open

2_build:
	bash 2_heroku設定.bash ${APP_NAME} ${HEROKU_APP_NAME}

heroku_open:
	cd ${APP_NAME} && heroku open

3:
	@make 3_build
	@make local_open

3_build:
	@make reset
	bash 3_item追加.bash ${APP_NAME}

reset:
	cd ${APP_NAME} && git checkout .
	cd ${APP_NAME} && git status -s | grep ^"??" | awk {'print $2'} | xargs rm -rf
	cd ${APP_NAME} && rails db:migrate:reset

