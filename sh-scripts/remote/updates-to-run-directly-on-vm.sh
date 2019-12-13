#!/bin/bash

if [[ -z "$debug" || $debug -eq 1 ]]; then
  set -x
  set -e
fi

# keep cron success status msg 
crontab -l | perl -pe 's/Ran jobs by schedule/DONT REMOVE CRON STATUS MSG/' | crontab -
