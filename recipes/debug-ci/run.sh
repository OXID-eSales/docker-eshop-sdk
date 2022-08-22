#!/bin/bash

SCRIPT_PATH=$(dirname ${BASH_SOURCE[0]})

cd $SCRIPT_PATH/../../ || exit

# Read user input and set the
read -p "Enter image tag: " CI_IMAGE_TAG
export CI_IMAGE_TAG

# Prepare services configuration
make setup
make addbasicservices
make file=services/selenium-chrome.yml addservice

# Configure containers
perl -pi\
  -e 's#/var/www/#/var/www/oxideshop_template/source/#g;'\
  containers/httpd/project.conf

perl -pi\
  -e 's#error_reporting = .*#error_reporting = E_ALL & ~E_DEPRECATED & ~E_NOTICE & ~E_WARNING#g;'\
  -e 'print "xdebug.max_nesting_level=1000\n" if $. == 1'\
  containers/php/custom.ini

# Start all containers
make up

# Configure shop
docker-compose exec php sed -i "s#dbHost = '127.0.0.1'#dbHost = 'mysql'#g;" /var/www/oxideshop_template/source/config.inc.php
docker-compose exec php sed -i "s#dbName = 'oxid'#dbName = 'example'#g;" /var/www/oxideshop_template/source/config.inc.php
docker-compose exec php sed -i "s#dbPwd  = 'oxid'#dbPwd  = 'root'#g;" /var/www/oxideshop_template/source/config.inc.php
docker-compose exec php sed -i "s#http://core-ci.oxid-esales.com/#http://localhost.local/#g;" /var/www/oxideshop_template/source/config.inc.php
docker-compose exec php sed -i "s#http://core-ci-private.oxid-esales.com/#http://localhost.local/#g;" /var/www/oxideshop_template/source/config.inc.php
docker-compose exec php sed -i "s#/var/www/oxideshop/source#/var/www/oxideshop_template/source#g;" /var/www/oxideshop_template/source/config.inc.php
docker-compose exec php sed -i "s#/var/www/oxideshop/source/tmp#/var/www/oxideshop_template/source/tmp#g;" /var/www/oxideshop_template/source/config.inc.php

# Reset shop
docker-compose exec -T php php vendor/bin/reset-shop

echo "Done!"