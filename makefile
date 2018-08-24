APP_NAME = hoge
HEROKU_APP_NAME = f01hoge

all:
	@make 1_build
	@make 2

1:
	@make 1_build
	@make 1_open

1_build:
	bash 1_railsでdevise使ったサンプル.bash ${APP_NAME}

1_open:
	open http://localhost:3000
	cd ${APP_NAME} && rails s

2:
	@make 2_build
	@make 2_open

2_build:
	bash 2_heroku設定.bash ${APP_NAME} ${HEROKU_APP_NAME}

2_open:
	cd ${APP_NAME} && heroku open
