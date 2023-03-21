#!/usr/bin/env bash


MAGE_VERSION=$(grep -ni '"version"' magento/composer.json | grep -o -E '\:\ .+' | cut -d' ' -f6 | cut -d',' -f1 | cut -d'"' -f2;);


if [ -z "$MAGE_VERSION" ]
then
  MAGE_VERSION=$(grep -ni '"version"' ./magento/composer.json | grep -o -E '\:\ .+' | cut -d ' ' -f4 | cut -d',' -f1 | cut -d'"' -f2;);
fi

set -e
echo "Current magento version is $MAGE_VERSION"
pwd
ls -lath magento/composer.json


majorVersion=${MAGE_VERSION:2:1}
minorVersion=${MAGE_VERSION:4:1}

if [ -n "$MAGE_VERSION" ]
then
  case "$majorVersion" in
    2)
         echo "No search engine needed";
         ;;
    3)case "$minorVersion" in
        5|6|7|8)
           echo "No search engine selected for it manually if needed";
           #[ -z "$INPUT_OPENSEARCH"  -a  -z  "$INPUT_ELASTICSEARCH" ] && echo $'INPUT_ELASTICSEARCH=1 \nINPUT_OPENSEARCH=0' >> /etc/environment;
           ;;
        0|1|2|3|4)
           echo "No search engine selected for it manually if needed";
           ;;
        *) echo "This version $INPUT_MAGENTO_VERSION of magento 2.4.X is not recognized minor $minorVersion" ;;
      esac ;;
    4)
      case "$minorVersion" in
        6)
           echo "switching search engine to opensearch";
           echo $'INPUT_ELASTICSEARCH=0 \nINPUT_OPENSEARCH=1' >> /etc/environment;
           ;;
        4|5)
           echo "switching search engine to elasticsearch if needed";
           [ -z "$INPUT_OPENSEARCH"  -a  -z  "$INPUT_ELASTICSEARCH" ] && echo $'INPUT_ELASTICSEARCH=1 \nINPUT_OPENSEARCH=0' >> /etc/environment;
           ;;
        0|1|2|3)
           echo "switching search engine to elasticsearch if needed";
           [ -z "$INPUT_OPENSEARCH"  -a  -z  "$INPUT_ELASTICSEARCH" ] && echo $'INPUT_ELASTICSEARCH=1 \nINPUT_OPENSEARCH=0' >> /etc/environment;
           ;;
        *) echo "This version $MAGE_VERSION of magento 2.4.X is not recognized minor $minorVersion";;
      esac ;;
    *) echo "This version $MAGE_VERSION of magento is not recognized minor $minorVersion"  ;;
   esac
else
  echo "No match found"
fi
