#!/bin/sh -l

echo "hello your setup is $INPUT_PHP & $INPUT_PROCESS"

update-alternatives --set php /usr/bin/php${INPUT_PHP}

if [ $INPUT_OVERRIDE_SETTINGS = 1 ]
then
  cp -R ./config/* /opt/config/
  cp -R ./scripts/* /opt/scripts/
  bash /opt/scripts/${INPUT_PROCESS}.sh
else
  bash /opt/scripts/${INPUT_PROCESS}.sh
fi