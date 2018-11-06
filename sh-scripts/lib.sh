#!/bin/bash

CLI_PATH=~/.magento-cloud/bin/magento-cloud
SSH_CMD="${CLI_PATH} ssh"
if [[ -f "${HOME}/.ssh/id_rsa.magento" ]]; then
  SSH_CMD="${SSH_CMD} -i ${HOME}/.ssh/id_rsa.magento"
fi


if [[ "${url}" =~ .magento.cloud/projects/ ]]; then
  project=$(echo "${url}" | perl -pe "s!.*?projects/!!;s!/environments/.*!!;")
  environment=$(echo "${url}" | perl -pe "s!.*?environments/!!;s!/.*!!;")
else
  project=$(echo "${url}" | perl -pe "s/.*-//;s/\..*//;")
  environment=$("${CLI_PATH}" environments -p "${project}" --pipe | \
    xargs -I + sh -c "printf '%s ' '+'; "${CLI_PATH}" url -p "${project}" -e + --pipe;" | \
    grep "${url}" | \
    awk '{print $1}')
fi

red='\033[0;31m'
green='\033[0;32m'
yellow='\033[1;33m'
no_color='\033[0m'

printf "\nRunning command for:\n${green}${url}${no_color}\n\n"
