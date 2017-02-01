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

  local brew_packages="git zsh vim neovim ctags tmux vcprompt zsh-completions
    ruby-install curl wget crystal-lang openssl htop
    node rlwrap valgrind qcachegrind coreutils
    kubectl reattach-to-user-namespace nvm watch fswatch
    asciinema jq netcat diff-so-fancy"
  local brew_owner="$(/usr/bin/stat -f %Su "$(command -v brew)")"
  for package in $brew_packages; do
    sudo -u $brew_owner brew install "$package"
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
  local cask_packages="google-chrome iterm2 docker the-unarchiver atom visual-studio-code"
  for package in $cask_packages; do
    brew cask install "$package"
  done
}

function setup_user () {
  sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

  setup_vim
  setup_atom
}

function setup_atom () {
  local plugins="atom-beautify coffee-compile ex-mode git-plus language-crystal-actual
    language-docker language-mako language-restructuredtext language-rust linter
    linter-coffeelint linter-crystal linter-csslint linter-flake8 linter-golinter
    linter-htmlhint linter-js-standard linter-js-yaml linter-jshint linter-jsonlint
    linter-lua linter-markdown linter-pylint linter-python-pep8 linter-rubocop
    linter-ruby linter-rust linter-sass-lint linter-scss-lint linter-shellcheck
    linter-tslint linter-xmllint minimap minimap-linter pretty-json
    preview project-manager racer react relative-numbers rust-api-docs-helper seti-icons
    source-preview source-preview-react standardjs-snippets symbol-gen vim-mode-plus"
  for plugin in $plugins; do
    apm install $plugin
  done
}

function setup_xcode () {
  if ! xcode-select -p; then
    xcode-select --install
  fi
}

function setup_vim () {
  # pathogen for vim
  mkdir -p ~/.vim/autoload ~/.vim/bundle && curl -LSso ~/.vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim

  for plugin in https://github.com/vim-syntastic/syntastic.git \
                https://github.com/tpope/vim-surround.git; do
    clone_or_pull $plugin ~/.vim/bundle
  done
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

function setup_osx () {
  # Save to disk (not to iCloud) by default
  defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false

  # Check for software updates daily, not just once per week
  defaults write com.apple.SoftwareUpdate ScheduleFrequency -int 1

  # Trackpad: enable tap to click for this user and for the login screen
  defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true

  # Natural scrolling
  defaults write NSGlobalDomain com.apple.swipescrolldirection -bool true

  # Set language and text formats
  defaults write NSGlobalDomain AppleLanguages -array "en-DE" "de-DE"
  defaults write NSGlobalDomain AppleLocale -string "en_DE@currency=EUR"
  defaults write NSGlobalDomain AppleMeasurementUnits -string "Centimeters"
  defaults write NSGlobalDomain AppleMetricUnits -bool true

  # Disable auto-correct
  defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false

  # Use scroll gesture with the Ctrl (^) modifier key to zoom
  defaults write com.apple.universalaccess closeViewScrollWheelToggle -bool true
  # Follow the keyboard focus while zoomed in
  defaults write com.apple.universalaccess closeViewZoomFollowsFocus -bool true

  # Finder: show all filename extensions
  defaults write NSGlobalDomain AppleShowAllExtensions -bool true

  # Finder: show status bar
  defaults write com.apple.finder ShowStatusBar -bool true

  # Finder: show path bar
  defaults write com.apple.finder ShowPathbar -bool true

  # Automatically hide and show the Dock
  defaults write com.apple.dock autohide -bool true

  # Set the icon size of Dock items to 64 pixels
  defaults write com.apple.dock tilesize -int 64

  # Hot corners
  # Possible values:
  #  0: no-op
  #  2: Mission Control
  #  3: Show application windows
  #  4: Desktop
  #  5: Start screen saver
  #  6: Disable screen saver
  #  7: Dashboard
  # 10: Put display to sleep
  # 11: Launchpad
  # 12: Notification Center
  defaults write com.apple.dock wvous-tl-corner -int 5
  defaults write com.apple.dock wvous-tr-corner -int 4
  defaults write com.apple.dock wvous-bl-corner -int 10
  defaults write com.apple.dock wvous-br-corner -int 2

  defaults write com.apple.dock wvous-br-modifier -int 1048576
  defaults write com.apple.dock wvous-bl-modifier -int 1048576
  defaults write com.apple.dock wvous-tr-modifier -int 1048576
  defaults write com.apple.dock wvous-tl-modifier -int 1048576

  # Privacy: don’t send Safari search queries to Apple
  defaults write com.apple.Safari UniversalSearchEnabled -bool false
  defaults write com.apple.Safari SuppressSearchSuggestions -bool true

  # Enable the Develop menu and the Web Inspector in Safari
  defaults write com.apple.Safari IncludeDevelopMenu -bool true
  defaults write com.apple.Safari WebKitDeveloperExtrasEnabledPreferenceKey -bool true
  defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled -bool true

  # Set iTerm2 preferences
  defaults write com.googlecode.iterm2 LoadPrefsFromCustomFolder -bool true
  defaults write com.googlecode.iterm2 PrefsCustomFolder -string $HOME/.dotfiles/etc

  echo "Logout/login might be needed to apply some of the settings"
}
