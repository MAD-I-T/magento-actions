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
  php7.2 /usr/local/bin/composer self-update --1
	/usr/local/bin/composer install --prefer-dist --no-progress
fi

chmod +x bin/magento

## fix magento error: connection default is not defined
echo "<?php  return ['db' => [ 'table_prefix' => '', 'connection' => [ 'default' => [ 'host' => 'mysql', 'dbname' => 'magento', 'username' => 'root', 'password' => 'magento', 'model' => 'mysql4', 'engine' => 'innodb', 'initStatements' => 'SET NAMES utf8;', 'active' => '1' ] ]]];" > app/etc/env.php
## end fix ##

if [ -n "$INPUT_DISABLE_MODULES"  ]
then
  echo "These modules will be discarded during install process $INPUT_DISABLE_MODULES"
  [ -f app/etc/config.php ] && cp app/etc/config.php app/etc/config.php.orig
fi


bash /opt/config/utils/pagebuilder-compatibility-checker.sh
bash /opt/config/utils/common-magento-installer.sh

bin/magento deploy:mode:set developer

./vendor/bin/phpunit -c dev/tests/static/phpunit.xml.dist


if [ -n "$INPUT_DISABLE_MODULES"  ]
then
  [ -f app/etc/config.php.orig ] && cat app/etc/config.php.orig > app/etc/config.php
fi
rm app/etc/env.php
