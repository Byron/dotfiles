# Make Cargo-installed tools available before initializing the prompt.
if test -d "$HOME/.cargo/bin"
    fish_add_path --global --path "$HOME/.cargo/bin"
end

if status is-interactive
    set -gx STARSHIP_CONFIG "$HOME/.dotfiles/etc/config/starship.toml"
    if command -q starship
        starship init fish | source
    else if test -x "$HOME/.cargo/bin/starship"
        "$HOME/.cargo/bin/starship" init fish | source
    end

    if functions -q fish_prompt; and functions -q __ghostty_git_repo_background; and not functions -q __fish_prompt_without_ghostty_git_repo_background
        functions --copy fish_prompt __fish_prompt_without_ghostty_git_repo_background
        function fish_prompt
            __fish_prompt_without_ghostty_git_repo_background $argv
            __ghostty_git_repo_background
        end
    end

    if functions -q fish_user_key_bindings
        fish_user_key_bindings
    end

    function __abbr_multicd
        set -l levels (math (string length -- $argv[1]) - 1)
        echo cd (string repeat -n $levels ../)
    end

    abbr --add multicd --position command --regex '^\.\.+$' --function __abbr_multicd
end

if test -x /opt/homebrew/bin/brew
    set -gx HOMEBREW_PREFIX /opt/homebrew
    set -gx HOMEBREW_CELLAR /opt/homebrew/Cellar
    set -gx HOMEBREW_REPOSITORY /opt/homebrew
    fish_add_path --global --move --path /opt/homebrew/bin /opt/homebrew/sbin
    if test -n "$MANPATH"
        set -gx MANPATH (string replace --regex '^:*(.*?):*$' ':$1' -- "$MANPATH")
    end
    if not set -q INFOPATH
        set INFOPATH ''
    end
    set -gx INFOPATH /opt/homebrew/share/info $INFOPATH
    set -gx HOMEBREW_NO_ANALYTICS 1

    if test -d /opt/homebrew/opt/awscli@1/bin
        fish_add_path -g /opt/homebrew/opt/awscli@1/bin
    end
end

fish_add_path --path --append /usr/local/bin

set -gx EDITOR hx
set -gx VISUAL hx
set -gx AZURE_OPENAI_BASE_URL https://openai-instance-g2.openai.azure.com/openai/v1
# set -gx https_proxy http://127.0.0.1:8118
# set -gx http_proxy http://127.0.0.1:8118

if command -q gpgconf
    set -gx SSH_AUTH_SOCK (gpgconf --list-dirs agent-ssh-socket)
end

set -l gpg_agent_commands /bye
if test -t 0
    set -l tty_path (tty 2>/dev/null)

    if test $status -eq 0
        set -gx GPG_TTY $tty_path

        set gpg_agent_commands updatestartuptty /bye
    end
end

if command -q gpg-connect-agent
    # One connection starts the SSH agent and updates pinentry's terminal when available.
    gpg-connect-agent $gpg_agent_commands >/dev/null 2>/dev/null
end

if test -d "$HOME/.npm-global/bin"
    fish_add_path -g "$HOME/.npm-global/bin"
end

# Added by LM Studio CLI (lms)
set -gx PATH $PATH /Users/byron/.cache/lm-studio/bin
# End of LM Studio CLI section

# Added by OrbStack: command-line tools and integration
# This won't be added again if you remove it.
source ~/.orbstack/shell/init2.fish 2>/dev/null || :
