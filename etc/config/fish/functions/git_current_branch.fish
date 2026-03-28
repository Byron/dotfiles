function git_current_branch --description 'Print the current git branch or short HEAD'
    set -l ref (__git_prompt_git symbolic-ref --quiet HEAD 2>/dev/null)
    set -l ret $status

    if test $ret -ne 0
        if test $ret -eq 128
            return
        end

        set ref (__git_prompt_git rev-parse --short HEAD 2>/dev/null)
        or return
    end

    string replace -r '^refs/heads/' '' -- $ref
end
