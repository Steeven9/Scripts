#!/usr/bin/env bash
set -euo pipefail

# usage:
# ./pullAll.sh
#
# Switches back to main/master and pulls updates for all repositories found in
# the subfolders of the GIT_HOME folder.

# projects home
GIT_HOME="$HOME/projects"
# folders to exclude from the pull (full path, e.g. "$GIT_HOME/Scripts")
EXCLUDE_DIRS=("")

for dir in "${GIT_HOME}"/*; do
  if [[ " ${EXCLUDE_DIRS[*]} " =~ " ${dir} " ]]; then
    echo "* Skipping ${dir} due to ignore list... *"
    echo "-----------"
    continue
  fi

  if [[ ! -d "${dir}/.git" ]]; then
    echo "* Skipping ${dir}, not a git repo... *"
    echo "-----------"
    continue
  fi

  echo "* Updating ${dir}... *"
  cd "${dir}"

  default_branch=$(git remote show origin 2>/dev/null | awk '/HEAD branch/ {print $NF}')
  if [[ -z "${default_branch}" ]]; then
    echo "* Skipping ${dir}, no remote origin... *"
    echo "-----------"
    cd "${GIT_HOME}"
    continue
  fi

  prev_branch=$(git symbolic-ref --short HEAD 2>/dev/null || echo "")
  stashed=false
  if [[ -n $(git status --short | grep -v "^??") ]]; then
    git stash
    stashed=true
  fi

  if [[ "${prev_branch}" != "${default_branch}" ]]; then
    git switch "${default_branch}"
  fi

  git pull

  if [[ -n "$prev_branch" && "${prev_branch}" != "${default_branch}" ]]; then
    git switch "${prev_branch}"
  fi

  if [[ $stashed == true ]]; then
    git stash pop
  fi

  if [ -f package-lock.json ]; then
    npm i
  fi
  if [ -f yarn.lock ]; then
    yarn
  fi
  if [ -f bun.lockb ]; then
    bun install
  fi

  cd "${GIT_HOME}"
  echo "-----------"
done

echo "Done!"
