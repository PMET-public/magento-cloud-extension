#!/bin/bash

if [[ -z "$debug" || $debug -eq 1 ]]; then
  set -x
  set -e
fi

[[ -f /tmp/scan-node-over-ssh.sh ]] && /tmp/scan-node-over-ssh.sh -i

red='\033[0;31m'
green='\033[0;32m'
yellow='\033[1;33m'
no_color='\033[0m'
cur_unix_ts=$(date +%s)

is_cloud() {
  test ! -z "$MAGENTO_CLOUD_ROUTES"
  return $?
}

is_cloud &&
  app_dir=/app ||
  app_dir=/var/www/magento

db_host=$(
  env_php_file=$app_dir/app/etc/env.php \
  php -r '$arr=include "$_SERVER[env_php_file]"; echo $arr["db"]["connection"]["default"]["host"];'
)
db_name=$(
  env_php_file=$app_dir/app/etc/env.php \
  php -r '$arr=include "$_SERVER[env_php_file]"; echo $arr["db"]["connection"]["default"]["dbname"];'
)
db_username=$(
  env_php_file=$app_dir/app/etc/env.php \
  php -r '$arr=include "$_SERVER[env_php_file]"; echo $arr["db"]["connection"]["default"]["username"];'
)
db_password=$(
  env_php_file=$app_dir/app/etc/env.php \
  php -r '$arr=include "$_SERVER[env_php_file]"; echo $arr["db"]["connection"]["default"]["password"];'
)

report () {
  printf "${@}" | tee -a /tmp/$cur_unix_ts-report.log
}

get_ee_version() {
  perl -ne 'undef $/; s/[\S\s]*(cloud-metapackage|magento\/product-enterprise-edition)"[\S\s]*?"version": "([^"]*)[\S\s]*/\2/m and print'
}

get_http_response_code() {
  perl -ne 's/^HTTP\/[1-2]\.?1? ([0-9]*).*/\1/ and print'
}

is_cron_enabled() {
  env_php_file=$1 php -r '
    error_reporting(E_ERROR|E_WARNING|E_PARSE);
    $arr=include "$_SERVER[env_php_file]";
    echo !array_key_exists("cron", $arr) || !array_key_exists("enabled", $arr["cron"]) || $arr["cron"]["enabled"] == 1  ? "true" : "false";
  '
}

dedup_msgs() {
  perl -ne '/report.(ERROR|CRITICAL)/ and print' |
    # want to dedup errors but have to ignore timestamps
    # also want the most recent first so have to reverse (tac) before dedup and then reverse again
    tac |
    uniq -s 25 |
    tac |
    tail -5
}

store_url=$(php $app_dir/bin/magento config:show web/unsecure/base_url)
report "\n$green----REPORT FOR $store_url----$no_color\n\n"

# check Magento version
this_ee_composer_version="$(cat $app_dir/composer.lock | get_ee_version)"
public_ee_composer_version="$(curl -s https://raw.githubusercontent.com/magento/magento-cloud/master/composer.lock | get_ee_version)"
test "$this_ee_composer_version" = "$public_ee_composer_version" &&
  report "This env is running the lastest public Magento version: $green$public_ee_composer_version$no_color.\n" ||
  report "This env is not running the lastest public Magento version.
    ${yellow}public: $public_ee_composer_version, env: $this_ee_composer_version.$no_color\n"

# check for unfinished maintenance 
cd $app_dir/var
test -f .maintenance.flag &&
  report "$red.maintenance.flag found. Removing ...$no_color\n" &&
  rm .maintenance.flag ||
  report 'No maintenance flag found.\n'

# check for failed deploy
test -f .deploy_is_failed &&
  report "$red.deploy_is_failed found. Removing ...$no_color\n" &&
  rm .deploy_is_failed &&
  report "Attempting 'php bin/magento setup:upgrade' ... ${yellow}This may take a few minutes.$no_color\n" &&
  {
    cd ${app_dir}
    php bin/magento setup:upgrade > /dev/null 2>&1
    report 'Tailing relevant end of install_upgrade.log:\n' &&
      cat ${app_dir}/var/log/install_upgrade.log |
      perl -pe 's/\e\[\d+(?>(;\d+)*)m//g;' |
      grep -v '^Module ' |
      grep -v '^Running schema' |
      perl -pe 's/^/\t/' |
      tail
    # reset cur timestamp b/c upgrade may have taken awhile
    cur_unix_ts=$(date +%s)
  } ||
  report 'No failed deploy flag found.\n'

# check for undeployed static content
cd $app_dir
test $(find pub/static -type f -name '*.css' | wc -l) -gt 1 &&
  report "Static files found.\n" ||
  {
    report "${red}Static files missing.$no_color Generating ... ${yellow}This may take a few minutes.$no_color\n"
    php bin/magento setup:static-content:deploy > /dev/null 2>&1
    report "Done.\n"
  } 


