#!/bin/bash

source scripts/config.sh || exit 1
check_env
check_repo_config
check_tfvars_in_repo_config

mkdir -p {logs,plans,vars}

timestamp=$(date +'%Y-%m-%d-%H-%M-%S')
tf_vars_file_disabled_phrase=${TF_VARS_FILE_DISABLED_PHRASE:-"disabled"}
first_command=$1
tf_commands=$@
additional_params=""

export TF_LOG_PATH="logs/$timestamp.terraform.log" 
export TF_LOG=DEBUG

if [ -z "$tf_commands" ];
then
  echo "Error: The script requires params for the action to run against Terraform"
  echo "Example: \`plan -out=aws.tfplan\`"
  exit 2
fi

if [ "$first_command" == "plan" ];
then
  plan_path="plans/$timestamp.$ENVIRONMENT.tfplan"
  echo "Terraform plan file will be created at: '$plan_path'"
  additional_params="-out=$plan_path"
fi

var_files=$(find vars \
  -type f \( \
    \( -iname "*.tfvars" -or -iname "*.tfvars.json" \) \
    -and \
    \( ! -iname "*.$tf_vars_file_disabled_phrase.*" \) \) \
  -printf '-var-file=vars/%f ')

terraform $tf_commands $var_files $additional_params
