
#!/usr/bin/env bash

PROJECT_PATH="$(pwd)"

echo "currently in $PROJECT_PATH"

cd "$PROJECT_PATH/magento"

/usr/local/bin/composer install --dry-run --prefer-dist --no-progress &> /dev/null

COMPOSER_COMPATIBILITY=$?

echo "Composer compatibility: $COMPOSER_COMPATIBILITY"


set -e

if [ $COMPOSER_COMPATIBILITY = 0 ]
then
	/usr/local/bin/composer install --prefer-dist --no-progress
else
  echo "using composer v1"
  /usr/local/bin/composer self-update --1
	/usr/local/bin/composer install --prefer-dist --no-progress
fi

chmod +x bin/magento


if [ $INPUT_ELASTICSUITE = 1 ]
then
  bin/magento setup:install --admin-firstname="local" --admin-lastname="local" --admin-email="local@local.com" --admin-user="local" --admin-password="local123" --base-url="http://magento.build/" --backend-frontname="admin" --db-host="mysql" --db-name="magento" --db-user="root" --db-password="magento" --use-secure=0 --use-rewrites=1 --use-secure-admin=0 --session-save="db" --currency="EUR" --language="en_US" --timezone="Europe/Rome" --cleanup-database --skip-db-validation --es-hosts="elasticsearch:9200" --es-user="" --es-pass=""
elif [ $INPUT_ELASTICSEARCH = 1 ]
then
  bin/magento setup:install --admin-firstname="local" --admin-lastname="local" --admin-email="local@local.com" --admin-user="local" --admin-password="local123" --base-url="http://magento.build/" --backend-frontname="admin" --db-host="mysql" --db-name="magento" --db-user="root" --db-password="magento" --use-secure=0 --use-rewrites=1 --use-secure-admin=0 --session-save="db" --currency="EUR" --language="en_US" --timezone="Europe/Rome" --cleanup-database --skip-db-validation --elasticsearch-host="elasticsearch" --elasticsearch-port=9200
else
  bin/magento setup:install --admin-firstname="local" --admin-lastname="local" --admin-email="local@local.com" --admin-user="local" --admin-password="local123" --base-url="http://magento.build/" --backend-frontname="admin" --db-host="mysql" --db-name="magento" --db-user="root" --db-password="magento" --use-secure=0 --use-rewrites=1 --use-secure-admin=0 --session-save="db" --currency="EUR" --language="en_US" --timezone="Europe/Rome" --cleanup-database --skip-db-validation
fi

bin/magento deploy:mode:set developer

./vendor/bin/phpunit -c dev/tests/unit/phpunit.xml.dist
