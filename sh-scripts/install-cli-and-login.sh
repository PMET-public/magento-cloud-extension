#!/usr/bin/env bash

# if php is missing (removed in OSX Monterey), install php via homebrew
# https://developer.apple.com/forums/thread/681907
[[ -z "$(which php)" ]] || {
  [[ -z "$(which brew)" ]] || {
    printf "\n\033[0;32mInstalling Homebrew ...\033[0m\n\n"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  }
  printf "\n\033[0;32mInstalling php ...\033[0m\n\n"
  brew install php@7.4
}

# remember lib.sh is not loaded
printf "\n\033[0;32mInstalling magento-cloud CLI ...\033[0m\n\n"

curl -sS https://accounts.magento.cloud/cli/installer | php
~/.magento-cloud/bin/magento-cloud login || :
