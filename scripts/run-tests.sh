#!/bin/bash

source scripts/config.sh
check_env
source scripts/localstack-shim.sh

mkdir -p logs

create_localstack_shim
echo

echo "Starting Terratestâ€¦"
cd tests && go test -timeout 90m && cd ..

echo
destroy_localstack_shim
