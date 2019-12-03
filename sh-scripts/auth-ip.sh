msg Enabling IP based access ...

read -p "You may add 1 additional, temporary IP (such as your current IP address) to the default egress list.

Add an IP? (y/n)
" -n 1 -r < /dev/tty
echo ""

case ${REPLY} in
y)
  cur_ip=$(curl -s ifconfig.co)
  read -p "Enter additional IP address or hit return to accept your current detected IP [${cur_ip}]:
  " -r < /dev/tty
  echo "Adding ${REPLY}"
  ;;
*)
  echo "Using default egress list only."
  ;;
esac

${cli_path} httpaccess -p ${project} -e ${environment} --no-wait --auth ""
${cli_path} httpaccess -p ${project} -e ${environment} --no-wait ${auth_opts}