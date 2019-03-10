msg Backing up env. Depending on the size, this may take a couple min ...


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

  # add sql file and other files needed to recreate project/environment
  tar --ignore-failed-read -C / -cf ${remote_tar_file} ${sql_file}.gz \
    --exclude="${app_dir}/pub/media/catalog/product/cache" \
    ${app_dir}/auth.json \
    ${app_dir}/.gitignore \
    ${app_dir}/composer.json \
    ${app_dir}/composer.lock \
    ${app_dir}/app/etc/env.php \
    ${app_dir}/app/etc/config.php \
    ${app_dir}/m2-hotfixes \
    ${additional_files} \
    ${app_dir}/pub/media/gene-cms \
    ${app_dir}/pub/media/wysiwyg \
    ${app_dir}/pub/media/ThemeCustomizer \
    ${app_dir}/pub/media/catalog/product \
    2> /dev/null
  rm ${sql_file}.gz

  # find full paths of imported images and create tar file
  mysql -sN ${db_opts} -e '# all paths of products added after a certain date
      select cpemg.value from 
        catalog_product_entity cpe, 
        catalog_product_entity_media_gallery cpemg, 
        catalog_product_entity_media_gallery_value_to_entity cpemgvte
      where 
        cpemgvte.row_id = cpe.row_id AND
        cpemgvte.value_id = cpemg.value_id AND
        updated_at > 
      # find date of first product plus 30 min
      (select date_add(min(updated_at), interval 30 minute) from 
        catalog_product_entity cpe, 
        catalog_product_entity_media_gallery cpemg, 
        catalog_product_entity_media_gallery_value_to_entity cpemgvte
      where 
        cpemgvte.row_id = cpe.row_id AND
        cpemgvte.value_id = cpemg.value_id
      order by updated_at asc)' 2> /dev/null | \
    perl -pe 's!^!pub/media/catalog/product!' | \
    tar -rf ${remote_tar_file} --files-from -
"

mkdir -p "${backups_dir}"
$scp_cmd $(get_ssh_url):${remote_tar_file} "${backups_dir}"

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