# check for unusual HTTP responses
localhost_http_status=$(curl -sI localhost | get_http_response_code)
test $localhost_http_status -ne 302 &&
  report "Localhost HTTP response should be 302 is $red$localhost_http_status$no_color\n" ||
  report 'Localhost HTTP response is normal (302)\n'
curl -I $store_url 2>&1 | grep -q 'certificate problem' && 
  report "${red}Certificate problem.$no_color\n"
remote_public_http_status=$(curl -skI $store_url | get_http_response_code)
test $remote_public_http_status -eq 200 &&
  report "Public HTTP response is normal ($remote_public_http_status)\n" ||
  report "Public HTTP response should be 200 is $red$remote_public_http_status$no_color\n"

# occassionally the db base url != the env url (cloning data, other changes, etc.)
is_cloud &&
  {
    route_url=$(echo "$MAGENTO_CLOUD_ROUTES" | base64 -d - | perl -pe 's#^{"(https?://[^"]+).*#\1#')
    # only compare string after https?://
    test "$(echo $store_url | perl -pe 's#https?://##')" = "$(echo $route_url | perl -pe 's#https?://##')" ||
      report "${red}Route url ($route_url) is different than configured store url ($store_url)$no_color\n"
  }

# check cron
cd $app_dir
env_file_old=$app_dir/app/etc/env.php
env_file_new=/tmp/env.php.$cur_unix_ts
test $(is_cron_enabled $env_file_old) = "true" ||
  { 
    report "${red}Cron disabled.$no_color Attempting fix ... " &&
      cp $env_file_old $env_file_new &&
      perl -i -p00e "s/'enabled'\s*=>\s*0/'enabled' => 1/" $env_file_new &&
      test "$(is_cron_enabled $env_file_new)" = "true" &&
      { 
        mv $env_file_new $env_file_old
        report "cron ${green}fixed$no_color. Running cron ...\n"
        php bin/magento cron:run > /dev/null
      } ||
      exit "Enabling cron via regex failed."
  }
is_cloud &&
  cron_file=/var/log/cron.log ||
  cron_file=/var/www/magento/var/log/magento.cron.log
last_cron=$(grep -a -A2 '^\[.*Launching command' $cron_file | tail -3 | tr '\n' ' ')
last_cron_ts=$(date -d "$(echo $last_cron | perl -pe 's/^.([^\.\]]+).*$/\1/')" +%s)
min_since_last_cron=$(( (cur_unix_ts - last_cron_ts) / 60 ))
report 'Last cron '
echo $last_cron | grep -q 'Ran jobs by' &&
  report "${green}succeeded " ||
  report "${red}failed "
test $min_since_last_cron -lt 10 &&
  report "$green"
report "$min_since_last_cron$no_color minutes ago.\n"

# check load avg
read -r nproc loadavg1 loadavg5 < <(echo $(nproc) $(awk "{print \$1, \$2}" /proc/loadavg))
load1=$(awk "BEGIN {printf \"%.f\", $loadavg1 * 100 / $nproc}")
load5=$(awk "BEGIN {printf \"%.f\", $loadavg5 * 100 / $nproc}")
test $load1 -gt 99 && 
  color="$red" || 
  {
    test $load1 -gt 89 && 
      color="$yellow" || 
      color="$green"
  }
report "The past 1 min load for this host: $color$load1%%$no_color\n"
report "The past 5 min load for this host: $color$load5%%$no_color\n"
report "Host has $nproc cpus.\n"

# check indexes
invalid_index_count=$(
  mysql $db_name -sN -h $db_host -u $db_username --password="$db_password" \
    -e 'SELECT COUNT(*) FROM indexer_state WHERE status != "valid";' 2> /dev/null
)
test $invalid_index_count -gt 0 &&
  {
    printf "$red$invalid_index_count$no_color invalid indexes found.\n"
    cd $app_dir
    php bin/magento indexer:reset
    php bin/magento indexer:reindex
  }

# last admin login
last_admin_login=$(
  mysql $db_name -sN -h $db_host -u $db_username --password="$db_password" \
    -e 'SELECT UNIX_TIMESTAMP(logdate) FROM admin_user 
      WHERE username != "sionly" ORDER BY logdate DESC limit 1;' 2> /dev/null
)
[[ ! -z "$last_admin_login" && "$last_admin_login" != "NULL" ]] &&
  {
    hr_since_last_admin_login=$(( (cur_unix_ts - last_admin_login) / 3600 ))
    days_since_last_admin_login=$(( (cur_unix_ts - last_admin_login) / 86400 ))
    last_msg=$(
      test $days_since_last_admin_login -gt 30 && 
        echo "$yellow$days_since_last_admin_login$no_color days ago" ||
        {
          test $days_since_last_admin_login -gt 1 &&
            echo "$days_since_last_admin_login days ago" ||
            echo "$hr_since_last_admin_login hrs ago"
        }
    )
    report "Last admin login $last_msg.\n"
  } ||
  report "${yellow}No admin logins found.$no_color\n"

