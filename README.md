These are my dotfiles, with enough automation to setup a new mac/account with the essentials,
and to keep it up to day.

### Fish, Codex skills, and tmuxx (Linux or macOS)

```sh
bash bin/install-shell.sh
tmuxx source-file "${XDG_CONFIG_HOME:-$HOME/.config}/tmuxx/tmux.conf"
```

This links fish's scripts and Starship configuration into the config directory,
and custom skills into `~/.agents/skills`, which Codex discovers automatically.
Existing files are backed up beside their replacements. Fish's history and
universal variables remain local to the machine.

New tmuxx panes run `~/.cargo/bin/fish --interactive-language=bash`; existing
panes keep their shells. Cargo binaries are added to fish's PATH before Starship
is initialized. The account's login shell is unchanged.

This tmuxx build requires an explicit configuration file when starting a daemon:
use `tmuxx -f ~/.config/tmuxx/tmux.conf ...`, or set
`tmuxx-config-file = ~/.config/tmuxx/tmux.conf` in the launching Rustty client.
Use your `XDG_CONFIG_HOME` path instead if it differs from `~/.config`.


### Bootstrapping

```
curl -sS https://raw.githubusercontent.com/Byron/dotfiles/master/bootstrap.sh | bash
```
