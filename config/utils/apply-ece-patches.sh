#!/usr/bin/env bash

set -e

IS_QUALITY_PATCHER=$(grep -i 'magento/quality-patches' composer.json | cut -d  ":" -f 1  | cut -d '"' -f 2;)

if [ "$IS_QUALITY_PATCHER" != "magento/quality-patches" ]
then
  composer require magento/quality-patches
  php vendor/bin/ece-patches apply
  composer remove magento/quality-patches
else
  php vendor/bin/ece-patches apply
fi

