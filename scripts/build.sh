#!/usr/bin/env bash

set -e

PROJECT_PATH="$(pwd)"

cd $PROJECT_PATH/magento

/usr/local/bin/composer install --no-dev --no-progress
chmod +x bin/magento

mysqladmin -h mysql -u root -pmagento status

if [ $INPUT_ELASTICSUITE = 1 ]
then
  bin/magento setup:install --admin-firstname="local" --admin-lastname="local" --admin-email="local@local.com" --admin-user="local" --admin-password="local123" --base-url="http://magento.build/" --backend-frontname="admin" --db-host="mysql" --db-name="magento" --db-user="root" --db-password="magento" --use-secure=0 --use-rewrites=1 --use-secure-admin=0 --session-save="db" --currency="EUR" --language="en_US" --timezone="Europe/Rome" --cleanup-database --skip-db-validation --es-hosts="elasticsearch:9200" --es-user="" --es-pass=""
else
  bin/magento setup:install --admin-firstname="local" --admin-lastname="local" --admin-email="local@local.com" --admin-user="local" --admin-password="local123" --base-url="http://magento.build/" --backend-frontname="admin" --db-host="mysql" --db-name="magento" --db-user="root" --db-password="magento" --use-secure=0 --use-rewrites=1 --use-secure-admin=0 --session-save="db" --currency="EUR" --language="en_US" --timezone="Europe/Rome" --cleanup-database --skip-db-validation
fi

#--key=magento \

bin/magento setup:di:compile
bin/magento deploy:mode:set --skip-compilation production

bin/magento setup:static-content:deploy
#bin/magento setup:static-content:deploy en_US  -a adminhtml
#bin/magento setup:static-content:deploy fr_FR -f -s standard -a adminhtml
#bin/magento setup:static-content:deploy fr_FR -f -s standard  -t Creativestyle/theme-creativeshop

composer dump-autoload -o
