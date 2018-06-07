#!/bin/bash

function clone_or_pull () {
  local repo=${1:?Need repository url to clone}
  local path=${2:?Need path to clone repository into or to pull latest}

  echo Clone or update $repo to $path
  if [ -d $path/.git ]; then
    cd $path && git pull --rebase
  else
    git clone --depth 1 $repo $path
  fi
}
