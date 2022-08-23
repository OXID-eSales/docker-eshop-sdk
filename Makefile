USERID = `id -u`
USERNAME = `id -un`
GROUPID = `id -g`
GROUPNAME = `id -gn`

default: help

help:
	@echo "\n\
	    \e[1;1;33mSome Help needed?\e[0m\n\n\
	    \e[1;1;32mmake setup\e[0m - Prefills the .env file with sync required parameters \n\
	        and prepares all modifiable custom files from dist. Run this \n\
	        once before everything!\n\n\
	    \e[1;1;32mmake addbasicservices\e[0m - Adds php, apache and mysql services \n\
	    \e[1;1;32mmake file=... addservice\e[0m - Prepend file contents to current docker-compose.yml file\n\n\
	    \e[1;1;32mmake up\e[0m - Start all configured containers (have you run setup command already?)!\n\
	    \e[1;1;32mmake down\e[0m - Stop all configured containers\n\n\
	    \e[1;1;32mmake example\e[0m - Setup basic services + Runs example recipe\n\n\
	    \e[1;1;32mmake php\e[0m - Connect to php container shell\n\
	    \e[1;1;32mmake node\e[0m - Connect to node container shell\n\
	"

setup:
	@cat .env.dist | \
		sed "s/<userId>/$(USERID)/;\
		     s/<userName>/$(USERNAME)/;\
		     s/<groupId>/$(GROUPID)/;\
		     s/<groupName>/$(GROUPNAME)/;\
		     s/<CI_IMAGE_TAG>/$(CI_IMAGE_TAG)/"\
		> .env
	@cp -n containers/httpd/project.conf.dist containers/httpd/project.conf
	@cp -n containers/php/custom.ini.dist containers/php/custom.ini
	@cp -n docker-compose.yml.dist docker-compose.yml
	@echo "Setup done! Add basic services with \e[1;1;32mmake addbasicservices\e[0m and start everything \e[1;1;32mmake up\e[0m"

config:
	docker-compose exec php sed -i "s#dbHost = '127.0.0.1'#dbHost = 'mysql'#g;" /var/www/oxideshop_template/source/config.inc.php \
    && docker-compose exec php sed -i "s#dbName = 'oxid'#dbName = 'example'#g;" /var/www/oxideshop_template/source/config.inc.php \
    && docker-compose exec php sed -i "s#dbPwd  = 'oxid'#dbPwd  = 'root'#g;" /var/www/oxideshop_template/source/config.inc.php \
    && docker-compose exec php sed -i "s#http://core-ci.oxid-esales.com/#http://localhost.local/#g;" /var/www/oxideshop_template/source/config.inc.php \
    && docker-compose exec php sed -i "s#http://core-ci-private.oxid-esales.com/#http://localhost.local/#g;" /var/www/oxideshop_template/source/config.inc.php \
    && docker-compose exec php sed -i "s#/var/www/oxideshop/source#/var/www/oxideshop_template/source#g;" /var/www/oxideshop_template/source/config.inc.php \
    && docker-compose exec php sed -i "s#/var/www/oxideshop/source/tmp#/var/www/oxideshop_template/source/tmp#g;" /var/www/oxideshop_template/source/config.inc.php

example:
	@make addbasicservices
	@./recipes/default/example/run.sh

up:
	docker-compose up --build -d

down:
	docker-compose down --remove-orphans

php:
	docker-compose exec php bash

reset-shop:
	docker-compose exec -T php php vendor/bin/reset-shop

node:
	docker-compose run --rm node bash

addservice:
	@cat $(file) >> docker-compose.yml
	@echo "\n" >> docker-compose.yml
	@echo "Service file $(file) contents added\n";

addbasicservices:
	@make file=services/apache.yml addservice
	@make file=services/php.yml addservice
	@make file=services/mysql.yml addservice
	@echo "php, apache and mysql related services added\n";
