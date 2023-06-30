#!/bin/bash

if [ -n "$GITLAB_USER_NAME" ]
then
  which ssh-agent || ( apt-get update -y && apt-get install openssh-client -y )
  eval $(ssh-agent -s)
  mkdir -p ~/.ssh
  echo "$SSH_PRIVATE_KEY" > ~/.ssh/id_rsa
  chmod 0600 ~/.ssh/id_rsa
  echo "StrictHostKeyChecking no " > /root/.ssh/config
fi

PROJECT_PATH="$(pwd)"

echo "currently in $PROJECT_PATH"

if [ $INPUT_NO_PUSH = 1 ]
then
  rm -rf ./pwa-studio
fi

if [ -d "$PROJECT_PATH/pwa-studio" ]
then
  echo "An PWA studio project already exists."
  echo "Please consider deleting the pwa-studio directory first."
  exit 1
fi

chown -R root:root .

curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.39.1/install.sh | bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
nvm install 16
npm install --location=global yarn
yarn install && yarn add compression

yarn add @magento/pwa-buildpack
yarn add @magento/pwa

npx -y ${INPUT_VERSION:+'--force'} @magento/pwa-buildpack create-project ./pwa-studio --name @madit/pwa-studio --template @magento/venia-concept${INPUT_VERSION:+"@"}$INPUT_VERSION --backend-url https://master-7rqtwti-mfwmkrjfqvbjk.us-4.magentosite.cloud --backend-edition MOS --braintree-token sandbox_8yrzsvtm_s2bg8fs563crhqzk --author Madit

set -x
ls -ltah

if [ "$INPUT_NO_PUSH" -ne 1 ]
then
  if [ -n "$GITLAB_USER_NAME" ]
  then
    git config --global user.email "${GIT_USER_EMAIL:-$GITLAB_USER_EMAIL}"
    git config --global user.name "${GIT_USER_NAME:-$GITLAB_USER_NAME}"
    git remote rm origin && git remote add origin "git@$GITLAB_URL:${CI_PROJECT_PATH}.git"

  else
    git config user.name github-actions
    git config user.email github-actions@github.com
  fi
  git add ./pwa-studio/.gitignore
  git commit -m 'added pwa-studio gitignore'
  git add ./pwa-studio
  git add -f ./pwa-studio/.env
  git commit -m "add pwa-studio project to github repo"
  if [ -n "$GITLAB_USER_NAME" ]
  then
    git remote rm origin && git remote add origin git@gitlab.com:$CI_PROJECT_PATH.git
    git push origin HEAD:$CI_COMMIT_REF_NAME -o ci.skip
  else
    git push
  fi
fi
