#!/usr/bin/env bash

if [ -n "$GITLAB_USER_NAME" ]
then
  which ssh-agent || ( apt-get update -y && apt-get install openssh-client -y )
  eval $(ssh-agent -s)
  mkdir -p ~/.ssh
  echo "$SSH_PRIVATE_KEY" > ~/.ssh/id_rsa
  chmod 0600 ~/.ssh/id_rsa
  echo "StrictHostKeyChecking no " > /root/.ssh/config
fi

set -e

PROJECT_PATH="$(pwd)"

echo "currently in $PROJECT_PATH"
git config --global --add safe.directory $(realpath .)


if [ $INPUT_NO_PUSH = 1 ]
then
  rm -rf ./magento
fi

majorVersion=${INPUT_MAGENTO_VERSION:2:1}
minorVersion=${INPUT_MAGENTO_VERSION:4:1}

php7.2 /usr/local/bin/composer self-update --1

if [ -n "$INPUT_MAGENTO_VERSION" ]
then
  case "$majorVersion" in
    2)
         php7.2 /usr/local/bin/composer self-update --1
         update-alternatives --set php /usr/bin/php7.1
         composer create-project --repository-url=https://repo.magento.com/ magento/project-community-edition=${INPUT_MAGENTO_VERSION}
         ;;
    3)case "$minorVersion" in
        4|5|6|7|8)
           php7.2 /usr/local/bin/composer self-update --1
           update-alternatives --set php /usr/bin/php7.3
           composer create-project --repository-url=https://repo.magento.com/ magento/project-community-edition=${INPUT_MAGENTO_VERSION}
           ;;
        0|1|2|3)
           update-alternatives --set php /usr/bin/php7.1
           composer create-project --repository-url=https://repo.magento.com/ magento/project-community-edition=${INPUT_MAGENTO_VERSION}
           ;;
        *) echo "This version $INPUT_MAGENTO_VERSION of magento 2.4.X is not recognized minor $minorVersion" && exit 1 ;;
      esac ;;
    4)case "$minorVersion" in
        6)
           php7.2 /usr/local/bin/composer self-update --2
           update-alternatives --set php /usr/bin/php8.2
           composer create-project --repository-url=https://repo.magento.com/ magento/project-community-edition=${INPUT_MAGENTO_VERSION}
           ;;
        4|5)
           php7.2 /usr/local/bin/composer self-update --2
           update-alternatives --set php /usr/bin/php8.1
           composer create-project --repository-url=https://repo.magento.com/ magento/project-community-edition=${INPUT_MAGENTO_VERSION}
           ;;
        0|1|2|3)
           update-alternatives --set php /usr/bin/php7.4
           composer create-project --repository-url=https://repo.magento.com/ magento/project-community-edition=${INPUT_MAGENTO_VERSION}
           ;;
        *) echo "This version $INPUT_MAGENTO_VERSION of magento 2.4.X is not recognized minor $minorVersion" && exit 1 ;;
      esac ;;
    *) echo "This version $INPUT_MAGENTO_VERSION of magento is not recognized minor $minorVersion" && exit 1 ;;
   esac
else
  echo "You must specify a magento version"
  exit 1;
fi

ls -lath

mv ./project-community-edition ./magento
ls -lath ./magento


if [ "$INPUT_ENABLE" =  "pwa" ]
then
  cd magento
  composer require magento/pwa
  cd ..
fi


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

  [ -f magento/.gitignore ] && echo "gitignore exists." || cp /opt/config/templates/gitignore.tpl magento/.gitignore
  git add magento/.gitignore
  git commit -m 'added gitignore'
  git add magento
  git commit -m "add magento project to github repo"
  if [ -n "$GITLAB_USER_NAME" ]
  then
    git remote rm origin && git remote add origin git@gitlab.com:$CI_PROJECT_PATH.git
    git push origin HEAD:$CI_COMMIT_REF_NAME -o ci.skip
  else
    git push
  fi
fi
