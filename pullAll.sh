#!/usr/bin/env bash

# usage:
# ./pullAll.sh
#
# Switches back to main/master and pulls updates for all repositories found in
# the subfolders of the git_home folder.

# projects home
git_home="$HOME/projects"
# folders to exclude from the pull (full path, e.g. "$git_home/scripts")
exclusions=("$git_home/Scripts")

for d in $git_home/*/; do
  dir=${d%*/}

  if [[ " ${exclusions[*]} " =~ " ${dir} " ]]; then
    echo "* Skipping $dir due to ignore list... *"
    echo "-----------"
    continue
  fi

  if [[ ! -d $dir/.git ]]; then
    echo "* Skipping $dir, not a git repo... *"
    echo "-----------"
    continue
  fi

  echo "* Updating $dir... *"
  cd "$d"

  if ! git switch master &>/dev/null; then
    git switch main &>/dev/null
  fi

  git stash
  git pull
  git stash pop

  if [ -f package.lock ]; then
    npm i
  fi
  if [ -f yarn.lock ]; then
    yarn
  fi
  if [ -f bun.lockb ]; then
    bun install
  fi

  cd ..
  echo "-----------"
done

echo "Done!"
