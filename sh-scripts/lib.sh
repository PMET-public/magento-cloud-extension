if [[ ! -z "${debug}" ]]; then
  set -x
fi

red='\033[0;31m'
green='\033[0;32m'
yellow='\033[1;33m'
no_color='\033[0m'

simplified_url=$(echo "${url}" | perl -pe "s!^(https?://[^/]+).*!\1!")
domain=$(echo "${simplified_url}" | perl -pe "s!https?://!!")

if [[ "${simplified_url}" =~ .magento(site)?.cloud ]]; then

  home_dir="/app"
  cli_path="${HOME}/.magento-cloud/bin/magento-cloud"

  # determine relevant project and environment
  if [[ "${url}" =~ .magento.cloud/projects/.*/environments ]]; then
    project=$(echo "${url}" | perl -pe "s!.*?projects/!!;s!/environments/.*!!;")
    environment=$(echo "${url}" | perl -pe "s!.*?environments/!!;s!/.*!!;")
  else
    project=$(echo "${url}" | perl -pe "s/.*-//;s/\..*//;")
    environment=$("${cli_path}" environments -p "${project}" --pipe | \
      xargs -I + sh -c "printf '%s ' '+'; "${cli_path}" url -p "${project}" -e + --pipe;" | \
      grep "${simplified_url}" | \
      awk '{print $1}')
  fi

  if [[ -z "${project}" ]]; then
    printf "${red}Project not found in your projects or could not be determined from url.${no_color}\n" && exit
  elif [[ -z "${environment}" ]]; then
    printf "${red}Environment not found or could not be determined from url.${no_color}\n" && exit
  fi

  # create ssh cmd
  ssh_cmd="ssh -n $(${cli_path} ssh -p "${project}" -e "${environment}" --pipe)"
  if [[ -f "${HOME}/.ssh/id_rsa.magento" ]]; then
    ssh_cmd="${ssh_cmd} -i ${HOME}/.ssh/id_rsa.magento"
  fi  

else

  # if not magento cloud, assume local vm
  home_dir="/var/www/magento"
  ssh_cmd="ssh -n vagrant@${domain} -i ${HOME}/.ssh/demo-vm-insecure-private-key"
  
  # verify local vm key exists
  if [[ ! -f "${HOME}/.ssh/demo-vm-insecure-private-key" ]]; then
    curl -o "${HOME}/.ssh/demo-vm-insecure-private-key" https://raw.githubusercontent.com/PMET-public/magento-cloud-extension/master/sh-scripts/demo-vm-insecure-private-key
    chmod 600 "${HOME}/.ssh/demo-vm-insecure-private-key"
  fi

fi
