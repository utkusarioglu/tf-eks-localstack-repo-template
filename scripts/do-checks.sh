#!/bin/bash

source .scripts.config

check_tfvars() {
  if [ -z $TFVARS_FILE_PATH ];
  then
    echo ".scripts.config file needs to define the \$TFVARS_FILE_PATH for this script to work."
    exit 13
  fi
}
