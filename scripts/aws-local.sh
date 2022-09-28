#!/bin/bash

source scripts/config.sh
check_env

LOCALSTACK_TFVARS="vars/main.localstack.$ENVIRONMENT.tfvars"
localstack_endpoint=$(cat $LOCALSTACK_TFVARS | hclq get 'localstack_endpoint' --raw)

aws-local() {
  aws --endpoint-url=$localstack_endpoint "$@"
}
