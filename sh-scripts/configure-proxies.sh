
ssh_cmd=$(get_interactive_ssh_cmd ${project} ${environment})
curl -s -o - "https://raw.githubusercontent.com/PMET-public/magento-cloud-extension/${ext_ver}/tinyproxy.tar.gz" | $ssh_cmd "tar -C /tmp -xzf -"
$ssh_cmd -f -D 8889 -L 8888:localhost:8888 "/tmp/tinyproxy/tinyproxy -c /tmp/tinyproxy/tinyproxy.conf; nohup sh -c 'sleep 3600; pkill tinyproxy' > /dev/null 2>&1 &"
echo export GIT_SSH_COMMAND=\'ssh -o ProxyCommand=\"nc -x 127.0.0.1:8100 %h %p\"\' HTTP_PROXY=\'http://127.0.0.1:8888\' \; exec bash
