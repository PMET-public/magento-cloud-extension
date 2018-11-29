printf "\nInstalling magento-cloud CLI ...\n"

curl -sS https://accounts.magento.cloud/cli/installer | php
~/.magento-cloud/bin/magento-cloud login
