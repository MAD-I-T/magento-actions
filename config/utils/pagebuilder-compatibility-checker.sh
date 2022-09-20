#!/usr/bin/env bash

set -e

if [ ! -f app/etc/config.php ]
then
  echo "Generating config.php if does not exist | fix for magento/magento2-page-builder#730"
  bin/magento module:enable --all
fi
