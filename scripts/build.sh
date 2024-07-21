#!/usr/bin/env bash

echo "building ....."


chown -R root:root .
PROJECT_PATH="$(pwd)"

echo "currently in $PROJECT_PATH"
[ $INPUT_PWA_STUDIO_ONLY = 1 ] && rm -rf  $PROJECT_PATH/magento
[ $INPUT_MAGENTO_ONLY = 1 ] && rm -rf  $PROJECT_PATH/pwa-studio


echo "currently in $PROJECT_PATH"


#launch pwa-strudio build if the directory exists
if [ -d "$PROJECT_PATH/pwa-studio" ]
then
  set -e

  curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.39.1/install.sh | bash
  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  nvm install $INPUT_NODE_VERSION
  npm install --location=global yarn
  npm install -g yarn
  yarn install && yarn add compression
  #yarn add  @magento/pwa-buildpack

  cd pwa-studio
  yarn install --update-checksums --frozen-lockfile
  yarn run build
  set +e
  ls -talh
fi
cd $PROJECT_PATH


if [ -d "$PROJECT_PATH/magento" ]
then
   cd "$PROJECT_PATH/magento"

   /usr/local/bin/composer install --dry-run --no-dev --no-progress &> /dev/null

   COMPOSER_COMPATIBILITY=$?

   echo "Composer compatibility: $COMPOSER_COMPATIBILITY"

   set -e

   if [ $COMPOSER_COMPATIBILITY = 0 ]
   then
	   /usr/local/bin/composer install --no-dev --no-progress
   else
      echo "using composer v1"
      php7.2 /usr/local/bin/composer self-update --1
      /usr/local/bin/composer install --no-dev --no-progress
   fi

    chmod +x bin/magento

    #mysqladmin -h mysql -u root -pmagento status
    ## fix magento error: connection default is not defined
    echo "<?php  return ['db' => [ 'table_prefix' => '', 'connection' => [ 'default' => [ 'host' => 'mysql', 'dbname' => 'magento', 'username' => 'root', 'password' => 'magento', 'model' => 'mysql4', 'engine' => 'innodb', 'initStatements' => 'SET NAMES utf8;', 'active' => '1' ] ]]];" > app/etc/env.php
    ## end fix ##

    if [ -n "$INPUT_DISABLE_MODULES"  ]
    then
      echo "These modules will be discarded during install process $INPUT_DISABLE_MODULES"
      [ -f app/etc/config.php ] && cp app/etc/config.php app/etc/config.php.orig
    fi

    bash /opt/config/utils/pagebuilder-compatibility-checker.sh
    bash /opt/config/utils/common-magento-installer.sh

    ## apply patches
    if [ $INPUT_APPLY_PATCHES = 1 ]
    then
      bash /opt/config/utils/apply-ece-patches.sh
    fi

    ## Build static contents
    bash /opt/config/utils/custom-theme-builder.sh

    if [ -z "$INPUT_LANGS"  ] && [ -z "$INPUT_THEMES"  ]
    then
      ## the switch to production will build static content for all languages declared in config.php
      bin/magento deploy:mode:set production
      composer dump-autoload -o
    else
      bin/magento setup:di:compile
      bin/magento deploy:mode:set --skip-compilation production
      # deploy static build for different locales
      export IFS=","
      magento_themes=${INPUT_THEMES:+${INPUT_THEMES//' '/,}",Magento/backend"}
      magento_themes_array=($magento_themes)
      languages="$INPUT_LANGS"
      if [ -n "$languages"  ]
      then
        for locale in $languages; do
          for theme in "${magento_themes_array[@]}" 
          do
            echo "bin/magento setup:static-content:deploy -t $theme $locale"
            bin/magento setup:static-content:deploy -t $theme $locale
	  done
        done
      else
          for theme in "${magento_themes_array[@]}" 
          do
            echo "bin/magento setup:static-content:deploy $theme"
            bin/magento setup:static-content:deploy $theme
	  done
      fi
      composer dump-autoload -o
    fi

    if [ -n "$INPUT_DISABLE_MODULES"  ]
    then
      [ -f app/etc/config.php.orig ] && cat app/etc/config.php.orig > app/etc/config.php
    fi

    rm app/etc/env.php
fi
