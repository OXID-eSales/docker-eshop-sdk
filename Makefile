PHONY: init permissions up down reset doc wiki test reset reset-db coverage shell clean composer

shell:
	docker-compose exec --user oxid php bash

test:
	docker-compose exec -T --user oxid php php vendor/bin/runtests
	docker-compose exec -T --user oxid php php vendor/bin/runtests-codeception
	docker-compose up -d selenium
	docker-compose exec -T --user oxid php php vendor/bin/runtests-selenium

coverage:
	docker-compose exec -T --user oxid php php vendor/bin/runtests-coverage

reset-db:
	docker-compose exec -T --user oxid php php vendor/bin/reset-shop
	
clean:
	rm data/oxideshop/vendor/ -rf
	rm data/oxideshop/composer.lock -f
	rm data/oxideshop/source/tmp/* -rf
	rm data/oxideshop/source/Application/views/flow/ -rf
	rm data/oxideshop/source/Application/views/azure/ -rf
	rm data/oxideshop/var/ -rf

reset: clean data/oxideshop/vendor/ reset-db

doc: data/dev-doc/build/

wiki: data/dev-wiki/build/

up:
	docker-compose up -d
	
down: 
	docker-compose down

restart:
	docker-compose restart
	
show-log:
	docker-compose exec -T --user oxid php tail -f /var/www/oxideshop/source/log/oxideshop.log

init: .env data/oxideshop/ permissions data/oxideshop/vendor/ data/oxideshop/source/config.inc.php up reset-db

.env: .env.dist
	if [ ! -f .env ]; then \
		cp .env.dist .env; \
		sed -i s/HOST_USER_ID=1000/HOST_USER_ID=`id -u`/ .env; \
		sed -i s/HOST_GROUP_ID=1000/HOST_GROUP_ID=`id -g`/ .env; \
	fi


composer: data/oxideshop/vendor/

migrate:
	docker-compose exec -T --user oxid php php vendor/bin/oe-eshop-db_migrate migrations:migrate

migration:
	docker-compose exec -T --user oxid php php vendor/bin/oe-eshop-db_migrate migrations:generate

data/oxideshop/vendor/: data/oxideshop/composer.lock
	docker-compose run -T --rm --no-deps --user oxid php composer install

data/oxideshop/composer.lock: data/oxideshop/composer.json
	docker-compose run -T --rm --no-deps --user oxid php composer update

data/oxideshop/composer.json: data/oxideshop/

data/oxideshop/:
	git clone -b b-6.3.x --single-branch git@github.com:OXID-eSales/oxideshop_ce.git data/oxideshop
	mkdir data/oxideshop/debug

permissions: data/oxideshop/ data/oxideshop/source/config.inc.php
	chmod 777 data/oxideshop/source/tmp/ \
	          data/oxideshop/source/out/pictures/ \
	          data/oxideshop/source/out/media/ \
	          data/oxideshop/source/log/ \
	          data/oxideshop/source/config.inc.php \
	          data/oxideshop/source/.htaccess \
	          -R
	chmod +r data/oxideshop/source/export

data/oxideshop/source/config.inc.php: data/oxideshop/source/config.inc.php.dist
	cp data/oxideshop/source/config.inc.php.dist data/oxideshop/source/config.inc.php
	sed -i -e 's/<dbHost>/db/' \
	    -e 's/<dbUser>/root/' \
	    -e 's/<dbName>/oxid/' \
	    -e 's/<dbPwd>/oxid/' \
	    -e 's/<dbPort>/3306/' \
	    -e 's/<sShopURL>/http:\/\/oxideshop.local\//' \
	    -e 's/<sShopDir>/\/var\/www\/oxideshop\/source/' \
	    -e 's/<sCompileDir>/\/var\/www\/oxideshop\/source\/tmp/' data/oxideshop/source/config.inc.php

data/dev-doc/build/: data/dev-doc/
	docker-compose run -T --rm sphinx sphinx-build ./dev-doc/ ./dev-doc/build

data/dev-doc/:
	git clone git@github.com:OXID-eSales/developer_documentation.git data/dev-doc/

data/dev-wiki/build/: data/dev-wiki/
	docker-compose run -T --rm sphinx sphinx-build ./dev-wiki/ ./dev-wiki/build

data/dev-wiki/:
	git clone git@github.com:OXID-eSales/development-wiki.git data/dev-wiki/
