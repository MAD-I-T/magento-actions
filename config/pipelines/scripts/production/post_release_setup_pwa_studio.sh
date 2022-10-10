#!/usr/bin/env bash

echo "post release script pwa studio start"

isNpmPackageInstalled() {
  sudo npm list --depth 1 -g $1 > /dev/null 2>&1
}

# checks if pm2 is installed
if isNpmPackageInstalled "pm2"
then
  echo "pm2 is already installed"
else
  echo "pm2 is NOT installed please install it on the server and redeploy"
  echo "use sudo yarn global add  pm2 \n or \n sudo npm install -g pm2"
  #sudo yarn global add  pm2
  #npm install pm2
fi

# get into the dist dir to start prod server
cd dist

echo "Start the node server monnitored by PM2"

pm2 stop pwa_studio
pm2 delete pwa_studio
pm2 start yarn --interpreter bash --name pwa_studio -- start