# last customer login
last_customer_login=$(
  mysql $db_name -sN -h $db_host -u $db_username --password="$db_password" \
    -e 'SELECT UNIX_TIMESTAMP(last_login_at) FROM customer_log 
      ORDER BY last_login_at DESC limit 1;' 2> /dev/null
)
[[ ! -z "$last_customer_login" && "$last_customer_login" != "NULL" ]] &&
  {
    hr_since_last_customer_login=$(( (cur_unix_ts - last_customer_login) / 3600 ))
    days_since_last_customer_login=$(( (cur_unix_ts - last_customer_login) / 86400 ))
    last_msg=$(
      test $days_since_last_customer_login -gt 30 && 
        echo "$yellow$days_since_last_customer_login$no_color days ago" ||
        {
          test $days_since_last_customer_login -gt 1 &&
            echo "$days_since_last_customer_login days ago" ||
            echo "$hr_since_last_customer_login hrs ago"
        }
    )
    report "Last customer login $last_msg.\n"
  } ||
  report "${yellow}No customer logins found.$no_color\n"

# var/report
cd $app_dir/var/report 2> /dev/null &&
  {
    last_var_report=$(ls -tr | tail -1)
    last_var_report_mtime=$(date -d "$(stat -c %x $last_var_report)")
    last_var_report_contents=$(perl -pe 's/\\n/\n/g;s/<pre>/<pre>\n/;s/\n(#[0-9]+)/\n  \1/g' $last_var_report)
    report "\n----Most recent ${yellow}var/report$no_color from $last_var_report_mtime: ---------\n"
    report "$last_var_report_contents"
    report '\n-----------------------------------------------------------------------\n\n'
  } ||
  report "${green}No reports in var/report.$no_color\n"

# exception.log
cd $app_dir/var/log
recent_exceptions=$(cat exception.log | dedup_msgs)
test ! -z "$recent_exceptions" &&
  {
    report "\n----Some CRITICAL/ERROR msgs in ${yellow}exception.log$no_color (skip repeats): ---------\n"
    report "$recent_exceptions"
    report '\n-----------------------------------------------------------------------\n\n'
  } ||
  report "${green}No CRITICAL or ERROR msgs in exception.log.$no_color\n"

# support_report.log
cd $app_dir/var/log

# truncate log files by removing generally unhelpful lines
for i in support_report.log cron.log cache.log; do
  file="$(mktemp)"
  sed '/ report.INFO: \| main.DEBUG: /d' "$i" > "$file"
  mv "$file" "$i"
done

recent_support_reports=$(cat support_report.log | dedup_msgs)
test ! -z "$recent_support_reports" &&
  {
    report "\n----Some CRITICAL/ERROR msgs in ${yellow}support_report.log$no_color (skip repeats): ----\n"
    report "$recent_support_reports"
    report '\n-----------------------------------------------------------------------\n\n'
  } ||
  report "${green}No CRITICAL or ERROR msgs in support_report.log.$no_color\n"

# recent http access (excluding go client from mcm, curl, wget)
is_cloud &&
  log_files=/var/log/access.log ||
  log_files=/var/log/nginx/access.log
for lf in $log_files; do
  recent_access=$(
    cat $lf |
    perl -ne '!/ "Go-http-client/ and !/ "curl\// and !/ "wget/i and /HTTP\/[1-2]\.?\d?"? 200/ and print' |
    # limiting uniq to 1st 16 chars should give 1 result per ip
    uniq -w 16 |
    tail -5
  )
  test ! -z "$recent_access" &&
  {
    report "\n---------------Recent ${green}normal$no_color HTTP responses in $lf-------------\n"
    report "$recent_access"
    report '\n-----------------------------------------------------------------------\n\n'
  } ||
  report "${yellow}No recent visits in $lf.$no_color\n"
done

# recent http access (excluding go client from mcm, curl, wget)
is_cloud &&
  log_files=/var/log/access.log ||
  log_files="/var/log/nginx/access.log /var/log/nginx/error.log"
for lf in $log_files; do
  recent_access=$(
    cat $lf |
    perl -ne '!/ "Go-http-client/ and !/ "curl\// and !/ "wget/i and !/HTTP\/[1-2]\.?\d?"? [2-3][0-9]{2}/ and print' |
    tail -5
  )
  test ! -z "$recent_access" &&
  {
    report "\n-----------Recent ${yellow}bad$no_color HTTP responses in $lf-------------\n"
    report "$recent_access"
    report '\n-----------------------------------------------------------------------\n\n'
  } ||
  report "${green}No recent errors in $lf.$no_color\n"
done
