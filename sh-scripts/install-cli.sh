#!/usr/bin/env bash

# if brew is missing, install it
[[ -z "$(which brew)" ]] && {
  printf "\n\033[0;32mInstalling Homebrew ...\033[0m\n\n"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  [[ "$SHELL" = "zsh" ]] && {
    echo; echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "$HOME/.zprofile"
    eval "$(/opt/homebrew/bin/brew shellenv)"
  }
}

# if php is missing (removed in OSX Monterey), install php via homebrew
# https://developer.apple.com/forums/thread/681907
[[ -z "$(which php)" ]] && {
  printf "\n\033[0;32mInstalling php ...\033[0m\n\n"
  brew install php@8.1
  printf "\n\033[0;32mLinking php ...\033[0m\n\n"
  brew link php@8.1
}

# remember lib.sh is not loaded
printf "\n\033[0;32mInstalling magento-cloud CLI ...\033[0m\n\n"

curl -sS https://accounts.magento.cloud/cli/installer | php
