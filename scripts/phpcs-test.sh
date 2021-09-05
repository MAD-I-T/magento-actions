#!/usr/bin/env bash

set -e

PROJECT_PATH="$(pwd)"


if [ -d "$PROJECT_PATH/magento-coding-standard" ]
then
	echo "Directory $PROJECT_PATH/magento-coding-standard already exists."
else
	composer create-project magento/magento-coding-standard --stability=dev magento-coding-standard
fi


cd $PROJECT_PATH/magento-coding-standard


if [ -d "$PROJECT_PATH/magento/app/code/$INPUT_EXTENSION" ]
then
	echo "Extension $PROJECT_PATH/magento/app/code/$INPUT_EXTENSION exists."
        vendor/bin/phpcs --standard=$INPUT_STANDARD $PROJECT_PATH/magento/app/code/$INPUT_EXTENSION
elif [ -d "$PROJECT_PATH/$INPUT_EXTENSION" ]
then
	echo "Directory $PROJECT_PATH / $INPUT_EXTENSION exists."
        vendor/bin/phpcs --standard=$INPUT_STANDARD $PROJECT_PATH/$INPUT_EXTENSION
else
	echo "Error: Directory $PROJECT_PATH/magento/app/code/$INPUT_EXTENSION  does not exists."
	echo "Nor does the Directory $PROJECT_PATH/$INPUT_EXTENSION ."
fi

