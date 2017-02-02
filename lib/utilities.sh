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

function update_everything () {
    local brew_owner="$(/usr/bin/stat -f %Su "$(command -v brew)")"
    local npm_owner="$(/usr/bin/stat -f %Su "$(command -v npm)")"
    
    yes | apm update &
    (sudo -u $brew_owner -i brew update && sudo -u $brew_owner -i brew upgrade; sudo -u $brew_owner -i brew cleanup) &
    (sudo -u $npm_owner -i npm install npm -g && sudo -u $npm_owner -i npm update -g) &
    (rustup update stable && (
      cargo +nightly install-update --all &
      cargo +nightly install --force --git https://github.com/jwilm/alacritty &
      wait
    )) &

    wait
}
