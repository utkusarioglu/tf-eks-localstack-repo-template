#!/bin/bash

source scripts/config.sh || exit 1
check_env
check_repo_config

resources=${1:-$DEFAULT_KUBECTL_WATCH_RESOURCES}

echo "watch '\
  for resource in $resources; do \
    echo \$resource; \
    kubectl get \$resource \
      -A \
      \$(if [ \$resource != \"svc\" ] && [ \$resource != \"ds\" ]; \
      then \
        echo \"-o=wide\"; \
      fi); \
    echo; \
  done\
'" | \
tr -s " " | \
sh
