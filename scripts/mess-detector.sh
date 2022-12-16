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


if [ ! -f $INPUT_RULESET ]
then
  echo -e "\e[32mThe ruleset file [$INPUT_RULESET] NOT FOUND\e[0m"
  echo "Using default magento ruleset dev/tests/static/testsuite/Magento/Test/Php/_files/phpmd/ruleset.xml"
  cp /opt/config/defaults/ruleset.xml .
  INPUT_RULESET=ruleset.xml
fi


if [ -n $INPUT_MD_SRC_PATH ]
then
  echo -e "\e[32mMess detection initiated\e[0m"
  php vendor/phpmd/phpmd/src/bin/phpmd $INPUT_MD_SRC_PATH ansi $INPUT_RULESET
else
  echo -e "\e[31mPlease specify the $md_src_path\e[0m"
  exit 1;
fi
