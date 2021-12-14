#!/bin/sh -l

echo "hello your setup is $INPUT_PHP & $INPUT_PROCESS & $INPUT_OVERRIDE_SETTINGS"


update-alternatives --set php /usr/bin/php${INPUT_PHP}

if [ $INPUT_OVERRIDE_SETTINGS = 1 ]
then
  [[ -d config ]] && ls ./config/*
  [[ -d scripts ]] && ls ./scripts/*
  [[ -d config ]] && cp -rf ./config/* /opt/config/
  [[ -d scripts ]] && cp -rf ./scripts/* /opt/scripts/
  bash /opt/scripts/${INPUT_PROCESS}.sh
else
  bash /opt/scripts/${INPUT_PROCESS}.sh
fi