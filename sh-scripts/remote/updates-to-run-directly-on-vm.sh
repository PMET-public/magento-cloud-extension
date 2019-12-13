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

# keep cron success status msg
crontab -l |
  tee /tmp/$cur_unix_ts-crontab |
  perl -pe 's/Ran jobs by schedule/DONT REMOVE CRON STATUS MSG/' |
  crontab -
