if status is-interactive
    if command -q starship
        starship init fish | source
    else if test -x "$HOME/.cargo/bin/starship"
        "$HOME/.cargo/bin/starship" init fish | source
    end

    if functions -q fish_user_key_bindings
        fish_user_key_bindings
    end
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
    set -gx GPG_TTY (tty)
end

if test -d "$HOME/.cargo/bin"
    fish_add_path -g "$HOME/.cargo/bin"
end

# Added by LM Studio CLI (lms)
set -gx PATH $PATH /Users/byron/.cache/lm-studio/bin
# End of LM Studio CLI section
