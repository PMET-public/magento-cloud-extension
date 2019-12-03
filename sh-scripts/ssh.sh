#printf "\nSSHing into ...\n${ssh_cmd}"

echo $(get_interactive_ssh_cmd "${project}" "${environment}") | bash
