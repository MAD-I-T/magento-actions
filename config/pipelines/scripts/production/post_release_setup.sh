#!/usr/bin/env bash

# check and edit this path (public path of magento)

if [ ! -f app/etc/env.php ]
then
  echo "This is the first deploy? You must set magento env.php"
  exit 3
fi

echo "Import magento config"
php bin/magento app:config:import --no-interaction

#kill current consumers
echo "killing consumers linked to this backend - path is : "
pwd -P
CUR_PATH="$(pwd -P)/bin/magento"
PREVIOUS=$(cat "$(pwd -P)/../../../.dep/latest_release")

if [[ $CUR_PATH =~ (releases/)([0-9]+)(/magento) ]]; then
    prefix=${BASH_REMATCH[1]}       # 'start_'
    num=${BASH_REMATCH[2]}          # '42'
    suffix=${BASH_REMATCH[3]}       # '_end'
    ((num--))
    # rebuild the string
    CUR_PATH="${CUR_PATH/${BASH_REMATCH[0]}/${prefix}.*?${suffix}}"
    echo "Current release is : $PREVIOUS"
    echo "Previous release is : ${num}"
fi

echo "Clearing all consumers associated with this backend : "
#echo "$CUR_PATH"
pgrep -u "$(whoami)" -af "$CUR_PATH [q]ueue:consumers:start" | tee /dev/stderr | awk '{print $1}' | xargs -r kill

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