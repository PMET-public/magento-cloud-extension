printf "\nFlushing cache ...\n"

"${cli_path}" environment:delete --no-wait --yes -p "${project}" -e "${environment}"
