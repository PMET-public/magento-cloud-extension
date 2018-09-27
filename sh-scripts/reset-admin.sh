
echo "$url"
exit


~/.magento-cloud/bin/magento-cloud environments -p xpwgonshm6qm2 --pipe | \
  xargs -I + sh -c 'echo -n "+ "; ~/.magento-cloud/bin/magento-cloud url -p xpwgonshm6qm2 -e +;' | \
  grep "$url" | \
  awk '{print $1;}'