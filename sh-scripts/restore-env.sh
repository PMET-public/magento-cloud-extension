# shellcheck shell=bash
: || source lib.sh # trick shellcheck into finding certain referenced vars

msg "No longer supported. Please use the cloud native snapshot and restore or MDM."
exit

if is_cloud; then
  local_tar_file=$(choose_backup "$project-$environment") || exit 1 
else
  local_tar_file=$(choose_backup "${domain}") || exit 1
fi

ssh_url=$(get_ssh_url)

disable_cron "$ssh_url"
transfer_local_tar_to_remote "$ssh_url" "${local_tar_file}"
restore_db_from_tar "$ssh_url" "${local_tar_file}"
restore_files_from_tar "$ssh_url" "${local_tar_file}"
restore_media_from_backup_server "$ssh_url"
enable_cron "$ssh_url"
