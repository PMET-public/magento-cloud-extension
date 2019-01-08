#!/bin/bash

# 1st install & run
# possibly update & run

LOCAL=$(git rev-parse @)
REMOTE=$(git rev-parse @{u})
BASE=$(git merge-base @ @{u})

if which node > /dev/null; then
  echo "[*] node is installed, continuing..."
  if [ -d "$HOME/pwa-studio/node_modules" ]; then
    echo "[*] pwa-studio previously setup, continuing..."
    cd $HOME/pwa-studio/
    if [ $LOCAL = $REMOTE ]; then
      echo "[*] pwa-studio up-to-date, starting..."
      npm run watch:venia
    elif [ $LOCAL = $BASE ]; then
      echo "[*] pwa-studio update available, updating..."
      echo "[*] pulling update..."
      git pull
      echo "[*] re-installing..."
      npm install
      echo "[*] re-building..."
      npm run build
      echo "[*] starting..."
      npm run watch:venia
    else
      echo "[*] Diverged"
      exit 1
    fi
  else
    echo "[*] setting up pwa-studio for the first time..."
    cd $HOME
    echo "[*] cloning pwa-studio..."
    git clone https://github.com/magento-research/pwa-studio.git
    cd pwa-studio/
    echo "[*] installing pwa-studio..."
    npm install
    cp packages/venia-concept/.env.dist packages/venia-concept/.env
    echo "[*] configuring storefront url from cloud..."
    sed -i '' 's,https://release-dev-rxvv2iq-zddsyhrdimyra.us-4.magentosite.cloud/,https://pwa-n3sumvi-xy4itwbmg2khk.demo.magentosite.cloud/,g' packages/venia-concept/.env
    echo "building the studio..."
    npm run build
    echo "starting the studio..."
    npm run watch:venia
  fi
  else
   echo "[*] visit https://nodejs.org/en/download/ to install to continue"
fi
