msg Backing up env. Depending on the size, this may take a couple min ...


tmp_git_dir="/tmp/delete-me-${project}-${environment}"

set_db_vars

$ssh_cmd "mysqldump -h \"${db_host}\" -P \"${db_port}\" -u \"${db_user}\" --password=\"${db_pass}\" \"${db_name}\" --single-transaction --no-autocommit --quick > ${sql_file}
  # replace specific host name with token placeholder
  perl -i -pe \"\\\$c+=s!${base_url}!REPLACEMENT_BASE_URL!g; 
    END{print \\\"\n\\\$c host name replacements\n\\\"}\" ${sql_file}
  gzip ${sql_file}

  # add sql file and other files needed to recreate project/environment
  tar --ignore-failed-read -C / -cf ${tar_file} ${sql_file}.gz ${app_dir}/.gitignore ${app_dir}/composer.json ${app_dir}/composer.lock ${additional_files} ${app_dir}/pub/media/gene-cms ${app_dir}/pub/media/wysiwyg ${app_dir}/pub/media/ThemeCustomizer 2> /dev/null
  rm ${sql_file}.gz

  # find full paths of imported images and create tar file
  mysql -sN -h \"${db_host}\" -P \"${db_port}\" -u \"${db_user}\" --password=\"${db_pass}\" \"${db_name}\" -e '# all paths of products added after a certain date
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
    sed 's/^/pub\\/media\\/catalog\\/product/' | \
    tar -rf ${tar_file} --files-from -
"

mkdir -p "${backups_dir}"
$scp_cmd $(get_ssh_url):${tar_file} "${backups_dir}"

if is_cloud; then
  # clean up remote to prevent full disk errors
  $ssh_cmd "rm ${tar_file}"
  # still not done b/c need .magento/services.yml & .magento/routes.yml but they do not exist on the remote cloud filesystem
  # so grab them from the env's repo
  rm -rf "${tmp_git_dir}" # ensure tmp_git_dir doesn't exist from a previously aborted cmd 
  git clone --branch "${environment}" $(${cli_path} project:info -p "${project}" git) "${tmp_git_dir}"
  tar -C "${tmp_git_dir}" -rf "${backups_dir}/${tar_file#/tmp/}" .magento
  rm -rf "${tmp_git_dir}"
fi 
