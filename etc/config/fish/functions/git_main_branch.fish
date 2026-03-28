function git_main_branch --description 'Print the repository default branch'
    command git rev-parse --git-dir >/dev/null 2>/dev/null
    or return

    for ref in \
        refs/heads/main \
        refs/heads/trunk \
        refs/heads/mainline \
        refs/heads/default \
        refs/heads/stable \
        refs/heads/master \
        refs/remotes/origin/main \
        refs/remotes/origin/trunk \
        refs/remotes/origin/mainline \
        refs/remotes/origin/default \
        refs/remotes/origin/stable \
        refs/remotes/origin/master \
        refs/remotes/upstream/main \
        refs/remotes/upstream/trunk \
        refs/remotes/upstream/mainline \
        refs/remotes/upstream/default \
        refs/remotes/upstream/stable \
        refs/remotes/upstream/master
        if command git show-ref -q --verify $ref
            string replace -r '.*/' '' -- $ref
            return 0
        end
    end

    for remote in origin upstream
        set -l ref (command git rev-parse --abbrev-ref $remote/HEAD 2>/dev/null)
        if string match -rq "^$remote/" -- $ref
            string replace -r "^$remote/" '' -- $ref
            return 0
        end
    end

    echo master
    return 1
end
