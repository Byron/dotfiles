function wait-pr --description 'Wait for a PR to finish CI or be merged'
    argparse auto-merge no-cleanup -- $argv
    if test $status -ne 0; or test (count $argv) -gt 1
        echo 'usage: wait-pr [PR_NUMBER] [--auto-merge] [--no-cleanup]' >&2
        return 2
    end

    set -l pr $argv[1]
    set -l auto_merge (set -q _flag_auto_merge; and echo true; or echo false)
    set -l merge_requested false
    set -l ci_done_seen false

    set -l pr_info (gh pr view $pr --json number,url,title --jq '.number, .url, .title' 2>/dev/null)
    if test (count $pr_info) -ne 3
        if test -n "$pr"
            echo "wait-pr: could not find PR #$pr" >&2
        else
            echo 'wait-pr: could not find a PR for the current branch' >&2
        end
        return 2
    end
    set pr $pr_info[1]
    set -l url $pr_info[2]
    set -l title (string replace -ar '[[:cntrl:]]' ' ' -- $pr_info[3])

    echo "Watching $url every 12 seconds."
    echo 'Will stop and notify when the PR is merged or CI finishes.'
    if test "$auto_merge" = true
        echo 'Successful CI will trigger a merge.'
    else
        echo 'Completed CI without a merge will be reported as a warning.'
    end
    if set -q _flag_no_cleanup
        echo 'If merged, will run: git fetch'
    else
        echo 'If merged, will run: wt remove -D; and git pull --ff-only'
    end

    printf '\e]2;wait-pr %s#%s\e\\' (string split / -- "$url")[5] "$pr"
    printf '\e]9;4;3\e\\'
    while true
        set -l state (gh pr view "$url" --json state --jq .state 2>/dev/null)

        if test "$state" = MERGED
            printf '\e]9;✅ PR #%s merged: %s\e\\' "$pr" "$title"
            echo ' ✅ merged'
            if set -q _flag_no_cleanup
                git fetch
            else
                wt remove -D; and git pull --ff-only
            end
            set -l cleanup_status $status
            printf '\e]9;4;0\e\\'
            return $cleanup_status
        end

        set -l ci_failed (gh pr checks "$url" --required --json bucket \
            --jq 'any(.[]; .bucket == "fail" or .bucket == "cancel")' 2>/dev/null)

        if test "$ci_failed" = true
            printf '\e]9;❌ PR #%s CI failed: %s\e\\' "$pr" "$title"
            echo ' ❌ CI failed or was cancelled'
            printf '\e]9;4;0\e\\'
            return 1
        end

        set -l ci_done (gh pr checks "$url" --json bucket \
            --jq 'length > 0 and all(.[]; .bucket != "pending")' 2>/dev/null)

        if test "$ci_done" = true
            if test "$auto_merge" = true
                if test "$merge_requested" = false
                    echo ' ✅ CI finished; requesting merge'
                    if not gh pr merge "$url" --merge
                        printf '\e]9;❌ PR #%s could not be merged: %s\e\\' "$pr" "$title"
                        echo " ❌ merge failed: $url"
                        printf '\e]9;4;0\e\\'
                        return 1
                    end
                    set merge_requested true
                    continue
                end
            else
                if test "$ci_done_seen" = true
                    printf '\e]9;✅⚠️ PR #%s CI finished, but is not merged: %s\e\\' "$pr" "$title"
                    echo ' ✅⚠️ CI finished; PR is not merged'
                    printf '\e]9;4;0\e\\'
                    return
                end
                set ci_done_seen true
            end
        end

        printf '.'
        sleep 12
        printf '\e]9;4;3\e\\'
    end
end
