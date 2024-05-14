#!/bin/sh -l

echo "hello your setup is $INPUT_PHP & $INPUT_PROCESS & $INPUT_OVERRIDE_SETTINGS"

if [ $INPUT_OVERRIDE_SETTINGS = 1 ]
then
  [ -d config ] && ls ./config/*
  [ -d scripts ] && ls ./scripts/*
  [ -d config ] && cp -rf ./config/* /opt/config/
  [ -d scripts ] && cp -rf ./scripts/* /opt/scripts/
fi

bash /opt/config/utils/project-format-checker.sh

if [ $INPUT_PHP = 'auto' ]
then
  bash /opt/config/utils/php-compatibility-checker.sh
else
  echo "Forcing php to match specified input argument"
  update-alternatives --set php /usr/bin/php${INPUT_PHP}
fi

echo "Input search engine specifications"
echo "Elasticsearch: $INPUT_ELASTICSEARCH"
echo "Opensearch: $INPUT_OPENSEARCH"
bash /opt/config/utils/search-engine-compatibility-checker.sh


if [ "$INPUT_COMPOSER_VERSION" -ne 0 ]
then
  echo "Forcing composer to match specified input argument"
  php7.2 /usr/local/bin/composer self-update --${INPUT_COMPOSER_VERSION}
fi

# for compatibility with older versions
cp /opt/scripts/deploy-production.sh /opt/scripts/deploy-prod.sh
cp /opt/scripts/cleanup-prod.sh /opt/scripts/cleanup-production.sh


bash /opt/scripts/${INPUT_PROCESS}.sh
