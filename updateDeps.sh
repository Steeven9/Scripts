#!/usr/bin/env bash

# usage:
# ./updateDeps.sh
#
# Runs 'yarn upgrade' in all the repos,
# then commits and pushes the changes

# projects home
git_home="$HOME/projects"
# folders to exclude from the pull (full path, e.g. "$git_home/scripts")
exclusions=("$git_home/Scripts")
# message used in the commit
commit_message="Update deps"

for d in $git_home/*/; do
  dir=${d%*/}

  if [[ " ${exclusions[*]} " =~ " ${dir} " ]]; then
    echo "* Skipping $dir due to ignore list... *"
    echo "-----------"
    continue
  fi

  if [[ ! -f "$dir/yarn.lock" ]]; then
    echo "* Skipping $dir, not a Yarn repo... *"
    echo "-----------"
    continue
  fi

  echo "* Updating $dir... *"
  cd "$d"

  git stash

  git pull

  yarn upgrade
  yarn build

  git commit -am $commit_message
  git push

  git stash pop

  cd ..
  echo "-----------"
done

echo "Done!"
