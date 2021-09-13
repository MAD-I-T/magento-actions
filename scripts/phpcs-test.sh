#!/usr/bin/env bash

set -e

PROJECT_PATH="$(pwd)"

composer create-project magento/magento-coding-standard --stability=dev magento-coding-standard

cd $PROJECT_PATH/magento-coding-standard

vendor/bin/phpcs --standard=$INPUT_STANDARD --severity=${$INPUT_SEVERITY:-1} $PROJECT_PATH/magento/app/code/$INPUT_EXTENSION

