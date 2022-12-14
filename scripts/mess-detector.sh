#!/usr/bin/env bash

set -e

PROJECT_PATH="$(pwd)"

wget -c https://phpmd.org/static/latest/phpmd.phar


if [ ! -f $INPUT_RULESET ]
then
  echo -e "\e[32mThe ruleset file [$INPUT_RULESET] NOT FOUND\e[0m"
  echo "Using default magento ruleset dev/tests/static/testsuite/Magento/Test/Php/_files/phpmd/ruleset.xml"
  cp /opt/config/defaults/ruleset.xml .
fi

if [ -n $INPUT_MD_SRC_PATH ]
then
  	echo -e "\e[32mMess detection initiated\e[0m"
    php phpmd.phar $INPUT_MD_SRC_PATH text $INPUT_RULESET
else
  echo -e "\e[31mPlease specify the $md_src_path\e[0m"
  exit 1;
fi


