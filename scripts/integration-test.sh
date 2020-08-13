#!/usr/bin/env bash

set -e

PROJECT_PATH="$(pwd)"

cd $PROJECT_PATH/magento

/usr/local/bin/composer install --prefer-dist --no-progress
chmod +x bin/magento


#if [ $INPUT_ELASTICSUITE = 1 ]
#then
#  bin/magento setup:install --admin-firstname="local" --admin-lastname="local" --admin-email="local@local.com" --admin-user="local" --admin-password="local123" --base-url="http://magento.build/" --backend-frontname="admin" --db-host="mysql" --db-name="magento" --db-user="root" --db-password="magento" --use-secure=0 --use-rewrites=1 --use-secure-admin=0 --session-save="db" --currency="EUR" --language="en_US" --timezone="Europe/Rome" --cleanup-database --skip-db-validation --es-hosts="elasticsearch:9200" --es-user="" --es-pass=""
#else
#  bin/magento setup:install --admin-firstname="local" --admin-lastname="local" --admin-email="local@local.com" --admin-user="local" --admin-password="local123" --base-url="http://magento.build/" --backend-frontname="admin" --db-host="mysql" --db-name="magento" --db-user="root" --db-password="magento" --use-secure=0 --use-rewrites=1 --use-secure-admin=0 --session-save="db" --currency="EUR" --language="en_US" --timezone="Europe/Rome" --cleanup-database --skip-db-validation
#fi
#
#bin/magento deploy:mode:set developer


#apt-get update && apt-get install -y mysql-server

if [ $INPUT_ELASTICSUITE = 1 ]
then
  yes | cp -rf /opt/config/integration-test-config-esuite.php dev/tests/integration/etc/install-config-mysql.php
elif [ $INPUT_ELASTICSEARCH = 1 ]
then
  yes | cp -rf /opt/config/integration-test-config-es.php dev/tests/integration/etc/install-config-mysql.php
else
  yes | cp -rf /opt/config/integration-test-config.php dev/tests/integration/etc/install-config-mysql.php
fi

cd dev/tests/integration && ../../../vendor/bin/phpunit -c phpunit.xml.dist
