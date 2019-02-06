msg Deleting env ... Answer \"Yes\" to both questions below to immediately deactivate AND delete your env.

# kill any php process up to 10 times in the next 10 min
# that may still be running and blocking a proper shutdown
$ssh_cmd "for i in {1..10}; do pkill php; sleep 60; done &" &

# --delete-branch appears to be incompatible with the --no-wait flag
"${cli_path}" environment:delete -p "${project}" -e "${environment}" --delete-branch
