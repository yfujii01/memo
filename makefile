APP_NAME = hoge
HEROKU_APP_NAME = f01hoge

all:
	@make 1_build
	@make 2_build
	heroku open

0:
	echo ${APP_NAME}

1:
	@make 1_build
	open http://localhost:3000
	cd ${APP_NAME} && rails s

1_build:
	bash 1_railsでdevise使ったサンプル.bash ${APP_NAME}

2:
	@make 2_build
	cd ${APP_NAME} && heroku open

2_build:
	bash 2_heroku設定.bash ${APP_NAME} ${HEROKU_APP_NAME}
