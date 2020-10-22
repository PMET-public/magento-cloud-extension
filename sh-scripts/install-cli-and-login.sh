#!/usr/bin/env bash

# remember lib.sh is not loaded
printf "\n\033[0;32mInstalling magento-cloud CLI ...\033[0m\n\n"

curl -sS https://accounts.magento.cloud/cli/installer | php
~/.magento-cloud/bin/magento-cloud login
