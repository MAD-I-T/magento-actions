#!/usr/bin/env bash

IS_NODE_SET=0

for file in app/design/frontend/*/*; do
  if [ -d "$file/web/tailwind" ]
  then
    if [ $IS_NODE_SET = 0 ]
    then
      curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.39.1/install.sh | bash
      export NVM_DIR="$HOME/.nvm"
      [ -s "$NVM_DIR/nvm.sh"  ] &&. "$NVM_DIR/nvm.sh"
      nvm install $INPUT_NODE_VERSION
      IS_NODE_SET=1
    fi
    mkdir -p "$file/web/css/"
    npm --prefix "$file/web/tailwind" ci
    npm --prefix "$file/web/tailwind" run build-prod
    # cleanup
    rm -rf "$file/web/tailwind/node_modules/"
  fi
done
rm -rf ~/.nvm/
