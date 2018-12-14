if [[ ! -z "${debug}" ]]; then
  set -x
fi

# stop on errors
set -e

red='\033[0;31m'
green='\033[0;32m'
yellow='\033[1;33m'
no_color='\033[0m'

error() {
  printf "\n${red}${@}${no_color}\n\n" && exit
}

warning() {
  printf "\n${yellow}${@}${no_color}\n\n"
}

msg() {
  printf "\n${green}${@}${no_color}\n\n"
}

menu_height=20
menu_width=70
num_visible_choices=10
# tab_url_simplified has no trailing "/" but by Magento convention base_url does
tab_url_simplified=$(echo "${tab_url}" | perl -pe "s!^(https?://[^/]+).*!\1!")
base_url=""
domain=$(echo "${tab_url_simplified}" | perl -pe "s!https?://!!")
cli_path="${HOME}/.magento-cloud/bin/magento-cloud"
backups_dir="${HOME}/Downloads/m2-backups"
sql_file=/tmp/db.sql

is_cloud() {
  [[ "${tab_url_simplified}" =~ .magento(site)?.cloud ]]
  return $?
}

set_db_vars() {
  if is_cloud; then
    additional_files=".magento.app.yaml"
    tar_file="/tmp/$(date "+%Y-%m-%d-%H-%M")-${project}-${environment}.tar"
    db_host=database.internal
    db_port=3306
    db_user=user
    db_name=main
    db_pass=""
  else
    additional_files=""
    tar_file="/tmp/$(date "+%Y-%m-%d-%H-%M")-${domain}.tar"
    db_host=127.0.0.1
    db_port=3306
    db_user=user
    db_name=main
    db_pass=""
  fi
}

get_cloud_base_url() {
  echo "$(${cli_path} url -p "${1}" -e "${2}" --pipe | grep https -m 1 | perl -pe 's/\s+//')"
}

get_cloud_ssh_url() {
  echo "$(${cli_path} ssh -p "${1}" -e "${2}" --pipe 2> /dev/null || :)"
}

get_ssh_url() {
  # if parameters are passed, used those
  # otherwise determine from env vars
  if [[ $# -eq 2 ]]; then 
    get_cloud_ssh_url $*
  elif is_cloud; then  
    get_cloud_ssh_url $project $environment
  else
    echo "vagrant@${domain}"
  fi
}

get_ssh_cmd() {
  echo "ssh -n -i ${identity_file} $(get_ssh_url $*)"
}

get_interactive_ssh_cmd() {
  echo "ssh -i ${identity_file} $(get_ssh_url $*)"
}

restore_from_tar() {
  local tar_file=$1
  local project=$2
  local environment=$3
  # send media and sql back file
  cat "${backups_dir}/${tar_file}" | $(get_interactive_ssh_cmd $project $environment) "tar -xf - -C / app/pub/media tmp"

  # get sql_file name
  sql_file=$(tar -tf "${backups_dir}/${tar_file}" | grep "var/backups/.*.sql" | sed "s/.*\///")

  # replace hostname and rollback db
  $(get_ssh_cmd $project $environment) "
    new_base_url=\$(curl -sI localhost | sed -n \"s/location: //i;s/\.cloud\/.*/.cloud/p\")
    gunzip ${sql_file}.gz
    perl -i -pe \"s!REPLACEMENT_BASE_URL!\${new_base_url}!g\" ${sql_file}

  "
}

if is_cloud; then

  # determine relevant project and environment
  if [[ "${tab_url}" =~ .magento.cloud/projects/.*/environments ]]; then
    project=$(echo "${tab_url}" | perl -pe "s!.*?projects/!!;s!/environments/.*!!;")
    environment=$(echo "${tab_url}" | perl -pe "s!.*?environments/!!;s!/.*!!;")
    base_url=$(get_cloud_base_url "${project}" "${environment}")
  else
    base_url="${tab_url_simplified}/"
    project=$(echo "${tab_url}" | perl -pe "s/.*-//;s/\..*//;")
    environments=$("${cli_path}" environments -I -p "${project}" --pipe)
    environment=""
    modified_env_pattern=$(echo "${tab_url_simplified}" | perl -pe 's!https://(.*?)-[^-]+-[^-]+$!\1!')
    for e in ${environments}; do
      if [[ "${e}" = "${modified_env_pattern}" ]]; then
        environment="${e}"
        break
      fi
    done
    # if we didn't find an env match based on just the url, do a more thorough but time consuming search via the cli
    if [[ -z "${environment}" ]]; then
      for e in ${environments}; do
        if [[ $(get_cloud_base_url "${project}" "${e}") = "${tab_url_simplified}/" ]]; then
          environment="${e}"
          break
        fi
      done
    fi
  fi

  if [[ -z "${project}" ]]; then
    error Project not found in your projects or could not be determined from url.
  elif [[ -z "${environment}" ]]; then
    error Environment not found or could not be determined from url.
  fi

  # prevent exit on inactive env but warn
  if [[ -z $(get_ssh_url) ]]; then
    warning SSH URL could not be determined. Environment inactive?
  fi
  identity_file="${HOME}/.ssh/id_rsa.magento"
  app_dir="/app"

else
  
  # if not magento cloud, assume local vm
  identity_file="${HOME}/.ssh/demo-vm-insecure-private-key"
  app_dir="/var/www/magento"

  # verify local vm key exists
  if [[ ! -f "${identity_file}" ]]; then
    curl -o "${identity_file}" https://raw.githubusercontent.com/PMET-public/magento-cloud-extension/master/sh-scripts/demo-vm-insecure-private-key
    chmod 600 "${identity_file}"
  fi

fi

ssh_cmd="$(get_ssh_cmd)"
scp_cmd="scp -i ${identity_file}"
