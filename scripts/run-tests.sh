#!/bin/bash

echo "Starting Terratest…"
mkdir -p logs
cd tests && go test -timeout 90m && cd ..
