function wait-pr --description 'Wait for a Gitoxide PR to finish CI or be merged'
    if test (count $argv) -ne 1
        echo 'usage: wait-pr PR_NUMBER' >&2
        return 2
    end

    set -l pr $argv[1]
    set -l url "https://github.com/GitoxideLabs/gitoxide/pull/$pr"

    echo "Watching Gitoxide PR #$pr every 20 seconds."
    echo 'Will stop when CI finishes or the PR is merged.'
    echo 'If merged, will run: stg commit -a; and wt remove -D'

    while true
        set -l state (gh pr view "$url" --json state --jq .state 2>/dev/null)

        if test "$state" = MERGED
            echo ' merged'
            stg commit -a; and wt remove -D
            return
        end

        set -l ci_done (gh pr checks "$url" --json bucket \
            --jq 'length > 0 and all(.[]; .bucket != "pending")' 2>/dev/null)

        if test "$ci_done" = true
            echo ' CI finished; PR is not merged'
            return
        end

        printf '.'
        sleep 20
    end
end
