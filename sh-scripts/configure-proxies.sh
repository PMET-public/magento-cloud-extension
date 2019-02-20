
# transfer tinyproxy to the env
ssh_cmd=$(get_interactive_ssh_cmd ${project} ${environment})
curl -s -o - "https://raw.githubusercontent.com/PMET-public/magento-cloud-extension/${ext_ver}/tinyproxy/tinyproxy.tar.gz" | $ssh_cmd "tar -C /tmp -xzf -"

# start SOCKS proxy for git access over ssh via netcat (nc) var below
# also start HTTP proxy (tinyproxy) with auto kill
# proper backgrounding when invoked in subshell: https://stackoverflow.com/questions/50613945/bash-run-command-in-background-inside-subshell
ssh -n -D 8889 -L 8888:localhost:8888 -i ${identity_file} $(get_ssh_url) \
  "nohup sh -c 'sleep 7200; pkill tinyproxy' > /dev/null 2>&1 & /tmp/tinyproxy/tinyproxy -d -c /tmp/tinyproxy/tinyproxy.conf" > /dev/null &

printf "${red}\nNotes:\n\n1. Proxy opened for 2 hrs.\n" >&2
printf "2. Composer and ssh are only configured for this terminal.\n" >&2
printf "3. If you need gitlab web access, instructions to configure your browser can be found here:\n" >&2
printf "\thttps://github.com/PMET-public/magento-cloud-extension/tree/${ext_ver}/tinyproxy\n\n${no_color}" >&2
echo GIT_SSH_COMMAND='ssh -o ProxyCommand="nc -x 127.0.0.1:8100 %h %p"'
echo HTTP_PROXY=http://127.0.0.1:8888
