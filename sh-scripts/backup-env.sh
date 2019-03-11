msg Backing up env. Depending on the size, this may take a couple min ...

backup_server="zajhc7u663lak-master-7rqtwti@ssh.demo.magento.cloud"
already_backed_up_list="/tmp/media-files-on-backup-server"
all_media_files_plus_md5_list="/tmp/media-files"
potential_backup_list="/tmp/potential-media-files-to-send"
differential_list="/tmp/media-files-to-send"
tmp_git_dir="/tmp/delete-me-${project}-${environment}"

set_db_vars

if is_cloud; then
    additional_files="${app_dir}/.magento.app.yaml"
    remote_tar_file="/tmp/$(date "+%Y-%m-%d-%H-%M")-${project}-${environment}.tar"
else
    additional_files=""
    remote_tar_file="/tmp/$(date "+%Y-%m-%d-%H-%M")-${domain}.tar"
fi

$ssh_cmd "mysqldump ${db_opts} --single-transaction --no-autocommit --quick > ${sql_file}
  # replace specific host name with token placeholder
  perl -i -pe \"\\\$c+=s!${base_url}!REPLACEMENT_BASE_URL!g; 
    END{print \\\"\n\\\$c base_url replacements\n\\\"}\" ${sql_file}
  gzip ${sql_file}

  # catalog all local media files
  find ${app_dir}/pub/media -type f -not -path '${app_dir}/pub/media/catalog/product/cache/*' \
    -exec md5sum \{} \; > ${all_media_files_plus_md5_list}
  
  # remove duplicates by md5 and create potential list to send to backup server
  sort | uniq -w 32 > ${potential_backup_list}
  
  # fetch list of media already on backup server
  ssh ${backup_server} 'find ${app_dir}/pub/media -type f -exec basename \{} \;' 2>/dev/null > ${already_backed_up_list}
  
  # calculate differential backup
  grep -vf ${already_backed_up_list} ${potential_backup_list} > ${differential_list}

  # transfer differential backup
  perl -pe 's!.*?/pub/media/!!' ${differential_list} | \
    rsync --stats --files-from=- ${app_dir}/pub/media "${backup_server}:/app/pub/media/${pid}-${env}"

  # rename files with md5 and cleanup dirs on backup server
  perl -pe \"END { print 'find /app/pub/media -type d -empty -delete' } \
    s%^(.*?) +.*?/pub/media/(.*)$%mv /app/pub/media/${pid}-${env}/\2 /app/pub/media/\1%\" /tmp/media-files-to-send | \
    ssh ${backup_server} 'cat - | bash' 2> /dev/null

  # add sql file, media files list, and other files needed to recreate project/environment
  tar --ignore-failed-read -C / -cf ${remote_tar_file} ${sql_file}.gz \
    ${all_media_files_plus_md5_list} \
    ${app_dir}/auth.json \
    ${app_dir}/.gitignore \
    ${app_dir}/composer.json \
    ${app_dir}/composer.lock \
    ${app_dir}/app/etc/env.php \
    ${app_dir}/app/etc/config.php \
    ${app_dir}/m2-hotfixes \
    ${additional_files} \
    2> /dev/null
  rm ${sql_file}.gz
"

mkdir -p "${backups_dir}"
scp $(get_ssh_url):${remote_tar_file} "${backups_dir}"

if is_cloud; then
  # clean up remote to prevent full disk errors
  $ssh_cmd "rm ${remote_tar_file}"
  # still not done b/c need .magento/services.yml & .magento/routes.yml but they do not exist on the remote cloud filesystem
  # so grab them from the env's repo
  rm -rf "${tmp_git_dir}" # ensure tmp_git_dir doesn't exist from a previously aborted cmd 
  git clone --branch "${environment}" $(${cli_path} project:info -p "${project}" git) "${tmp_git_dir}${app_dir}"
  tar -C "${tmp_git_dir}" -rf "${backups_dir}/${remote_tar_file#/tmp/}" "${app_dir#'/'}/.magento"
  rm -rf "${tmp_git_dir}"
fi 
