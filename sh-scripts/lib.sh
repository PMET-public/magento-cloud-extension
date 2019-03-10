if [[ ! -z "${debug}" ]]; then
  set -x
fi

# stop on errors
set -e

cli_required_version="1.23.0"
cli_path="${HOME}/.magento-cloud/bin/magento-cloud"
cli_actual_version=$("${cli_path}" --version | perl -pe 's/.*?([\d\.]+)/\1/')
if [[ "${cli_actual_version}" != "${cli_required_version}" ]]; then
  cli_path="${cli_path}-${cli_required_version}"
  if [[ ! -f "${cli_path}" ]]; then
    curl -s -o "${cli_path}" "https://accounts.magento.cloud/sites/default/files/magento-cloud-v${cli_required_version}.phar" || (echo Could not retrieve required cli version && exit 1)
    chmod +x "${cli_path}"
  fi
fi

red='\033[0;31m'
green='\033[0;32m'
yellow='\033[1;33m'
no_color='\033[0m'

error() {
  printf "\n${red}${@}${no_color}\n\n" && exit 1
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
backups_dir="${HOME}/Downloads/m2-backups"
sql_file=/tmp/db.sql

is_cloud() {
  [[ "${tab_url_simplified}" =~ .magento(site)?.cloud ]]
  return $?
}

set_db_vars() {
  if is_cloud; then
    db_host=database.internal
    db_port=3306
    db_user=user
    db_name=main
    db_pass=""
  else
    db_host=127.0.0.1
    db_port=3306
    db_user=user
    db_name=main
    db_pass=""
  fi
  db_opts="-h \"${db_host}\" -P \"${db_port}\" -u \"${db_user}\" --password=\"${db_pass}\" \"${db_name}\""
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

choose_backup() {
  tar_file_pattern="${1}"
  local_tar_files=($(find "${backups_dir}" -name "*${tar_file_pattern}*.tar" 2>/dev/null | sort -r | perl -pe 's!.*/!!' | cat -n))
  if [[ ${#local_tar_files[@]} -lt 1 ]]; then
    error No files matching "*-${tar_file_pattern}" found in "${backups_dir}"
  fi

  selection=$(dialog --clear \
    --backtitle "Restoring env from backup ..." \
    --title "Your Backup(s)" \
    --menu "Choose a backup file to deploy to ${pattern}:" \
    $menu_height $menu_width $num_visible_choices "${local_tar_files[@]}" \
    2>&1 >/dev/tty)
  clear > /dev/null
  echo "${local_tar_files[$(( (${selection} - 1) * 2 + 1))]}" # account for menu numbering vs array with labels numbering
}

reset_env() {
  local project="${1:-$project}"
  local environment="${2:-$environment}"
  local ssh_cmd=$(get_ssh_cmd ${project} ${environment})
  ${ssh_cmd} "
    mysql -h ${db_host} -e 'drop database if exists ${db_name}; 
    create database if not exists ${db_name} default character set utf8;'; 
    # can not remove var/export so or noop cmd (|| :) in case it exists
    rm -rf ~/var/* ~/pub/media/* ~/app/etc/env.php ~/app/etc/config.php || :
  "
}

reindex_env() {
  local project="${1:-$project}"
  local environment="${2:-$environment}"
  local ssh_cmd=$(get_ssh_cmd ${project} ${environment})
  ${ssh_cmd} "
    php ${app_dir}/bin/magento indexer:reset; php ${app_dir}/bin/magento indexer:reindex
  "
}

enable_cron() {
  local project="${1:-$project}"
  local environment="${2:-$environment}"
  local ssh_cmd=$(get_ssh_cmd ${project} ${environment})
  ${ssh_cmd} "
    sed -i.bak '/cron.*enabled/d' /app/app/etc/env.php
  "
}

disable_cron() {
  local project="${1:-$project}"
  local environment="${2:-$environment}"
  local ssh_cmd=$(get_ssh_cmd ${project} ${environment})
  ${ssh_cmd} "
    # prevent duplicate lines
    sed -i.bak '/cron.*enabled/d' /app/app/etc/env.php
    # insert disable line
    sed -i.bak '\$i\\\x27cron\x27 => array ( \x27enabled\x27 => 0, ),' /app/app/etc/env.php
  "
}

transfer_local_tar_to_remote() {
  local local_tar_file="${1}"
  local project="${2:-$project}"
  local environment="${3:-$environment}"
  $(${scp_cmd} "${backups_dir}/${local_tar_file}" $(get_ssh_url "${project}" "${environment}"):/tmp)
}

restore_files_from_tar() {
  local local_tar_file="${1}"
  local project="${2:-$project}"
  local environment="${3:-$environment}"
  local ssh_cmd=$(get_ssh_cmd ${project} ${environment})
  ${ssh_cmd} "
    rm -rf \"${app_dir}/var/log/*\" \"${app_dir}/pub/media/catalog/*\"
    tar -xf /tmp/${local_tar_file} -C / --exclude=\"${app_dir}/pub/media\" --anchored ${app_dir#'/'} || :
  "
}

restore_db_from_tar() {
  local local_tar_file="${1}"
  local project="${2:-$project}"
  local environment="${3:-$environment}"
  local ssh_cmd=$(get_ssh_cmd ${project} ${environment})
  ${ssh_cmd} "
    rm ${sql_file} 2> /dev/null # if an old file exists from previous attempt
    tar -xf /tmp/${local_tar_file} -C / tmp
    gunzip ${sql_file}.gz
    perl -i -pe \"\\\$c+=s!REPLACEMENT_BASE_URL!$(get_cloud_base_url ${project} ${environment})!g;
      END{ if (\\\$c == 0) {exit 1;} print \\\"\n\\\$c base url replacements\n\\\"}\" ${sql_file}
    if [[ $? -ne 0 ]]; then
      echo No replacements made in sql. Not restoring. && exit 1
    fi
    php bin/magento maintenance:enable
    mysql ${db_opts} -e 'drop database if exists ${db_name}; 
    create database if not exists ${db_name} default character set utf8;'
    mysql ${db_opts} < ${sql_file}
    php bin/magento maintenance:disable
  "
}

install_local_dev_tools_if_needed() {
  if ! git --version > /dev/null 2>&1; then
    warning Local developer tools are not installed. You will need to accept the agreement from Apple. Initiating install ...
    sudo xcode-select --install || :
    read -p "Continue when the installer has finished. Continue? (y/n): " -n 1 -r < /dev/tty
    if [[ "${REPLY}" =~ ^[Yy]$ ]]; then
      install_local_dev_tools_if_needed # check again
    else
      exit
    fi
  fi
}
install_local_dev_tools_if_needed

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

  # export to env for child git processes only
  export GIT_SSH_COMMAND="ssh -i ${HOME}/.ssh/id_rsa.magento"

else
  
  # if not magento cloud, assume local vm
  identity_file="${HOME}/.ssh/demo-vm-insecure-private-key"
  app_dir="/var/www/magento"

  # verify local vm key exists
  if [[ ! -f "${identity_file}" ]]; then
    curl -o "${identity_file}" "https://raw.githubusercontent.com/PMET-public/magento-cloud-extension/${ext_ver}/sh-scripts/demo-vm-insecure-private-key"
    chmod 600 "${identity_file}"
  fi

fi

ssh_cmd="$(get_ssh_cmd)"
scp_cmd="scp -i ${identity_file}"
