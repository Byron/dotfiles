#!/bin/bash

function has_program () {
  command -v ${1:?Need program name} >/dev/null 2>&1
}

function setup_rust () {
  if ! has_program rustup; then
    curl https://sh.rustup.rs -sSf | sh /dev/stdin -y
  fi
  
  for program in skim; do
    install_rust_program $program
  done
  
  install_rust_program cargo-update cargo-install-update
}

function install_rust_program () {
  local program=${1:?Need name of program to install}
  local program_name=${2-$1}
  if ! has_program $program_name; then
    echo Installing rust program '$program'
    cargo install --force $program
  fi
}

function clone_repositories () {
  clone_or_pull https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
}
