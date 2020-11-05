# shellcheck shell=bash
: || source lib.sh # trick shellcheck into finding certain referenced vars

msg "Deleting env ..."

read -r -n 1 -p "Confirm deletion of project: $project environment: $environment (y/n): " < "$read_input_src"
if [[ "$REPLY" =~ ^[Yy]$ ]]; then
  # kill any php process up to 10 times in the next 10 min
  # that may still be running and blocking a proper shutdown
  $cmd_prefix "for i in {1..10}; do pkill php; sleep 60; done &" &

  # in v1.23, --delete-branch appears to be incompatible with the --no-wait flag, so it must be run twice
  "$cli_path" environment:delete -p "$project" -e "$environment" --delete-branch --no-wait --yes
  sleep 30
  "$cli_path" environment:delete -p "$project" -e "$environment" --delete-branch --no-wait --yes
else
  exit
fi
