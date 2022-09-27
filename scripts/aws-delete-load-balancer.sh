#!/bin/bash

source scripts/config.sh || exit 1
check_env
check_repo_config
check_ingress_file_config

lb_name=$(cat $MAIN_VAR_FILE | hclq get 'cluster_name' --raw)
cluster_name=$(cat $MAIN_VAR_FILE | hclq get 'cluster_name' --raw)
cluster_region=$(cat $MAIN_VAR_FILE | hclq get 'cluster_region' --raw)
project_name=$(cat $MAIN_VAR_FILE | hclq get 'project_name' --raw)
aws_profile=$(cat $MAIN_VAR_FILE | hclq get 'aws_profile' --raw)

echo "Starting removal of lb '$lb_name' in \
'$cluster_name.$project_name.$cluster_region' using aws profile \
'$aws_profile'"

echo "Getting arn for '$lb_name'…"
lb_arn=$(aws elbv2 describe-load-balancers \
  --name $lb_name \
  --profile $aws_profile \
  --region $cluster_region \
  --output json | \
  jq --raw-output '.LoadBalancers[0].LoadBalancerArn')


if [ -z "$lb_arn" ];
then
  exit
fi
echo "Retrieved arn '$lb_arn'"

echo "Removing alb '$lb_name'…"
aws elbv2 delete-load-balancer \
  --region $cluster_region \
  --profile $aws_profile \
  --load-balancer-arn $lb_arn \
