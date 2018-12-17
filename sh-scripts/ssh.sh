#printf "\nSSHing into ...\n${ssh_cmd}"

$(get_interactive_ssh_cmd "${project}" "${environment}")
