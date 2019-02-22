# remember lib.sh is not run before this so can not use the msg function
printf "\n${green}Installing magento-cloud CLI ...${no_color}\n\n"

curl -sS https://accounts.magento.cloud/cli/installer | php
~/.magento-cloud/bin/magento-cloud login
