printf "\nSetting up PWA Studio ...\n"

NODE_VERSION="v10.15.0"

declare -a "pwa_backend_urls=(
  '1. Cloud Backend ' 'https://pwa-sc-s6uhy2i-u3uh6xofiwzu2.demo.magentosite.cloud/'
  '2. VM Backend ' 'http://luma.com/'
)"

selection=$(dialog --clear \
  --backtitle "Choose which server the PWA should access" \
  --title "Available options" \
  --menu "Choose which server the PWA should access:" \
  $menu_height $menu_width $num_visible_choices \
  "${pwa_backend_urls[@]}" \
  2>&1 >/dev/tty)
selection=$(echo "${selection}" | perl -pe 's/\..*//')
pwa_backend_url="${pwa_backend_urls[$(( (${selection} - 1) * 2 + 1))]}"

if ! which node > /dev/null; then
  curl -o "/tmp/${NODE_VERSION}.tar.gz" "https://nodejs.org/dist/${NODE_VERSION}/node-${NODE_VERSION}-darwin-x64.tar.gz"
  mkdir -p "${HOME}/${NODE_VERSION}"
  tar -zxf "/tmp/${NODE_VERSION}.tar.gz" -C "${HOME}/${NODE_VERSION}" --strip 1
  echo "Password required to install node ..."
  sudo ln -sf "${HOME}/${NODE_VERSION}/bin/node" /usr/local/bin/node
  sudo ln -sf "${HOME}/${NODE_VERSION}/bin/npm" /usr/local/bin/npm
  rm "/tmp/${NODE_VERSION}.tar.gz"
fi

if [[ ! -d "${HOME}/pwa-studio/node_modules" ]]; then
  cd "${HOME}"
  git clone https://github.com/magento-research/pwa-studio.git
  cd pwa-studio/
  npm install
  cp packages/venia-concept/.env.dist packages/venia-concept/.env
  npm run build || :
fi 

cd "${HOME}/pwa-studio/"

if [ "$(git rev-parse @)" != $(git rev-parse @{u}) ]; then
  read -p "There is an update to PWA. It may contain breaking changes. Upgrade? (y/n): " -n 1 -r < /dev/tty
  if [[ "${REPLY}" =~ ^[Yy]$ ]]
  then
    git pull
    npm install
    npm run build || :
  fi
fi

perl -i -pe "s!^MAGENTO_BACKEND_URL=.*!MAGENTO_BACKEND_URL=\"${pwa_backend_url}\"!g" "${HOME}/pwa-studio/packages/venia-concept/.env"

npm run watch:venia
