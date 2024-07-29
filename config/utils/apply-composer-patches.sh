#!/usr/bin/env bash

echo "applying patches"

set -e
if [ -s .magento.env.yaml ]
then
  echo "applying with magento quality patches"
  IS_QUALITY_PATCHER=$(grep -i 'magento/quality-patches' composer.json | cut -d  ":" -f 1  | cut -d '"' -f 2;)

  if [ "$IS_QUALITY_PATCHER" != "magento/quality-patches" ]
  then
    composer require magento/quality-patches
    php vendor/bin/ece-patches apply
    composer remove magento/quality-patches
  else
    php vendor/bin/ece-patches apply
  fi
else
  echo "applying patches in m2-hotfixes"
  echo "provided there are no conflicts"
  find m2-hotfixes/ -type f -name '*.patch' -print0 | sort -z | xargs -t -0 -n 1 patch -p1 -i
fi
echo "end of applying patch"
