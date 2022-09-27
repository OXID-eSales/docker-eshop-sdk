#!/bin/bash

SCRIPT_PATH=$(dirname ${BASH_SOURCE[0]})
USERID=$(id -u)
USERNAME=$(id -un)
GROUPID=$(id -g)
GROUPNAME=$(id -gn)

cd $SCRIPT_PATH/../../ || exit

# Read user input and write .env file
read -p "Enter build hash: " CI_IMAGE_TAG
export CI_IMAGE_TAG

cat .env.dist | \
		sed "s/<userId>/${USERID}/;\
		     s/<userName>/${USERNAME}/;\
		     s/<groupId>/${GROUPID}/;\
		     s/<groupName>/${GROUPNAME}/;\
		     s/<CI_IMAGE_TAG>/${CI_IMAGE_TAG}/"\
		> .env

# Cleanup source
make cleanup

# Copy files from CI image
make files

# Prepare services configuration
make setup
make addbasicservices
make file=services/selenium-chrome.yml addservice

# Configure containers
perl -pi\
  -e 's#/var/www/#/var/www/source/#g;'\
  containers/httpd/project.conf

perl -pi\
  -e 's#error_reporting = .*#error_reporting = E_ALL & ~E_DEPRECATED & ~E_NOTICE & ~E_WARNING#g;'\
  -e 'print "xdebug.max_nesting_level=1000\n" if $. == 1'\
  containers/php/custom.ini

# Start all containers
make up

# Configure shop
make config

sleep 2

# Reset shop
make reset-shop

echo "Done!"