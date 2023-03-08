#!/usr/bin/env bash

err_log="$(mktemp)"
exec 2>> "$err_log"
set -xeE -o pipefail
trap handle_script_err ERR

red='\033[0;31m'
green='\033[0;32m'
yellow='\033[1;33m'
no_color='\033[0m'

handle_script_err() {
  echo "Command $BASH_COMMAND failed with exit code $?.

See $err_log for complete output. 
Copy it to the clipboard with: 
$(msg "  cat $err_log | pbcopy")"

  # use [p] to prevent matching self in log
  if grep -q '[p]ort 22.*timed' $err_log; then
    error "Are you in an Adobe office?
If so, ssh may be blocked. Enable it here: 
$(msg "  https://adobe.service-now.com/sc?id=kb_article&sys_id=3f763f391bd3b41064ef37ff034bcb0d")"
  fi

}

error() {
  printf "\n$red$@$no_color\n\n" && exit 1
}

warning() {
  printf "\n$yellow$@$no_color\n\n"
}

msg() {
  printf "\n$green$@$no_color\n\n"
}

is_mac() {
  # [[ "$(uname)" = "Darwin" ]]
  # matching against uname is relatively slow compared to checking for safari and the users dir
  # and if this funct is called 20x to render the menu, it makes a diff
  [[ -d /Applications/Safari.app && -d /Users ]]
}

decode_URI() {
  # see https://stackoverflow.com/questions/28309728/decode-url-in-bash
  printf "%b\n" "$(sed 's/+/ /g; s/%\([0-9a-f][0-9a-f]\)/\\x\1/gi;')"
}

input_src="/dev/tty"
output_src="/dev/tty"
[[ "$GITHUB_WORKSPACE" ]] && input_src="/dev/stdin" && output_src="/dev/stdout"

cli_required_version="1.42.0"
if [[ "$HOME" == "/app" ]]; then
  error "You are probably attempting to run this command in a cloud env. Commands are intended to be run in a local terminal."
fi

php_version="$(php --version | perl -ne 's/^PHP\s+(\d\.\d).*/\1/ and print')"
php_changed=false
if [[ "$php_version" != "8.1" ]]; then
  if is_mac; then
    php_changed=true
    msg "Upgraded php to v8.1 ..."
    brew unlink php || :
    brew install php@8.1
    brew link php@8.1
  else
    sudo bash -c " apt-get purge php8.*; add-apt-repository --yes ppa:ondrej/php; apt-get update; apt-get install --yes php8.1;"
  fi
fi
cli_path="$HOME/.magento-cloud/bin/magento-cloud"
cli_actual_version=$("$cli_path" --version | perl -pe 's/.*?([\d\.]+)/\1/')
if [[ "$cli_actual_version" != "$cli_required_version" ]]; then
  normal_cli_path="$cli_path"
  cli_path="$cli_path-$cli_required_version"
  if [[ ! -f "$cli_path" ]]; then
    curl -s -o "$cli_path" "https://accounts.magento.cloud/sites/default/files/magento-cloud-v$cli_required_version.phar" ||
      error "Could not retrieve required cli version."
    chmod +x "$cli_path"
  fi
  # edge case when IT moved user's files and magento-cloud-version existed but magento-cloud did not
  if [[ ! -f "$normal_cli_path" ]]; then
    cp "$cli_path" "$normal_cli_path"
  fi
fi

ext_raw_git_url="https://raw.githubusercontent.com/PMET-public/magento-cloud-extension/$ext_ver"

menu_height=20
menu_width=70
num_visible_choices=10
# tab_url_simplified has no trailing "/" but by Magento convention base_url does
tab_url_simplified=$(echo "$tab_url" | perl -pe "s!^(https?://[^/]+).*!\1!")
base_url="$tab_url_simplified/"
domain=$(echo "$tab_url_simplified" | perl -pe "s!https?://!!")
backups_dir="$HOME/Downloads/m2-backups"
sql_file="/tmp/db.sql"
backup_server="zajhc7u663lak-master-7rqtwti@ssh.demo.magento.cloud"
media_files_on_backup_server="/tmp/media-files-on-backup-server"
list_of_all_media_filenames_and_their_md5s_in_orig_env="/tmp/list-of-all-media-filenames-and-their-md5s-in-orig-env"
transfer_list="/tmp/transfer_list"
local_media_files_md5s="/tmp/existing-media-files-md5"
differential_list_of_media_files="/tmp/differential-list-of-media-files"
is_cloud() {
  [[ "$tab_url_simplified" =~ .magento(site)?.cloud ]]
  return $?
}
is_cloud &&
  # var only needed for cloud and causes error when offline (vm use case)
  shared_k=$(
    $cli_path auth:info --format=csv |
    perl -pe 's/,.*//;s/\n//'
  )

