if [[ ! -z "${debug}" ]]; then
  set -x
fi

# stop on errors
set -e

red='\033[0;31m'
green='\033[0;32m'
yellow='\033[1;33m'
no_color='\033[0m'

simplified_url=$(echo "${url}" | perl -pe "s!^(https?://[^/]+).*!\1!")
domain=$(echo "${simplified_url}" | perl -pe "s!https?://!!")
cli_path="${HOME}/.magento-cloud/bin/magento-cloud"
backups_dir="${HOME}/Downloads/m2-backups"

if [[ "${simplified_url}" =~ .magento(site)?.cloud ]]; then

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

  user_and_host="$(${cli_path} ssh -p "${project}" -e "${environment}" --pipe)"
  identity_file="${HOME}/.ssh/id_rsa.magento"
  home_dir="/app"

  if [[ -z "${project}" ]]; then
    printf "${red}Project not found in your projects or could not be determined from url.${no_color}\n" && exit
  elif [[ -z "${environment}" ]]; then
    printf "${red}Environment not found or could not be determined from url.${no_color}\n" && exit
  fi

else
  
  # if not magento cloud, assume local vm
  user_and_host="vagrant@${domain}"
  identity_file="${HOME}/.ssh/demo-vm-insecure-private-key"
  home_dir="/var/www/magento"

  # verify local vm key exists
  if [[ ! -f "${identity_file}" ]]; then
    curl -o "${identity_file}" https://raw.githubusercontent.com/PMET-public/magento-cloud-extension/master/sh-scripts/demo-vm-insecure-private-key
    chmod 600 "${identity_file}"
  fi

fi

ssh_cmd="ssh -n -i ${identity_file} ${user_and_host}"
scp_cmd="scp -i ${identity_file} ${user_and_host}"
