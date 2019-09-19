#!/bin/sh -l

echo "hello your setup is $INPUT_PHP & $INPUT_PROCESS"

update-alternatives --set php /usr/bin/php${INPUT_PHP}
bash /opt/scripts/${INPUT_PROCESS}.sh
