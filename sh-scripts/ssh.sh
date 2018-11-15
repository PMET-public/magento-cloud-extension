#printf "\nSSHing into ...\n${ssh_cmd}"

ssh_cmd=$(echo "${ssh_cmd}" | sed "s/ -n / /")
echo $ssh_cmd
