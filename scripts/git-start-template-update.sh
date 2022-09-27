#!/bin/bash

source scripts/config.sh
check_repo_config
check_repo_template_config

default_merge_branch=$(git branch --show-current)
update_mode=$1

if [[ "$update_mode" != "repo" ]] && [[ "$update_mode" != "parent" ]];
then
  echo "Error: Update mode can only be \`parent\` or \`repo\`"
  exit 1
fi

if [[ $update_mode == "parent" ]];
then
  check_parent_template_config
fi

local_staging_branch=${3:-"chore/${update_mode}-template-update"}
merge_branch=${4:-$default_merge_branch}
template_ref="$TEMPLATE_REPO_ORIGIN/$TEMPLATE_REPO_BRANCH"

if [ "$@" == "--help" ] || [ "$@" == "-h" ];
then
  cat << EOF
Git template update
template-update.sh [...params]

Params in order (all optional):
  <update_mode>             Required. Sets whether the update is being done
                            from the repo's template or from a parent template.
                            Unless you are updating the template itself, you 
                            want to choose \`repo\`.
  <local_staging_branch>    Local branch to be created for the template update
                            Default: \`chore/<update_mode>-template-update\`
  <merge_branch>            The branch on which the changes shall be staged. 
                            Default: the current branch from which the script 
                            is called, currently: \`$default_merge_branch\`

This script uses '$template_ref' to create a new local branch named
'$local_staging_branch'. Script will terminate when it merges
all template changes on top of local branch '$merge_branch'.

EOF
  exit 0
fi

if [[ $(git branch) == *"$local_staging_branch"* ]];
then
  cat << EOF
Error: There is already a branch named '$local_staging_branch'. 
Either provide a different local branch name or delete the existing branch.
EOF
  exit 2
fi

if [[ $(git branch) != *"$merge_branch"* ]];
then
  cat << EOF
Error: There is no '$merge_branch' branch to merge upon. Please provide a branch that
already exists.
EOF
  exit 3
fi

local_repo_url=$(git remote get-url origin)
if [[ "$local_repo_url" == "$TEMPLATE_REPO_URL" ]]
then
  cat <<EOF
Error: Local repo url is the same as the remote template url. This can mean
that there is a configuration error with the url of '$update_mode'.
EOF
  exit 4
fi

source scripts/git-facades.sh
git_remote_add $TEMPLATE_REPO_ORIGIN $TEMPLATE_REPO_URL

if [[ "$(git remote)" != *"$TEMPLATE_REPO_ORIGIN"* ]];
then
  echo "Error: Remote '$TEMPLATE_REPO_ORIGIN' not found among remotes."
  exit 1
fi

record_target=$REPO_CONFIG_FILE
if [[ "$update_mode" == "parent" ]];
then
  record_target=$PARENT_TEMPLATE_CONFIG_FILE
fi

git checkout -b $local_staging_branch
git fetch $TEMPLATE_REPO_ORIGIN
template_date_human=$(git_last_commit_utc_date $template_ref)
template_date_epoch=$(date -d "$template_date_human" +%s)

merge_response=$(git merge \
  --squash \
  --allow-unrelated-histories \
  --strategy-option theirs \
  $template_ref 2>&1)
git remote remove $TEMPLATE_REPO_ORIGIN 1> /dev/null

if [[ "$merge_response" == *"error"* ]];
then
  git checkout $merge_branch
  git branch -D $local_staging_branch
  echo
  echo "Error: There was a git error during the merging process:"
  echo
  echo "$merge_response"
  echo
  echo "Changes have been reverted. Please restart the process once the error is resolved."
  exit 5
fi

git reset --mixed $merge_branch
git_template_update_record "$record_target" "$template_date_human" "$template_date_epoch"

echo
echo -e "${GREEN_TEXT}Template update started${DEFAULT_TEXT}"
cat <<EOF

Current branch:  $local_staging_branch
Merge branch:    $merge_branch
Template branch: $TEMPLATE_REPO_ORIGIN/$TEMPLATE_REPO_BRANCH
Template url:    $TEMPLATE_REPO_URL
Template date:   $template_date_human

You can now reject the changes that you do not want, and then merge/rebase them 
with '$merge_branch' or any other branch you prefer.

Note that the \`TEMPLATE_LAST_COMMIT_EPOCH\` in \`$record_target\`  now records the 
date of the last commit of the template. You should commit this line if you 
accept any of the changes from the template repo.
EOF
