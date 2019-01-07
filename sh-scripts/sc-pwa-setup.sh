#!/bin/bash
if which node > /dev/null
  then
   echo "node is installed, continuing..."
   cd ~/
   echo "cloning pwa-studio..."
   git clone https://github.com/magento-research/pwa-studio.git
   cd pwa-studio/
   echo "installing pwa-studio..."
   npm install
   cp packages/venia-concept/.env.dist packages/venia-concept/.env
   echo "configuring storefront url from cloud..."
   sed -i '' 's,https://release-dev-rxvv2iq-zddsyhrdimyra.us-4.magentosite.cloud/,https://pwa-n3sumvi-xy4itwbmg2khk.demo.magentosite.cloud/,g' packages/venia-concept/.env
   echo "building the stuidio..."
   npm run build
   echo "starting the studio..."
   npm run watch:venia
  else
   echo "visit https://nodejs.org/en/download/ to install to continue"
fi
