
# transfer tinyproxy to the env
ssh_cmd=$(get_interactive_ssh_cmd ${project} ${environment})
curl -s -o - "https://raw.githubusercontent.com/PMET-public/magento-cloud-extension/${ext_ver}/tinyproxy/tinyproxy.tar.gz" | $ssh_cmd "tar -C /tmp -xzf -"

# start SOCKS proxy for git access over ssh via netcat (nc) var below
# also start HTTP proxy (tinyproxy) with auto kill
$ssh_cmd -f -D 8889 -L 8888:localhost:8888 "nohup sh -c 'sleep 7200; pkill tinyproxy' > /dev/null 2>&1 &; /tmp/tinyproxy/tinyproxy -c /tmp/tinyproxy/tinyproxy.conf"

echo "printf '${red}\nNotes:\n\n1. Proxy will be open for 2 hrs.\n'"
echo "printf '2. Composer and ssh only configured for this terminal.\n'"
echo "printf '3. If you need gitlab web access, configure your browser:\n\thttps://raw.githubusercontent.com/PMET-public/magento-cloud-extension/${ext_ver}/tinyproxy/\n\n${no_color}'"
echo 'export GIT_SSH_COMMAND='\''ssh -o ProxyCommand="nc -x 127.0.0.1:8100 %h %p"'\'' HTTP_PROXY=http://127.0.0.1:8888; exec bash'
