git_remote_add() {
  template_repo_origin=$1
  template_repo_url=$2

  # This next line is not silenced
  git remote add $template_repo_origin $template_repo_url --no-tags > /dev/null
  git remote set-url --push $template_repo_origin not-allowed > /dev/null
}

git_template_update_record() {
  record_target=$1
  template_date_human=$2
  template_date_epoch=$3
  if [ ! -f $record_target ];
  then
    touch $record_target
  else
    sed -i '/TEMPLATE_LAST_COMMIT_EPOCH/d' $record_target 
  fi
  echo "TEMPLATE_LAST_COMMIT_EPOCH=$template_date_epoch # $template_date_human" >> $record_target
}

git_last_commit_utc_date() {
  repo_ref=$1
  TZ=UTC0 git log "$repo_ref" -1 --format=%cd --date=format:'%Y-%m-%d %H:%M:%S'
}
