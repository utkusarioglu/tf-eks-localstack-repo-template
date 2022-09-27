source scripts/config.sh
source scripts/git-facades.sh

check_template_updates() {
  template_repo_origin=$1
  template_repo_branch=$2
  template_repo_url=$3
  template_last_commit_epoch=$4
  template_repo_ref=$template_repo_origin/$template_repo_branch

  if [[ "$(git remote)" != *"$template_repo_origin"* ]];
  then
    git_remote_add $template_repo_origin $template_repo_url
  fi

  git fetch $template_repo_origin > /dev/null
  template_date_human=$(git_last_commit_utc_date $template_repo_ref)
  template_date_epoch=$(date -d "$template_date_human" +%s)
  
  local_repo_url=$(git remote get-url origin)
  if [[ "$local_repo_url" != "$template_repo_url" ]] && \
     [ "$template_last_commit_epoch" -lt "$template_date_epoch" ];
  then
    diff=$(git diff HEAD $template_repo_ref)
    if [ -z "$diff" ];
    then
      echo "$template_repo_origin has a faulty record"
      git_template_update_record "$template_date_human" "$template_date_epoch"
    else
      echo "$template_repo_origin has an update"
    fi
  fi

  git remote remove $template_repo_origin 1> /dev/null
}

check_config_attributes() {
  pretty_name=$1
  config_file=$2
  if [ -f "$config_file" ];
  then
    source $config_file
    echo "$pretty_name config file found at '$config_file'"
    for attribute in TEMPLATE_REPO_ORIGIN \
      TEMPLATE_REPO_BRANCH \
      TEMPLATE_REPO_URL \
      TEMPLATE_LAST_COMMIT_EPOCH;
    do
      if [ -z "${!attribute}" ];
      then
        echo "Error: '$config_file.$attribute' is missing. Unable to check for $pretty_name template updates."
        exit 100
      fi
    done
  else 
    echo "Warn: '$config_file' unavailable. $pretty_name template updates will not be checked."
  fi
}

check_repo_template_updates() {
  if [[ $REPO_UPDATE_TYPE == "repository" ]];
  then
    repo_config_response=$(check_config_attributes "Repo" "$REPO_CONFIG_FILE")
    if [[ "$repo_config_response" != *"Error"* ]];
    then
      source $REPO_CONFIG_FILE
      repo_template_status=$(check_template_updates \
        $TEMPLATE_REPO_ORIGIN \
        $TEMPLATE_REPO_BRANCH \
        $TEMPLATE_REPO_URL \
        $TEMPLATE_LAST_COMMIT_EPOCH \
      )
    else
      echo "$repo_config_response"
    fi
  else
    echo "Info: Skipping repo template update check, this repo isn't eligible."
  fi
}

check_parent_template_updates() {
  if [[ $REPO_UPDATE_TYPE == "template" ]];
  then
    config_response=$(check_config_attributes "Parent" "$PARENT_TEMPLATE_CONFIG_FILE")
    if [[ "$config_response" != *"Error"* ]] && [[ "$config_response" != *"Warn"* ]]
    then
      source $PARENT_TEMPLATE_CONFIG_FILE
      parent_template_status=$(check_template_updates \
        $TEMPLATE_REPO_ORIGIN \
        $TEMPLATE_REPO_BRANCH \
        $TEMPLATE_REPO_URL \
        $TEMPLATE_LAST_COMMIT_EPOCH \
      )
    else
      echo "$config_response" 
    fi
  else
    echo "Info: Skipping parent template update check, this repo isn't eligible."
  fi
}

display_repo_template_updates() {
  if [[ "$repo_template_status" == *"has an update"* ]]
  then
    echo -e "${GREEN_TEXT}You have a repo template update!${DEFAULT_TEXT}"
    echo "To start, run \`scripts/git-start-template-update.sh repo\`"
    echo
  fi

  if [[ "$repo_template_status" == *"has a faulty record"* ]]
  then
    echo -e "${RED_TEXT}Outdated repo template record${DEFAULT_TEXT}"
    cat <<EOF

In order to correct the error, config file '$REPO_CONFIG_FILE.TEMPLATE_LAST_COMMIT_EPOCH'
has been altered with a value that will resolve the issue. 
Please commit this file.
EOF
    echo
  fi
}

display_parent_template_updates() {
  if [[ "$parent_template_status" == *"has an update"* ]]
  then
    echo -e "${GREEN_TEXT}You have a parent template update!${DEFAULT_TEXT}"
    echo "To start, run \`scripts/git-start-template-update.sh parent\`"
    echo
  fi

  if [[ "$parent_template_status" == *"has a faulty record"* ]]
  then
    echo -e "${RED_TEXT}Outdated parent template record${DEFAULT_TEXT}"
    cat <<EOF

In order to correct the error, config file '$PARENT_TEMPLATE_CONFIG_FILE.TEMPLATE_LAST_COMMIT_EPOCH'
has been altered with a value that will resolve the issue. 
Please commit this file.
EOF
    echo
  fi
}
