#!/bin/bash

#keeping this for backward incommpatibity issues shoud be discarded starting 3.9, use deploy-production instead
set -e


PROJECT_PATH="$(pwd)"


echo "project path is $PROJECT_PATH";

which ssh-agent || ( apt-get update -y && apt-get install openssh-client -y )
eval $(ssh-agent -s)
mkdir ~/.ssh/ && echo "$SSH_PRIVATE_KEY" > ~/.ssh/id_rsa && chmod 600 ~/.ssh/id_rsa
ssh-add ~/.ssh/id_rsa
echo "$SSH_CONFIG" > /etc/ssh/ssh_config && chmod 600 /etc/ssh/ssh_config



echo "Create artifact and send to server"

cd $PROJECT_PATH


echo "Deploying to production server";

mkdir -p deployer/scripts/
cp -R /opt/config/pipelines/scripts/production deployer/scripts/production

echo 'creating bucket dir'
ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null  production "mkdir -p $HOST_DEPLOY_PATH_BUCKET"



tar cfz "$BUCKET_COMMIT" deployer/scripts/production magento
scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null  "$BUCKET_COMMIT" production:$HOST_DEPLOY_PATH_BUCKET


cd /opt/config/php-deployer

echo 'Deploying production ...';


#create dirs if not exists first deploy



echo '------> Deploying bucket ...';
# deploy bucket
php7.4 ./vendor/bin/dep deploy-bucket production \
-o bucket-commit=$BUCKET_COMMIT \
-o host_bucket_path=$HOST_DEPLOY_PATH_BUCKET \
-o deploy_path_custom=$HOST_DEPLOY_PATH \
-o write_use_sudo=$WRITE_USE_SUDO

# setup magento
ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null  production "cd $HOST_DEPLOY_PATH/release/magento/ && /bin/bash $HOST_DEPLOY_PATH/deployer/scripts/production/release_setup.sh"


echo '------> Deploying release ...';

DEFAULT_DEPLOYER="deploy"
if [ $INPUT_DEPLOYER = "no-permission-check" ]
then
  DEFAULT_DEPLOYER="deploy:no-permission-check"
fi

# deploy release
php7.4 ./vendor/bin/dep $DEFAULT_DEPLOYER production \
-o bucket-commit=$BUCKET_COMMIT \
-o host_bucket_path=$HOST_DEPLOY_PATH_BUCKET \
-o deploy_path_custom=$HOST_DEPLOY_PATH \
-o write_use_sudo=$WRITE_USE_SUDO

ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null  production "cd $HOST_DEPLOY_PATH/current/magento/ && /bin/bash $HOST_DEPLOY_PATH/deployer/scripts/production/post_release_setup.sh"
