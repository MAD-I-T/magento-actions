#!/usr/bin/env bash


MAGE_VERSION_OS=$(grep -ni '"magento/product-community-edition"' magento/composer.json | cut -d ':' -f 3 | cut -d '"' -f 2;);
MAGE_VERSION=$(grep -ni '"version"' magento/composer.json | cut -d ':' -f 3 | cut -d '"' -f 2;);


if [ "$MAGE_VERSION" != "$MAGE_VERSION_OS" ]
then
   [ -n "$MAGE_VERSION_OS" ] && MAGE_VERSION="$MAGE_VERSION_OS"
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
         update-alternatives --set php /usr/bin/php7.1
         ;;
    3)case "$minorVersion" in
        4|5|6|7|8)
           echo "switching to php7.3 to match magento version";
           update-alternatives --set php /usr/bin/php7.3
           ;;
        0|1|2|3)
           echo "switching to php7.1 to match magento version";
           update-alternatives --set php /usr/bin/php7.1
           ;;
        *) echo "This version $INPUT_MAGENTO_VERSION of magento 2.4.X is not recognized minor $minorVersion" ;;
      esac ;;
    4)
      case "$minorVersion" in
          8)
           echo "switching to php8.3 to match magento version ";
           update-alternatives --set php /usr/bin/php8.3;
           ;;
        6|7)
           echo "switching to php8.2 to match magento version ";
           update-alternatives --set php /usr/bin/php8.2;
           ;;
        4|5)
           echo "switching to php8.1 to match magento version";
           update-alternatives --set php /usr/bin/php8.1;
           ;;
        0|1|2|3)
           echo "switching to php7.4 to match magento version";
           update-alternatives --set php /usr/bin/php7.4;
           ;;
        *) echo "This version $MAGE_VERSION of magento 2.4.X is not recognized minor $minorVersion";;
      esac ;;
    *) echo "This version $MAGE_VERSION of magento is not recognized minor $minorVersion"  ;;
   esac
else
  echo "No match found"
fi
