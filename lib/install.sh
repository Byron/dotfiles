#!/bin/bash

function has_program () {
  command -v ${1:?Need program name} >/dev/null 2>&1
}

function setup_rust () {
  if ! has_program rustup; then
    curl https://sh.rustup.rs -sSf | sh /dev/stdin -y
  fi

  install_rust_program cargo-update cargo-install-update
  install_rust_program cargo-edit cargo-add
  install_rust_program heatseeker hs
  install_rust_program ripgrep rg
  install_rust_program crates-io-cli krates

  for program in loc; do
    install_rust_program $program
  done
}

function setup_brew () {
  if ! has_program brew; then
    yes | /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
  fi

  brew_packages="git zsh neovim ctags tmux vcprompt zsh-completions
    ruby-install curl wget crystal-lang openssl htop
    node rlwrap valgrind qcachegrind coreutils
    kubectl reattach-to-user-namespace nvm watch fswatch
    asciinema jq netcat diff-so-fancy"
  for package in $brew_packages; do
    brew install "$package"
  done

  if ! brew info cask &> /dev/null; then
    echo "Installing Homebrew Cask" &&
    brew install caskroom/cask/brew-cask
  else
    echo "Updating Homebrew cask"
    brew cask update
    brew cask cleanup
  fi

  # Install cask essentials
  cask_packages="google-chrome iterm2 sequel-pro docker
  the-unarchiver enpass vagrant atom"
  for package in $cask_packages; do
    brew cask install "$package"
  done
}

function setup_user () {
  sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

  # pathogen for vim
  mkdir -p ~/.vim/autoload ~/.vim/bundle && curl -LSso ~/.vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim
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
  clone_or_pull https://github.com/junegunn/fzf.git ~/.fzf
}
