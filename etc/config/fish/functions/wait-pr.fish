function wait-pr --description 'Wait for a PR to finish CI or be merged'
    if test (count $argv) -gt 2; or test (count $argv) -eq 2 -a "$argv[2]" != --auto-merge
        echo 'usage: wait-pr [PR_NUMBER] [--auto-merge]' >&2
        return 2
    end

    set -l pr
    set -l auto_merge false
    if test (count $argv) -ge 1
        if test "$argv[1]" = --auto-merge
            set auto_merge true
        else
            set pr $argv[1]
        end
    end
    if test (count $argv) -eq 2
        set auto_merge true
    end
    set -l merge_requested false
    set -l ci_done_seen false

    set -l pr_info (gh pr view $pr --json number,url --jq '.number, .url' 2>/dev/null)
    if test (count $pr_info) -ne 2
        if test -n "$pr"
            echo "wait-pr: could not find PR #$pr" >&2
        else
            echo 'wait-pr: could not find a PR for the current branch' >&2
        end
        return 2
    end
    set pr $pr_info[1]
    set -l url $pr_info[2]

    echo "Watching $url every 20 seconds."
    echo 'Will stop and notify when the PR is merged or CI finishes.'
    if test "$auto_merge" = true
        echo 'Successful CI will trigger a merge.'
    else
        echo 'Completed CI without a merge will be reported as a warning.'
    end
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
            if test "$auto_merge" = true
                if test "$merge_requested" = false
                    echo ' ✅ CI finished; requesting merge'
                    if not gh pr merge "$url" --merge
                        printf '\e]9;❌ PR #%s could not be merged!\e\\' "$pr"
                        echo ' ❌ merge failed'
                        return 1
                    end
                    set merge_requested true
                    continue
                end
            else
                if test "$ci_done_seen" = true
                    printf '\e]9;⚠️ PR #%s CI finished, but is not merged\e\\' "$pr"
                    echo ' ⚠️ CI finished; PR is not merged'
                    return
                end
                set ci_done_seen true
            end
        end

        printf '.'
        sleep 20
    end
end
