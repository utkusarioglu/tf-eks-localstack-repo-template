#!/bin/bash

source scripts/config.sh
check_env
source scripts/localstack-shim.sh

if shim_creation_required $1; then
  create_localstack_shim
  echo
fi

scripts/terraform.sh "$@"

if shim_destruction_required $1; then
  echo
  destroy_localstack_shim
fi
