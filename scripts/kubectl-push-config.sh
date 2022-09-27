#!/bin/bash

source scripts/config.sh || exit 1
check_env
check_repo_config

cluster_name=$(cat $MAIN_VAR_FILE | hclq get 'cluster_name' --raw)
cluster_region=$(cat $MAIN_VAR_FILE | hclq get 'cluster_region' --raw)
aws_profile=$(cat $MAIN_VAR_FILE | hclq get 'aws_profile' --raw)

aws eks update-kubeconfig \
 --region $cluster_region \
 --profile $aws_profile \
 --name $cluster_name \
 --alias "$cluster_name-$cluster_region"
