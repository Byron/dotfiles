function wait-pr --description 'Wait for a PR to finish CI or be merged'
    if test (count $argv) -ne 1
        echo 'usage: wait-pr PR_NUMBER' >&2
        return 2
    end

    set -l pr $argv[1]
    set -l repository_url (gh repo view --json url --jq .url 2>/dev/null)
    if test -z "$repository_url"
        echo 'wait-pr: could not determine the repository URL for the current directory' >&2
        return 2
    end
    set -l url "$repository_url/pull/$pr"

    echo "Watching $repository_url PR #$pr every 20 seconds."
    echo 'Will stop and notify when the PR is merged or CI finishes.'
    echo 'Completed CI without a merge will be reported as a warning.'
    echo 'If merged, will run: stg commit -a; and wt remove -D'

    while true
        set -l state (gh pr view "$url" --json state --jq .state 2>/dev/null)

        if test "$state" = MERGED
            printf '\e]9;✅ PR #%s merged!\e\\' "$pr"
            echo ' ✅ merged'
            stg commit -a; and wt remove -D
            return
        end

        set -l ci_failed (gh pr checks "$url" --json bucket \
            --jq 'any(.[]; .bucket == "fail" or .bucket == "cancel")' 2>/dev/null)

        if test "$ci_failed" = true
            printf '\e]9;❌ PR #%s CI failed!\e\\' "$pr"
            echo ' ❌ CI failed or was cancelled'
            return 1
        end

        set -l ci_done (gh pr checks "$url" --json bucket \
            --jq 'length > 0 and all(.[]; .bucket != "pending")' 2>/dev/null)

        if test "$ci_done" = true
            printf '\e]9;⚠️ PR #%s CI finished, but is not merged\e\\' "$pr"
            echo ' ⚠️ CI finished; PR is not merged'
            return
        end

        printf '.'
        sleep 20
    end
end
