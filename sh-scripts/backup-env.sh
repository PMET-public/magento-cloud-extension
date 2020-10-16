msg "Backing up env. Depending on the size, this may take a couple minutes ..."

tmp_git_dir="/tmp/delete-me-${domain}"

if is_cloud; then
    additional_files="${app_dir}/.magento.app.yaml"
    remote_tar_file="/tmp/$(date "+%m-%d-%H-%M")-${project}-${environment}.tar"
else
    additional_files=""
    remote_tar_file="/tmp/$(date "+%m-%d-%H-%M")-${domain}.tar"
fi
local_backup_file="${backups_dir}/${remote_tar_file#/tmp/}"

$cmd_prefix "
  mysqldump ${db_opts} --single-transaction --no-autocommit --quick > ${sql_file}
  # replace specific host name with token placeholder
  perl -i -pe \"\\\$c+=s!${base_url}!REPLACEMENT_BASE_URL!g; 
    END{print \\\"\n\\\$c base_url replacements\n\\\"}\" ${sql_file}
  # rm old if not cleaned up from last run, gzip, and rm sql file
  rm ${sql_file}.gz 2> /dev/null || : 
  gzip ${sql_file}

  # catalog all local media files
  find ${app_dir}/pub/media -type f -not -path '${app_dir}/pub/media/catalog/product/cache/*' \
    -exec md5sum \{} \; > ${list_of_all_media_filenames_and_their_md5s_in_orig_env}
  
  # remove duplicates by md5 and create potential list to send to backup server
  sort ${list_of_all_media_filenames_and_their_md5s_in_orig_env} | uniq -w 32 > ${transfer_list}
  
  # fetch list of media already on backup server
  ssh ${backup_server} 'find ${app_dir}/pub/media -type f -exec basename \{} \;' 2> /dev/null > ${media_files_on_backup_server}
  
  # calculate differential backup
  grep -vf ${media_files_on_backup_server} ${transfer_list} > ${differential_list_of_media_files}

  # transfer differential backup
  perl -pe 's!.*?/pub/media/!!' ${differential_list_of_media_files} | \
    rsync --stats --files-from=- ${app_dir}/pub/media \"${backup_server}:/app/pub/media/${pid}-${env}\"

  # on backup server, rename any files by md5 hash and cleanup dirs
  ssh ${backup_server} \"
    find /app/pub/media -type f -regextype posix-extended -not -regex '^/app/pub/media/[a-f0-9]{32}$' -exec md5sum {} \; | \
      perl -pe 's%^(.*?) +(.*)$%mv \2 /app/pub/media/\1%' | \
      bash
    find /app/pub/media -type d -empty -delete
  \" 2> /dev/null

  # add sql file, media files list, and other files needed to recreate project/environment
  tar --ignore-failed-read -C / -cf ${remote_tar_file} ${sql_file}.gz \
    ${list_of_all_media_filenames_and_their_md5s_in_orig_env} \
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
  $cmd_prefix "rm ${remote_tar_file}"
  # still not done b/c need .magento/services.yml & .magento/routes.yml but they do not exist on the remote cloud filesystem
  # so grab them from the env's repo
  rm -rf "${tmp_git_dir}" # ensure tmp_git_dir doesn't exist from a previously aborted cmd 
  git clone --branch "${environment}" $(${cli_path} project:info -p "${project}" git) "${tmp_git_dir}${app_dir}"
  tar -C "${tmp_git_dir}" -rf "${backups_dir}/${remote_tar_file#/tmp/}" "${app_dir#'/'}/.magento"
  rm -rf "${tmp_git_dir}"
fi

msg "Backup saved to ${local_backup_file}"
