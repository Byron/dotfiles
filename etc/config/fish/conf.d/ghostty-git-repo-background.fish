function __ghostty_git_repo_background_color --argument-names path
    command -q starship
    or return 1

    set -l rendered (starship module git_repo_color --path "$path" 2>/dev/null)
    test -n "$rendered"
    or return 1

    set -l rgb (string match -rg -- '\x1b\[48;2;([0-9]+);([0-9]+);([0-9]+)[;m]' "$rendered")
    test (count $rgb) -eq 3
    or return 1

    printf '#%02x%02x%02x\n' $rgb
end

function __ghostty_git_repo_background --on-variable PWD
    status --is-interactive
    or return

    set -q GHOSTTY_RESOURCES_DIR
    or test "$TERM_PROGRAM" = ghostty
    or return

    test "$__ghostty_git_repo_background_pwd" = "$PWD"
    and return

    # Fish buffers prompt output; reset the terminal before Starship queries it.
    printf "\e]111\e\\" >/dev/tty 2>/dev/null
    or return
    set -l color (__ghostty_git_repo_background_color "$PWD")
    set -g __ghostty_git_repo_background_pwd "$PWD"
    if test -n "$color"
        printf "\e]11;%s\e\\" $color
    end
end
