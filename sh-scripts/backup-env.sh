msg Backing up env. Depending on the size, this may take a couple min ...

tar_file=/tmp/$(date "+%Y-%m-%d-%H-%M")-${project}-${environment}.tar
tmp_git_dir="/tmp/delete-me-${project}-${environment}"
additional_files=""
if is_cloud; then
  additional_files=".magento.app.yaml"
fi

$ssh_cmd "sql_file=\$(php ${home_dir}/bin/magento setup:backup --db | sed -n \"s/.*path: \/app\///p\")

# replace specific host name with token placeholder
perl -i -pe \"\\\$c+=s!${simplified_url}!REPLACEMENT_BASE_URL!g; 
  END{print \\\"\n\\\$c host name replacements\n\\\"}\" \$sql_file

# find full paths of imported images and create tar file
mysql main -sN -h database.internal -e '# all paths of products added after a certain date
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
  tar -cf ${tar_file} --files-from -

# add sql file and other files needed to recreate project/environment
tar --ignore-failed-read -rf ${tar_file} \$sql_file .gitignore composer.json composer.lock ${additional_files} pub/media/gene-cms pub/media/wysiwyg pub/media/ThemeCustomizer 2> /dev/null
rm \$sql_file
"

mkdir -p "${backups_dir}"
$scp_cmd ${user_and_host}:$tar_file "${backups_dir}"

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
