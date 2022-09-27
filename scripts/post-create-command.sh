#!/bin/bash

terraform init

cd tests && go mod tidy && cd ..

scripts/git-update-status.sh
