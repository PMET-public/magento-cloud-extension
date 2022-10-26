# shellcheck shell=bash
: || source lib.sh # trick shellcheck into finding certain referenced vars

msg "Updating access ..."

read -r -n 1 -p "You may add 1 additional, temporary IP (such as your current IP address) to the default egress list.

Add an IP? (y/n)
" < "$read_input_src" 2>/dev/tty
echo ""

case ${REPLY} in
y)
  cur_ip=$(curl -s ifconfig.co)
  read -r -p "Hit return to accept your current detected IP [$cur_ip] or enter an additional IP address:
" < "$read_input_src" 2>/dev/tty
  if [[ -z "$REPLY" ]]; then
    REPLY=${cur_ip}
  elif [[ ! $REPLY =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
    error Invalid IP address: "$REPLY"
  fi
  extra_ip_opt="--access allow:$REPLY"
  ;;
*)
  echo "Using default egress list only."
  ;;
esac

# pass and ip list
$cli_path httpaccess -p $project -e $environment --no-wait --auth "admin:$project" $extra_ip_opt $auth_opts
