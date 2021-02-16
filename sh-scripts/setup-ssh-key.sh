#!/usr/bin/env bash

if [[ "$HOME" == "/app" ]]; then
  echo "You are probably attempting to run this command in a cloud env. Commands are intended to be run in a local terminal." && exit 1
fi

printf "\nCreating and adding ssh key to cloud account ...\n"

if [ ! -f ~/.ssh/id_rsa.magento ]; then
  ssh-keygen -t rsa -N '' -f ~/.ssh/id_rsa.magento;
fi

~/.magento-cloud/bin/magento-cloud ssh-key:add ~/.ssh/id_rsa.magento.pub --yes
