#!/bin/bash

source scripts/do-checks.sh
source .scripts.config

check_tfvars

cluster=$(jq '.cluster_name' $TFVARS_FILE_PATH -r)
aws_region=$(jq '.aws_region' $TFVARS_FILE_PATH -r)

aws eks update-kubeconfig \
 --name $cluster \
 --alias "$cluster-$aws_region" \
 --region $aws_region \
 --profile default
