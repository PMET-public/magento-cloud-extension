
curl https://raw.githubusercontent.com/PMET-public/magento-cloud-extension/master/tinyproxy.tar.gz | $ssh_cmd "tar -C /tmp -xzf -"
$ssh_cmd -D 8889 -L 8888:localhost:8888 "/tmp/tinyproxy/tinyproxy -d -c /tmp/tinyproxy/tinyproxy.conf"
export GIT_SSH_COMMAND="ssh -o ProxyCommand='nc -x 127.0.0.1:8100 %h %p'" 
export HTTP_PROXY="http://127.0.0.1:8888"
