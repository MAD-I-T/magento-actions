#!/bin/bash

set -e

PROJECT_PATH="$(pwd)"

echo "project path is $PROJECT_PATH";

[ $INPUT_PWA_STUDIO_ONLY = 1 ] && rm -rf  $PROJECT_PATH/magento
[ $INPUT_MAGENTO_ONLY = 1 ] && rm -rf  $PROJECT_PATH/pwa-studio*

which ssh-agent || ( apt-get update -y && apt-get install openssh-client -y )
eval $(ssh-agent -s)
mkdir ~/.ssh/ && echo "$SSH_PRIVATE_KEY" > ~/.ssh/id_rsa && chmod 600 ~/.ssh/id_rsa
ssh-add ~/.ssh/id_rsa
echo "$SSH_CONFIG" > /etc/ssh/ssh_config && chmod 600 /etc/ssh/ssh_config

echo "Create artifact and send to server"

cd $PROJECT_PATH


echo "Deploying to staging server";

mkdir -p deployer/scripts/
cp -R /opt/config/pipelines/scripts/staging deployer/scripts/staging

echo 'creating bucket dir'
ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null  staging "mkdir -p $HOST_DEPLOY_PATH_BUCKET"

ARCHIVES="deployer/scripts/staging"

for dir in *pwa-studio*
do
  echo "archiving $dir ..."
  ARCHIVES="$ARCHIVES $dir"

done

[ -d "magento" ] && ARCHIVES="$ARCHIVES magento"


tar cfz "$BUCKET_COMMIT" $ARCHIVES
scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null  "$BUCKET_COMMIT" staging:$HOST_DEPLOY_PATH_BUCKET


cd /opt/config/php-deployer

echo 'Deploying staging ...';

echo '------> Deploying bucket ...';
# deploy bucket
php7.4 ./vendor/bin/dep deploy-bucket staging \
-o bucket-commit=$BUCKET_COMMIT \
-o host_bucket_path=$HOST_DEPLOY_PATH_BUCKET \
-o deploy_path_custom=$HOST_DEPLOY_PATH \
-o deploy_keep_releases=$INPUT_KEEP_RELEASES \
-o write_use_sudo=$WRITE_USE_SUDO

# Run pre-release script in order to setup the server before magento deploy
if [ -d "$PROJECT_PATH/magento" ]
then
  ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null  staging "cd $HOST_DEPLOY_PATH/release/magento/ && /bin/bash $HOST_DEPLOY_PATH/deployer/scripts/staging/release_setup.sh"
fi

echo '------> Deploying release ...';

DEFAULT_DEPLOYER="deploy"
if [ $INPUT_DEPLOYER = "no-permission-check" ]
then
  DEFAULT_DEPLOYER="deploy:no-permission-check"
  if [ ! -d "$PROJECT_PATH/magento" ]
    then
      DEFAULT_DEPLOYER="deploy:no-permission-check:pwa-only"
  fi
fi

# deploy release
php7.4 ./vendor/bin/dep $DEFAULT_DEPLOYER staging \
-o bucket-commit=$BUCKET_COMMIT \
-o host_bucket_path=$HOST_DEPLOY_PATH_BUCKET \
-o deploy_path_custom=$HOST_DEPLOY_PATH \
-o deploy_keep_releases=$INPUT_KEEP_RELEASES \
-o write_use_sudo=$WRITE_USE_SUDO

echo "running magento and/or pwa deployer"
if [ -d "$PROJECT_PATH/magento" ]
then
  ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null  staging "cd $HOST_DEPLOY_PATH/current/magento/ && /bin/bash $HOST_DEPLOY_PATH/deployer/scripts/staging/post_release_setup.sh"
fi

# Run pwa-studio post release script if the directory exists
if [ -d "$PROJECT_PATH/pwa-studio" ]
then
 ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null  staging "cd $HOST_DEPLOY_PATH/current/pwa-studio/ && /bin/bash $HOST_DEPLOY_PATH/deployer/scripts/staging/post_release_setup_pwa_studio.sh"
fi

ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null  staging "cd $HOST_DEPLOY_PATH_BUCKET && /bin/bash $HOST_DEPLOY_PATH/deployer/scripts/staging/post_release_cleanup.sh $INPUT_KEEP_RELEASES"