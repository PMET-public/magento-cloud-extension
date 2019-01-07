msg Deleting env ... Answer \"Yes\" to both questions below to immediately deactivate AND delete your env.

# --delete-branch appears to be incompatible with the --no-wait flag
"${cli_path}" environment:delete -p "${project}" -e "${environment}" --delete-branch
