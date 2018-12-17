msg Restoring env from backup ...

# prompt user for tar file and project to create new env on

set_db_vars

if is_cloud; then
  local_tar_file=$(choose_backup "${project}-${environment}") || exit 1 
else
  local_tar_file=$(choose_backup "${domain}") || exit 1
fi

restore_db_from_tar "${local_tar_file}" "${project}" "${environment}"
restore_files_from_tar "${local_tar_file}" "${project}" "${environment}"
