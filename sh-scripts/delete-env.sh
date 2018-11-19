printf "\nDeleting env ...\n"

"${cli_path}" environment:delete --no-wait -p "${project}" -e "${environment}"
