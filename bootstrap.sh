#!/bin/bash -eu

read -p "Press <enter> to setup your dotfiles ..."

dest=~/.dotfiles

if ! [ -d "$dest" ]; then
  git clone https://github.com/Byron/dotfiles $dest
  $dest/bin/install.sh
else
  echo "'$dest' is already present - pulling latest"
  cd $dest && git pull --rebase
fi

