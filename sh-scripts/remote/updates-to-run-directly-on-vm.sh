#!/bin/bash

if [[ -z "$debug" || $debug -eq 1 ]]; then
  set -x
  set -e
fi

red='\033[0;31m'
green='\033[0;32m'
yellow='\033[1;33m'
no_color='\033[0m'
cur_unix_ts=$(date +%s)

report () {
  printf "${@}" | tee -a /tmp/$cur_unix_ts-report.log
}

# update crontab
# first del old magento tasks
crontab -l | perl -p00e 's/#~ MAGENTO[\S\s]*#~ MAGE.*?\n//' > /tmp/new-cron
# append modified version
cat << 'EOF' >> /tmp/new-cron
#~ MAGENTO START d1958f62aa710cc367525c9ec68dd7456d4311756b5aa37d2143c4a98b25318c
lf=/var/www/magento/var/log/magento.cron.log
* * * * * echo "\n$(date +[\%Y-\%m-\%d\ \%H:\%M:\%S]) Launching command 'php bin/magento cron:run'.\n" >> $lf && /usr/bin/php7.3 /var/www/magento/bin/magento cron:run 2>&1 >> $lf
* * * * * /usr/bin/php7.3 /var/www/magento/update/cron.php >> /var/www/magento/var/log/update.cron.log
* * * * * /usr/bin/php7.3 /var/www/magento/bin/magento setup:cron:run >> /var/www/magento/var/log/setup.cron.log
#~ MAGENTO END d1957f62aa710cc367525c9ec68dd7456d4311756b5aa37d2143c4a98b25318c
EOF
# load new
crontab /tmp/new-cron

# delete anything before Oct (ideally this should be converted to a rolling average)
cd /var/www/magento/var/log
sed -i '/^\[2019-0/d' *.log

sudo rm /var/log/*.log.* /var/log/*.gz 2> /dev/null || :
