#!/bin/bash

source scripts/config.sh
check_env
source scripts/localstack-shim.sh

mkdir -p logs

echo "Starting Terratest…"
create_localstack_shim
echo

cd tests && go test -timeout 90m && cd ..

echo
destroy_localstack_shim
