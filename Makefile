USERID = `id -u`
USERNAME = `id -un`
GROUPID = `id -g`
GROUPNAME = `id -gn`

default: help

help:
	@printf "\n\
	    \e[1;1;33mSome Help needed?\e[0m\n\n\
	    \e[1;1;32mmake setup\e[0m - Prefills the .env file with sync required parameters \n\
	        and prepares all modifiable custom files from dist. Run this \n\
	        once before everything!\n\n\
	    \e[1;1;32mmake addbasicservices\e[0m - Adds php, apache and mysql services \n\
	    \e[1;1;32mmake file=... addservice\e[0m - Prepend file contents to current docker-compose.yml file\n\n\
	    \e[1;1;32mmake up\e[0m - Start all configured containers (have you run setup command already?)!\n\
	        \e[1;1;32mUse with ENABLE_CERTS=true|false\e[0m to control SSL certificate generation.\n\
	        Defaults to \e[1;1;32mtrue\e[0m. Example:\n\
	        \e[1;1;32mmake up ENABLE_CERTS=true\e[0m\n\n\
	    \e[1;1;32mmake down\e[0m - Stop all configured containers\n\n\
	    \e[1;1;32mmake example\e[0m - Setup basic services + Runs example recipe\n\n\
	    \e[1;1;32mmake php\e[0m - Connect to php container shell\n\
	    \e[1;1;32mmake node\e[0m - Connect to node container shell\n\
	"

setup-mkcert:
	@bash scripts/setup-mkcert.sh

generate-certificates: setup-mkcert
	@echo "=============================="
	@echo "Generating SSL certificates using mkcert..."
	@mkdir -p containers/httpd/certs
	@mkcert -key-file containers/httpd/certs/server.key -cert-file containers/httpd/certs/server.crt localhost.local localhost 127.0.0.1
	@echo "Certificates generated and stored in containers/httpd/certs."
	@echo "=============================="

# Default value for enabling certificate generation
ENABLE_CERTS ?= false

setup:
	@cat .env.dist | \
		sed "s/<userId>/$(USERID)/;\
		     s/<userName>/$(USERNAME)/;\
		     s/<groupId>/$(GROUPID)/;\
		     s/<groupName>/$(GROUPNAME)/"\
		> .env
	@cp -n containers/httpd/project.conf.dist containers/httpd/project.conf
	@cp -n containers/php/custom.ini.dist containers/php/custom.ini
	@cp -n docker-compose.yml.dist docker-compose.yml
ifeq ($(ENABLE_CERTS), true)
	@make generate-certificates
else
	@echo "Skipping certificate generation and trust setup as ENABLE_CERTS=false."
endif
	@printf "Setup done! Add basic services with \e[1;1;32mmake addbasicservices\e[0m and start everything \e[1;1;32mmake up\e[0m\n"

example:
	@make addbasicservices
	@./recipes/default/example/run.sh

up:
	@printf "Starting containers...\n"
ifeq ($(ENABLE_CERTS), true)
	@echo "SSL certificate generation enabled."
	@make generate-certificates
else
	@echo "Skipping SSL certificate generation (ENABLE_CERTS=false)."
endif
	docker compose up --build -d
	@printf "Containers are up and running!\n"


down:
	docker compose down --remove-orphans

php:
	docker compose exec php bash

generate-docs:
	docker compose run --rm sphinx sphinx-build /home/$(USERNAME)/docs /home/$(USERNAME)/docs/build

node:
	docker compose run --rm node bash

addservice:
	@cat $(file) >> docker-compose.yml
	@printf "\n" >> docker-compose.yml
	@printf "Service file $(file) contents added\n";

addbasicservices:
	@make file=services/apache.yml addservice
	@make file=services/php.yml addservice
	@make file=services/mailpit.yml addservice
	@make file=services/mysql.yml addservice
	@printf "php, apache and mysql related services added\n";

addsphinxservice:
	@printf "\nDOC_PATH=$(docpath)" >> .env
	@make file=services/sphinx.yml addservice

cleanup:
	-make down
	-[ -d "source" ] && rm -rf source
	-[ -e ".env" ] && rm .env
	-[ -e "docker-compose.yml" ] && rm docker-compose.yml
	-[ -e "containers/httpd/project.conf" ] && rm containers/httpd/project.conf
	-[ -e "containers/php/custom.ini" ] && rm containers/php/custom.ini
	-[ -d "data/mysql" ] && rm -rf data/mysql/*
	-[ -d "data/composer/cache" ] && rm -rf data/composer/cache
