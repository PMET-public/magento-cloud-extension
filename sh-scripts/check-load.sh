#!/bin/bash

CLI_PATH=~/.magento-cloud/bin/magento-cloud

# url is passed via `env url=https://....`
#echo $url

project=$(echo "$url" | perl -pe "s/.*-//;s/\..*//;")
#echo $project

environment=$($CLI_PATH environments -p $project --pipe | \
  xargs -I + sh -c "printf '%s ' '+'; $CLI_PATH url -p $project -e + --pipe;" | \
  grep $url | \
  awk '{print $1}')
#echo $environment