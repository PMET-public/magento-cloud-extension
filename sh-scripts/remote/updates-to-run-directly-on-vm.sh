#! /bin/bash

#!/bin/bash

if [[ -z "$debug" || $debug -eq 1 ]]; then
  set -x
  set -e
fi

# make it easy to call via bash history or while writing/debugging
[[ "$0" =~ "most-recent" ]] || rm /tmp/most-recent-vm-updates.sh || ln -s $0 /tmp/most-recent-vm-updates.sh

touch /tmp/delme-$(date +%s)
