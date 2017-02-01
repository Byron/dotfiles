#!/bin/bash

function clone_or_pull () {
  local repo=${1:?Need repository url to clone}
  local path=${2:?Need path to clone repository into or to pull latest}
  
  echo Clone or update $repo to $path
  if [ -d $path/.git ]; then
    cd $path && git pull --rebase
  else
    git clone $repo $path
  fi
}

function update_everything () {
    yes | apm update &
    (brew update && brew upgrade; brew cleanup) &
    (npm install npm -g && npm update -g) &
    rustup update stable &
    cargo install-update --all &

    wait
}
