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
    /opt/homebrew/bin/brew shellenv | source
    set -gx HOMEBREW_NO_ANALYTICS 1

    if test -d /opt/homebrew/opt/awscli@1/bin
        fish_add_path -g /opt/homebrew/opt/awscli@1/bin
    end
end

set -gx EDITOR hx
set -gx VISUAL hx
set -gx https_proxy http://127.0.0.1:8118
set -gx http_proxy http://127.0.0.1:8118

if command -q gpgconf
    gpgconf --launch gpg-agent >/dev/null 2>/dev/null
    set -gx SSH_AUTH_SOCK (gpgconf --list-dirs agent-ssh-socket)
end

if test -t 0
    set -l tty_path (tty 2>/dev/null)

    if test $status -eq 0
        set -gx GPG_TTY $tty_path

        if command -q gpg-connect-agent
            gpg-connect-agent updatestartuptty /bye >/dev/null 2>/dev/null
        end
    end
end

if test -d "$HOME/.cargo/bin"
    fish_add_path -g "$HOME/.cargo/bin"
end

# Added by LM Studio CLI (lms)
set -gx PATH $PATH /Users/byron/.cache/lm-studio/bin
# End of LM Studio CLI section

# Added by OrbStack: command-line tools and integration
# This won't be added again if you remove it.
source ~/.orbstack/shell/init2.fish 2>/dev/null || :
