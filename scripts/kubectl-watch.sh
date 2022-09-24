#!/bin/sh

DEFAULT_RESOURCES="ns po svc ing ds no"

resources=${1:-$DEFAULT_RESOURCES}

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
