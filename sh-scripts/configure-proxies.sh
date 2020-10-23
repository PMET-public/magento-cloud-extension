# shellcheck shell=bash
: || source lib.sh # trick shellcheck into finding certain referenced vars

# since this feature only applies to setting up connections via cloud
# directly set applicable variables

project=$($cli_path projects --pipe | head -1)
if [[ -z "$project" ]]; then
  error "Could not find a valid cloud project. Are you logged in?"
fi
environment=master

# transfer tinyproxy to the env
ssh_cmd=$(get_interactive_ssh_cmd $project $environment)
curl -s -o - "https://raw.githubusercontent.com/PMET-public/magento-cloud-extension/$ext_ver/tinyproxy/tinyproxy.tar.gz" | $ssh_cmd "tar -C /tmp -xzf -"

# start SOCKS proxy for git access over ssh via netcat (nc) var below
# also start HTTP proxy (tinyproxy) with auto kill
# proper backgrounding when invoked in subshell: https://stackoverflow.com/questions/50613945/bash-run-command-in-background-inside-subshell
ssh -n $(get_ssh_url $project $environment) "pkill tinyproxy || :"
ssh -n -D 8889 -L 8888:localhost:8888 $(get_ssh_url $project $environment) \
  "nohup sh -c 'sleep 14400; pkill tinyproxy' > /dev/null 2>&1 & /tmp/tinyproxy/tinyproxy -d -c /tmp/tinyproxy/tinyproxy.conf" > /dev/null &

printf "$red\nNotes:\n\n1. Access granted for 4 hrs or until local/remote processes stopped.\n" >&2
printf "2. Composer and git cmds are only configured for this terminal.\n" >&2
printf "3. For gitlab web access (only if you need it), instructions to configure your browser can be found here:\n" >&2
printf "\thttps://github.com/PMET-public/magento-cloud-extension/tree/$ext_ver/tinyproxy\n\n$no_color" >&2

echo export GIT_SSH_COMMAND=\'ssh -o ProxyCommand=\"nc -x 127.0.0.1:8889 %h %p\"\' HTTP_PROXY=http://127.0.0.1:8888
echo exec bash
