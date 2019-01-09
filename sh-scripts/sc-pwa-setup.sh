printf "\nSetting up PWA Studio ...\n"

NODE_VERSION="v10.15.0"
GIT_PWA_URL="https://release-dev-rxvv2iq-zddsyhrdimyra.us-4.magentosite.cloud/"
CLOUD_PWA_URL="https://pwa-n3sumvi-xy4itwbmg2khk.demo.magentosite.cloud/"

if ! which node > /dev/null; then
  curl -o "/tmp/${NODE_VERSION}.tar.gz" "https://nodejs.org/dist/${NODE_VERSION}/node-${NODE_VERSION}-darwin-x64.tar.gz"
  mkdir -p "${HOME}/${NODE_VERSION}"
  tar -zxf "/tmp/${NODE_VERSION}.tar.gz" -C "${HOME}/${NODE_VERSION}" --strip 1
  ln -sf "${HOME}/${NODE_VERSION}/bin/node" /usr/local/bin/node
  ln -sf "${HOME}/${NODE_VERSION}/bin/npm" /usr/local/bin/npm
  rm "/tmp/${NODE_VERSION}.tar.gz"
fi

if [[ ! -d "${HOME}/pwa-studio/node_modules" ]]; then
  cd "${HOME}"
  git clone https://github.com/magento-research/pwa-studio.git
  cd pwa-studio/
  npm install
  perl -pe "s!${GIT_PWA_URL}!${CLOUD_PWA_URL}!g" packages/venia-concept/.env.dist > packages/venia-concept/.env
  npm run build || :
fi 

cd "${HOME}/pwa-studio/"

if [ "$(git rev-parse @)" -ne $(git rev-parse @{u}) ]; then
  read -p "There is an update to PWA. It may contain breaking changes. Upgrade? (y/n)" -n 1 -r
  echo # new line
  if [[ "${REPLY}" =~ ^[Yy]$ ]]
  then
    git pull
    npm install
    npm run build || :
  fi
fi

npm run watch:venia
