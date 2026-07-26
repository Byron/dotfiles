function wt-pr --description 'Check out a PR in its own worktree'
    argparse -- $argv
    if test $status -ne 0; or test (count $argv) -ne 1
        echo 'usage: wt-pr PR_NUMBER' >&2
        return 2
    end

    set -l original_branch (git symbolic-ref --quiet --short HEAD)
    if test $status -ne 0
        echo 'wt-pr: current worktree has a detached HEAD' >&2
        return 2
    end

    gh pr checkout "$argv[1]"; or return
    set -l pr_branch (git symbolic-ref --quiet --short HEAD)
    if test $status -ne 0
        echo 'wt-pr: gh did not check out a branch' >&2
        git switch "$original_branch"; or return
        return 1
    end

    git switch "$original_branch"; or return
    wt switch "$pr_branch"
end
