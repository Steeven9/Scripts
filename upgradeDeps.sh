#!/usr/bin/env bash
set -euo pipefail

# usage:
# ./upgradeDeps.sh
#
# Runs 'yarn upgrade' in all the repos,
# then commits and pushes the changes

# projects home
GIT_HOME="$HOME/projects"
# folders to exclude from the pull (full path, e.g. "$GIT_HOME/Scripts")
EXCLUDE_DIRS=("")
# message used in the commit
commit_message="[chore] Upgrade deps"

for dir in "${GIT_HOME}"/*; do
  if [[ " ${EXCLUDE_DIRS[*]} " =~ " ${dir} " ]]; then
    echo "* Skipping ${dir} due to ignore list... *"
    echo "-----------"
    continue
  fi

  if [[ ! -f "${dir}/yarn.lock" ]]; then
    echo "* Skipping ${dir}, not a Yarn repo... *"
    echo "-----------"
    continue
  fi

  echo "* Updating ${dir}... *"
  cd "${dir}"

  if [[ -n $(git status --short | grep -v "^??") ]]; then
    git stash
    stashed=true
  fi

  git pull

  yarn upgrade
  yarn build
  yarn audit

  git commit -am "${commit_message}"
  git push

  if [[ $stashed == true ]]; then
    git stash pop
  fi

  cd "${GIT_HOME}"
  echo "-----------"
done

echo "Done!"
