#!/bin/bash

source scripts/config.sh || exit 1
check_env
check_repo_config

remove_users() {
  cluster_name=$1
  user_arns=$(\
    kubectl config view -o=json | \
    jq -r -c \
      '.users[]? | select(.name | endswith("'$cluster_name'")) | .name'\
  )
  for user_arn in $user_arns;
  do
    echo "Deleting user: $user_arn"
    kubectl config delete-user $user_arn
  done
  echo
}

remove_clusters() {
  cluster_name=$1
  cluster_arns=$(\
    kubectl config view -o=json | 
    jq -r -c \
      '.clusters[]? | select(.name | endswith("'$cluster_name'")) | .name'\
  )
  for cluster_arn in $cluster_arns;
  do
    echo "Deleting cluster: $cluster_arn"
    kubectl config delete-cluster $cluster_arn
  done
  echo 
}

remove_contexts() {
  cluster_name=$1
  kubectl config use-context docker-desktop 

  context_names=$(\
    kubectl config view -o=json | \
    jq -r -c \
      '.contexts[]? | select(.name | startswith("'$cluster_name'")) | .name'\
  )
  echo context_names: $context_names
  for context_name in $context_names;
  do
    echo "Deleting context: $context_name"
    kubectl config delete-context $context_name
  done
  echo
}

var_file="vars/$TF_VARS_MAIN_FILE_NAME.$ENVIRONMENT.tfvars"
cluster_name=$(cat $var_file | hclq get 'cluster_name' --raw)

echo "Starting removal of $cluster_name resources…"
remove_users $cluster_name
remove_clusters $cluster_name
remove_contexts $cluster_name
kubectl config view
echo "Finished"
