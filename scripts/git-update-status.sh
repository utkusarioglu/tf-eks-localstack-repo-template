#!/bin/bash

source scripts/config.sh
source scripts/git-check-template-updates.sh
check_env
check_repo_update_type
check_repo_template_updates
check_parent_template_updates

git fetch origin
echo
git status

echo
display_repo_template_updates
display_parent_template_updates
