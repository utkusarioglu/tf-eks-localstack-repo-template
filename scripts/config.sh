#!/bin/bash

REPO_CONFIG_FILE=".repo.config"
PARENT_TEMPLATE_CONFIG_FILE=".parent.config"
GREEN_TEXT="\e[32m"
DEFAULT_TEXT="\e[0m"
RED_TEXT="\e[31m"

source .env 2> /dev/null
source $REPO_CONFIG_FILE

check_env () {
  if [ -z "$ENVIRONMENT" ];
  then
    echo "Warn: \`.env.ENVIRONMENT\` hasn't been set. Using '$DEFAULT_ENVIRONMENT_NAME' for this script."
    ENVIRONMENT=$DEFAULT_ENVIRONMENT_NAME
  fi
}

check_repo_config() {
  if [ ! -f ".repo.config" ];
  then
    echo "Error \`.repo.config\` file is required to configure the scripts' behavior"
    exit 20
  fi

  source .repo.config

}

check_tfvars_in_repo_config() {
  if [ -z "$TF_VARS_MAIN_FILE_NAME" ];
  then
    echo "Error: \`.repo.config.TF_VARS_MAIN_FILE_NAME\` needs to be set for this script to work"
    exit 21
  fi

  if [ ! -f "vars/$TF_VARS_MAIN_FILE_NAME.$ENVIRONMENT.tfvars" ];
  then
    echo "Error: The main tfvars file 'vars/$TF_VARS_MAIN_FILE_NAME.$ENVIRONMENT.tfvars' has to exist for this script to work"
    exit 22
  fi
}

check_repo_template_config() {
  for var in TEMPLATE_REPO_ORIGIN TEMPLATE_REPO_URL TEMPLATE_LAST_COMMIT_EPOCH;
  do
    if [ -z "$var" ];
    then
      echo "Error: \`$file_name.$var\` needs to be set for this script to work"
      exit 21
    fi
  done
}

check_parent_template_config() {
  file_name=$PARENT_TEMPLATE_CONFIG_FILE
  if [ ! -f "$file_name" ];
  then
    echo "Error \`$file_name\` file is required to configure the scripts' behavior"
    exit 20
  fi

  source $file_name

  for var in TEMPLATE_REPO_ORIGIN TEMPLATE_REPO_URL TEMPLATE_LAST_COMMIT_EPOCH;
  do
    if [ -z "$var" ];
    then
      echo "Error: \`$file_name.$var\` needs to be set for this script to work"
      exit 21
    fi
  done
}


check_ingress_file_config() {
  if [ -z "$TF_VARS_INGRESS_FILE_NAME" ];
  then
    echo "Error: `.repo.config.TF_VARS_INGRESS_FILE_NAME` needs to be set for this script to work"
    exit 30
  fi
}


check_repo_update_type() {
  local_repo_url=$(git remote get-url origin)
  REPO_UPDATE_TYPE="none"

  has_parent_config() ( [ -f $PARENT_TEMPLATE_CONFIG_FILE ] )
  has_repo_config() ( [ -f $REPO_CONFIG_FILE ] )
  origin_matches_template_url()[[ "$local_repo_url" == "$TEMPLATE_REPO_URL" ]]
  
  if (! origin_matches_template_url) && has_repo_config; then
    REPO_UPDATE_TYPE="repository"
  fi

  if origin_matches_template_url && has_parent_config; then
    REPO_UPDATE_TYPE="template"
  fi
}

MAIN_VAR_FILE="vars/$TF_VARS_MAIN_FILE_NAME.$ENVIRONMENT.tfvars"
