#!/usr/bin/env bash

# check and edit this path (public path of magento)

if [ ! -f app/etc/env.php ]
then
  echo "This is the first deploy? You must set magento env.php"
  exit 3
fi

echo "Import magento config"
php bin/magento app:config:import --no-interaction

echo "Check setup:upgrade status"
# use --no-ansi to avoid color characters
message=$(php bin/magento setup:db:status --no-ansi)

#kill current consumers
pgrep -u "$(whoami)" -f "[q]ueue:consumers:start" | tee /dev/stderr | awk '{print $1}' | xargs -r kill

if [[ ${message:0:3} == "All" ]]; then
  echo "No setup upgrade - clear cache";
  php bin/magento cache:clean
  php bin/magento queue:consumers:restart
else
  echo "Run setup:upgrade - maintenance mode"
  php bin/magento maintenance:enable
  php bin/magento setup:upgrade --keep-generated
  php bin/magento maintenance:disable
  php bin/magento cache:flush
fi
