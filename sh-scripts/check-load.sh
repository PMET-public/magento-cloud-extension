#!/bin/bash

CLI_PATH=~/.magento-cloud/bin/magento-cloud
SSH_CMD="${CLI_PATH} ssh"
if [ -f ${HOME}/.ssh/id_rsa.magento ]; then
  SSH_CMD="${SSH_CMD} -i ${HOME}/.ssh/id_rsa.magento"
fi

# url is passed via `env url=https://....`
#echo $url

project=$(echo "$url" | perl -pe "s/.*-//;s/\..*//;")
#echo $project

environment=$($CLI_PATH environments -p $project --pipe | \
  xargs -I + sh -c "printf '%s ' '+'; $CLI_PATH url -p $project -e + --pipe;" | \
  grep $url | \
  awk '{print $1}')
#echo $environment

red='\033[0;31m'
green='\033[0;32m'
yellow='\033[1;33m'
no_color='\033[0m'

read -r nproc loadavg1 loadavg5 < <($SSH_CMD -p $project -e $environment 'echo $(nproc) $(awk "{print \$1, \$2}" /proc/loadavg)' 2> /dev/null) 

load1=$(awk "BEGIN {printf \"%.f\", $loadavg1 * 100 / $nproc}")
load5=$(awk "BEGIN {printf \"%.f\", $loadavg5 * 100 / $nproc}")

[[ $load1 -gt 99 ]] && color="$red" || [[ $load1 -gt 89 ]] && color="$yellow" || color="$green"
printf "The past 1 min load for this host: $color$load1%%$no_color\n"
printf "The past 5 min load for this host: $color$load5%%$no_color\n"
echo "Just a reminder: host =/= env. A env may be limited even if resources are available on its host."