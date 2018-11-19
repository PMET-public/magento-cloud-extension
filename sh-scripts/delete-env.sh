printf "\nDeleting env ... Answer \"Yes\" to both questions below to immediately deactivate AND delete your env.\n"

"${cli_path}" environment:delete -p "${project}" -e "${environment}"