# if small terminal, attempt to set a more reasonable terminal size
if [[ $COLUMNS -lt 81 ]]; then
  printf '\e[8;50;120t'
fi

is_cloud() {
  [[ "$tab_url_simplified" =~ .magento(site)?.cloud ]]
  return $?
}

is_local_env() {
  [[ $domain =~ \.(test|local|dev)$ ]]
  return $?
}

if is_cloud; then
  db_host=database.internal
  db_port=3306
  db_user=user
  db_name=main
  db_pass=""
else
  db_host=127.0.0.1
  db_port=3306
  db_user=magento
  db_name=magento
  db_pass="password"
fi
db_opts="-h \"$db_host\" -P \"$db_port\" -u \"$db_user\" --password=\"$db_pass\" \"$db_name\""

get_cloud_base_url() {
  echo "$($cli_path url -p "$1" -e "$2" --pipe | grep https -m 1 | perl -pe 's/\s+//')"
}

get_cloud_ssh_url() {
  echo "$($cli_path ssh -p "$1" -e "$2" --pipe 2> /dev/null || :)"
}

get_ssh_url() {
  # if parameters are passed, use those
  # otherwise determine from env vars
  if [[ $# -eq 2 ]]; then
    get_cloud_ssh_url $*
  elif is_cloud; then  
    get_cloud_ssh_url $project $environment
  else
    echo "vagrant@$domain"
  fi
}

get_cmd_prefix() {
  is_local_env &&
    echo "bash -c" ||
    echo "ssh -n -A $(get_ssh_url $*)"
}

get_interactive_ssh_cmd() {
  echo "ssh -A $(get_ssh_url $*) < $input_src"
}

choose_backup() {
  tar_file_pattern="$1"
  local_tar_files=($(find "$backups_dir" -name "*$tar_file_pattern*.tar" 2> /dev/null | sort -r | perl -pe 's!.*/!!' | cat -n))
  if [[ ${#local_tar_files[@]} -lt 1 ]]; then
    error "No files matching ""*-$tar_file_pattern" found in "$backups_dir"
  fi

  selection=$(dialog --clear \
    --backtitle "Restoring env from backup ..." \
    --title "Your Backup(s)" \
    --menu "Choose a backup file to deploy to $pattern:" \
    $menu_height $menu_width $num_visible_choices "${local_tar_files[@]}" \
    2>&1 >/dev/tty)
  clear > /dev/null
  echo "${local_tar_files[$(( ($selection - 1) * 2 + 1))]}" # account for menu numbering vs array with labels numbering
}

reset_env() {
  msg "Resetting env ..."
  local ssh_url="$1"
  ssh -n "$ssh_url" "
    mysql -h $db_host -e 'drop database if exists $db_name; 
    create database if not exists $db_name default character set utf8;'; 
    # can not remove var/export so or noop cmd (|| :) in case it exists
    rm -rf ~/var/* ~/pub/media/* ~/app/etc/env.php ~/app/etc/config.php || :
  "
}

reindex_env() {
  msg "Reindexing env ..."
  local ssh_url="$1"
  ssh -n "$ssh_url" "
    php $app_dir/bin/magento indexer:reset; php -d memory_limit=-1 $app_dir/bin/magento indexer:reindex
  "
}

reindex_on_schedule() {
  msg "Setting reindex mode to update on schedule ..."
  local ssh_url="$1"
  ssh -n "$ssh_url" "
    php $app_dir/bin/magento indexer:set-mode schedule
  "
}

enable_maintenance_mode() {
  msg "Enabling maintenance mode ..."
  local ssh_url="$1"
  ssh -n "$ssh_url" "
    php bin/magento maintenance:enable
  "
}

disable_maintenance_mode() {
  msg "Disabling maintenance mode ..."
  local ssh_url="$1"
  ssh -n "$ssh_url" "
    php bin/magento maintenance:disable
  "
}

enable_cron() {
  msg "Enabling cron ..."
  local ssh_url="$1"
  ssh -n "$ssh_url" "
    sed -i.bak '/cron.*enabled/d' /app/app/etc/env.php
  "
}

disable_cron() {
  msg "Disabling cron ..."
  local ssh_url="$1"
  ssh -n "$ssh_url" "
    # prevent duplicate lines
    sed -i.bak '/cron.*enabled/d' /app/app/etc/env.php
    # insert disable line
    sed -i.bak '\$i\\\x27cron\x27 => array ( \x27enabled\x27 => 0, ),' /app/app/etc/env.php
  "
}

clean_cache() {
  msg "Cleaning the cache ..."
  local ssh_url="$1"
  ssh -n "$ssh_url" "
    php bin/magento cache:clean
  " 
}

transfer_local_tar_to_remote() {
  msg "Sending tar file ..."
  local ssh_url="$1"
  local local_tar_file="$2"
  scp "$backups_dir/$local_tar_file" $ssh_url:/tmp
}

restore_files_from_tar() {
  msg "Restoring files from tar ..."
  local ssh_url="$1"
  local local_tar_file="$2"
  ssh -n $ssh_url "
    rm -rf \"$app_dir/var/log/*\" \"$app_dir/pub/media/catalog/*\"
    tar -xf /tmp/$local_tar_file -C / --exclude=\"$app_dir/pub/media\" --anchored ${app_dir#'/'} 2> /dev/null || :
  "
}

restore_db_from_tar() {
  msg "Restoring DB from tar ..."
  local ssh_url="$1"
  local local_tar_file="$2"
  ssh -n $ssh_url "
    rm $sql_file 2> /dev/null # if an old file exists from previous attempt
    tar -xf /tmp/$local_tar_file -C / tmp
    gunzip $sql_file.gz
    perl -i -pe \"\\\$c+=s!REPLACEMENT_BASE_URL!$(get_cloud_base_url $project $environment)!g;
      END{ if (\\\$c == 0) {exit 1;} print \\\"\n\\\$c base url replacements\n\\\"}\" $sql_file
    if [[ $? -ne 0 ]]; then
      echo No replacements made in sql. Not restoring. && exit 1
    fi
    mysql $db_opts -e 'drop database if exists $db_name; 
    create database if not exists $db_name default character set utf8;'
    mysql $db_opts < $sql_file
  "
}

restore_media_from_backup_server() {
  msg "Restoring media from backup server ..."
  local ssh_url="$1"
  ssh -n -A $ssh_url "
    rm -rf /app/pub/media/catalog/product/cache/

    # rename any files to their md5 hash and cleanup dirs
    # if you want to skip files already renamed to their md5, use: -regextype posix-extended -not -regex '^/app/pub/media/[a-f0-9]{32}$'
    # but of questionable utility and could skip some media that are not actually files renamed to their md5
    find /app/pub/media -type f -exec md5sum {} \; | \
      perl -pe 's%^(.*?) +(.*)\$%mv \2 /app/pub/media/\1 2>>/tmp/restore.err.log%' | \
      bash
    find /app/pub/media -type d -empty -delete

    # create list of existing media files (now just a list of md5 hashes)
    find /app/pub/media -type f | perl -pe 's/.*\///' > $local_media_files_md5s

    # remove files from list that we already have
    grep -vf $local_media_files_md5s $list_of_all_media_filenames_and_their_md5s_in_orig_env > $differential_list_of_media_files

    # transfer missing media files
    perl -pe 's/ +.*//' $differential_list_of_media_files > $transfer_list
    rsync --files-from=$transfer_list $backup_server:/app/pub/media/ /app/pub/media/ 2>>/tmp/restore.err.log

    # sort then for each md5sum, cp each file and after the last cp of current md5, rm it 
    # run rm as a separate step after all copies or current md5 are complete, so we are less likely to run out of disk space
    sort $list_of_all_media_filenames_and_their_md5s_in_orig_env | \
      perl -pe 's{^(\S+)\s+(.*/)(.*)\$}{(\$prev_match ne \$1 ?
        \"rm /app/pub/media/\$prev_match 2> /dev/null;\n\".(do {\$prev_match=\"\$1\"; eval \"\"})
        : \"\").
        \"mkdir -p \\\"\$2\\\"; cp /app/pub/media/\$1 \\\"\$2\$3\\\";\"}e;END { print \"rm /app/pub/media/\$prev_match;\n\" }' | \
      bash
  "
}

install_local_dev_tools_if_needed() {
  if ! git --version > /dev/null 2>&1; then
    warning "Local developer tools are not installed, or you need to accept the agreement from Apple. Please run this command first:"
    error "sudo xcode-select --install; sudo xcodebuild -license"
  fi
}
install_local_dev_tools_if_needed

start_ssh_agent_and_load_cloud_and_vm_key() {
  if [[ -z "$SSH_AUTH_SOCK" ]]; then
    eval "$(ssh-agent -s)"
  fi

  cloud_key="$HOME/.ssh/id_rsa.magento"
  vm_key="$HOME/.ssh/demo-vm-insecure-private-key"

  # if cloud key does not exist, warn user
  if [[ ! -f "$cloud_key" ]]; then
    warning "Cloud key does not exist. Please check prerequisites. Continuing anyway but some functions may not work."
  fi

  # verify local vm key exists
  if ! grep -q "BEGIN RSA PRIVATE KEY" "$vm_key"; then
    curl -so "$vm_key" "$ext_raw_git_url/sh-scripts/demo-vm-insecure-private-key"
    chmod 600 "$vm_key"
  fi

  if ! ssh-add "$cloud_key" 2> /dev/null; then
    warning "Could not add cloud ssh key."
  fi
  if ! ssh-add "$vm_key" 2> /dev/null; then
    warning "Could not add vm ssh key."
  fi
}
start_ssh_agent_and_load_cloud_and_vm_key

if is_cloud; then

  # determine relevant project and environment
  if [[ "$tab_url" =~ .magento.cloud/projects/.*/environments ]]; then
    project="$(echo "$tab_url" | perl -pe "s!.*?projects/!!;s!/environments/.*!!;")"
    environment="$(echo "$tab_url" | perl -pe "s!.*?environments/!!;s!/.*!!;" | decode_URI)"
    base_url="$(get_cloud_base_url "$project" "$environment")"
  else
    project=$(echo "$tab_url" | perl -pe "s/.*-//;s/\..*//;")
    environments=$("$cli_path" environments -I -p "$project" --pipe)
    environment=""
    modified_env_pattern=$(echo "$tab_url_simplified" | perl -pe 's!https://(.*?)-[^-]+-[^-]+$!\1!')
    for e in $environments; do
      if [[ "$e" = "$modified_env_pattern" ]]; then
        environment="$e"
        break
      fi
    done
    # if we didn't find an env match based on just the url, do a more thorough but time consuming search via the cli
    if [[ -z "$environment" ]]; then
      for e in $environments; do
        if [[ $(get_cloud_base_url "$project" "$e") = "$tab_url_simplified/" ]]; then
          environment="$e"
          break
        fi
      done
    fi
  fi

  if [[ -z "$project" ]]; then
    error "Project not found in your projects or could not be determined from url."
  elif [[ -z "$environment" ]]; then
    error "Environment not found or could not be determined from url."
  fi

  # prevent exit on inactive env but warn
  if [[ -z $(get_ssh_url) ]]; then
    warning "SSH URL could not be determined. Environment inactive?"
  fi

  # export to env for child git processes only
  export GIT_SSH_COMMAND="ssh -i $HOME/.ssh/id_rsa.magento"

fi

is_cloud &&
  app_dir="/app" ||
  {
    is_local_env &&
      app_dir="." ||
      app_dir="/var/www/magento" # vm
  }

cmd_prefix="$(get_cmd_prefix)"
scp_cmd="scp"
