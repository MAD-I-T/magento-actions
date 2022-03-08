#!/usr/bin/env bash

set -e

PROJECT_PATH="$(pwd)"

echo "currently in $PROJECT_PATH"

majorVersion=${INPUT_MAGENTO_VERSION:2:1}
minorVersion=${INPUT_MAGENTO_VERSION:4:1}

/usr/local/bin/composer self-update --1

if [ -n "$INPUT_MAGENTO_VERSION" ]
then
  case "$majorVersion" in
    3)case "$minorVersion" in
        4|5|6|7|8)
           /usr/local/bin/composer self-update --1
           update-alternatives --set php /usr/bin/php7.3
           composer create-project --repository-url=https://repo.magento.com/ magento/project-community-edition=${INPUT_MAGENTO_VERSION}
           ;;
        0|1|2|3)
           update-alternatives --set php /usr/bin/php7.1
           composer create-project --repository-url=https://repo.magento.com/ magento/project-community-edition=${INPUT_MAGENTO_VERSION}
           ;;
        *) echo "This version $INPUT_MAGENTO_VERSION of magento 2.4.X is not recognized minor $minorVersion" && exit 1 ;;
      esac ;;
    4)
      case "$minorVersion" in
        4|5)
           /usr/local/bin/composer self-update --2
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

if [ "$INPUT_NO_PUSH" -ne 1 ]
then
  mv ./project-community-edition ./magento
  ls -lath ./magento
  git config user.name github-actions
  git config user.email github-actions@github.com
  [ -f magento/.gitignore ] && echo "gitignore exists." || cp /opt/config/templates/gitignore.tpl magento/.gitignore
  git add magento/.gitignore
  git commit -m 'added gitignore'
  git add magento
  git commit -m "add magento project to github repo"
  git push
fi