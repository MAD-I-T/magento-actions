#!/bin/bash

curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.39.1/install.sh | bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
nvm install 16
npm install --location=global yarn
yarn install && yarn add compression


set -x
yarn add @magento/pwa-buildpack
yarn add @magento/pwa

yarn cache clear
yarn buildpack  create-project   ./pwa-studio --name @madit/pwa-studio --template @magento/venia-concept --backend-url https://master-7rqtwti-mfwmkrjfqvbjk.us-4.magentosite.cloud --backend-edition MOS --braintree-token sandbox_8yrzsvtm_s2bg8fs563crhqzk --author Madit


set -x


ls -ltah
pwd

if [ "$INPUT_NO_PUSH" -ne 1 ]
then
  git config user.name github-actions
  git config user.email github-actions@github.com
  git add ./pwa-studio/.gitignore
  git commit -m 'added pwa-studio gitignore'
  git add ./pwa-studio
  git commit -m "add pwa-studio project to github repo"
  git push
fi
