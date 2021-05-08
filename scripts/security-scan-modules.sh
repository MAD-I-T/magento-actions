#!/usr/bin/env bash

set -e

PROJECT_PATH="$(pwd)"



mkdir -p ~/.n98-magerun2/modules
cd ~/.n98-magerun2/modules
git clone https://github.com/gwillem/magevulndb.git


cd $PROJECT_PATH/magento
#/usr/local/bin/composer install --no-dev --no-progress
#chmod +x bin/magento

php /opt/magerun/n98-magerun2-latest.phar dev:module:security

