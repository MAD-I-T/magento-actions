#!/usr/bin/env bash


set -e
PROJECT_PATH="$(pwd)"


echo "currently in $PROJECT_PATH"

cp -r magento magento-phpstan

cd "$PROJECT_PATH/magento-phpstan"


/usr/local/bin/composer install --dry-run --prefer-dist --no-progress &> /dev/null

COMPOSER_COMPATIBILITY=$?

echo "Composer compatibility: $COMPOSER_COMPATIBILITY"


if [ $COMPOSER_COMPATIBILITY = 0 ]
then
	/usr/local/bin/composer install --prefer-dist --no-progress
else
  echo "using composer v1"
  php7.2 /usr/local/bin/composer self-update --1
	/usr/local/bin/composer install --prefer-dist --no-progress
fi

composer require --dev phpstan/phpstan
composer require --dev bitexpert/phpstan-magento
composer config allow-plugins.phpstan/extension-installer true
composer require --dev phpstan/extension-installer



NEONCONFIG=(`find $PROJECT_PATH -maxdepth 1 -name "*.neon"`)
NEONEXTENSIONCONFIG=(`find $INPUT_EXEC_PATH -maxdepth 1 -name "*.neon"`)
[ ${#NEONCONFIG[@]} -gt 0 ] && cp $PROJECT_PATH/*.neon .
[ ${#NEONEXTENSIONCONFIG[@]} -gt 0 ] && cp $INPUT_EXEC_PATH/*.neon .


vendor/bin/phpstan analyse $INPUT_EXEC_PATH

rm -r magento-phpstan



