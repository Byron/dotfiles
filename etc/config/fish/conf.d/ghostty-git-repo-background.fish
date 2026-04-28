function __ghostty_git_repo_background_color --argument-names path
    command -q starship
    or return 1

    set -l rendered (starship module git_repo_color --path "$path" 2>/dev/null)
    test -n "$rendered"
    or return 1

    set -l color_code
    for seq in (string match -ra "\e\\[[0-9;]*m" -- $rendered)
        for code in (string match -ra "[0-9]+" -- $seq)
            switch $code
                case 30 31 32 33 34 35 36 37 90 91 92 93 94 95 96 97
                    set color_code $code
            end
        end
    end

    switch $color_code
        case 30
            echo "#080808"
        case 31
            echo "#1a0808"
        case 32
            echo "#081808"
        case 33
            echo "#1a1406"
        case 34
            echo "#080d1a"
        case 35
            echo "#18081a"
        case 36
            echo "#08181a"
        case 37
            echo "#181818"
        case 90
            echo "#121212"
        case 91
            echo "#220b0b"
        case 92
            echo "#0b220b"
        case 93
            echo "#24200b"
        case 94
            echo "#0b1224"
        case 95
            echo "#220b24"
        case 96
            echo "#0b2224"
        case 97
            echo "#202020"
        case "*"
            return 1
    end
end

function __ghostty_git_repo_background --on-variable PWD
    status --is-interactive
    or return

    set -q GHOSTTY_RESOURCES_DIR
    or test "$TERM_PROGRAM" = ghostty
    or return

    set -l color (__ghostty_git_repo_background_color "$PWD")
    if test -n "$color"
        printf "\e]11;%s\e\\" $color
    else
        printf "\e]111\e\\"
    end
end

if status --is-interactive
    __ghostty_git_repo_background
end
