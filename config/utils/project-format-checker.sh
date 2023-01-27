#!/usr/bin/env bash

set -e

echo 'Checking project format...'
#create and move m2 files into the magento dir if not present
if [ ! -d magento ] && [ -d app/etc ]
then
  echo 'Magento project found. Reformatting...'
  mkdir magento
  cp -r ./* magento/
fi


#create and move pwa-studio files into the pwa-studio dir if not present
if [ ! -d pwa-studio ] && [ -f upward.yml ]
then
  echo 'PWA-studio project found. Reformatting...'
  mkdir pwa-studio
  cp -r ./* pwa-studio/
fi