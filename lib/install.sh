#!/bin/bash

function has_program () {
  command -v ${1:?Need program name} >/dev/null 2>&1
}

function setup_rust () {
  if ! has_program rustup; then
    curl https://sh.rustup.rs -sSf | sh /dev/stdin -y
  fi
  
  install_rust_program cargo-update cargo-install-update
  install_rust_program heatseeker hs
}

function install_rust_program () {
  local program=${1:?Need name of program to install}
  local program_name=${2-$1}
  if ! has_program $program_name; then
    echo Installing rust program '$program'
    cargo install --force $program
  fi
}

function link_dotfiles () {
  local base_dir=${1:?Need base repository checkout directory}
  local base_name
  base_name=$(basename "$base_dir")
  local from_relative_dir=${2:?Need directory to with source dot files}
  local to_dir=${3:?Need directory to create simlinks to}
  
  for dotfile in $(ls $base_dir/$from_relative_dir); do
    local dotpath=$to_dir/.$dotfile
    if ! [ -L "$dotpath" ]; then
      rm -fv $dotpath
      echo Linking $dotpath
      ln -s $base_name/$from_relative_dir/$dotfile $dotpath
    fi
  done
}

function clone_repositories () {
  clone_or_pull https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
}