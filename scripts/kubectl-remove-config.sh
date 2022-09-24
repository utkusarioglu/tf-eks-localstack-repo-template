#!/bin/bash

source .scripts.config

check_tfvars

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

cluster_name=$(jq -r '.cluster_name' $TFVARS_FILE_PATH)
echo "Starting removal of $cluster_name resources…"
remove_users $cluster_name
remove_clusters $cluster_name
remove_contexts $cluster_name
kubectl config view
echo "Finished"
