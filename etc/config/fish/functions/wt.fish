# tix worktrunk shell integration for fish
# Sources full integration from tix on first use.

function wt
    command tix wt shell-init fish | source
    # Check both command exit code ($pipestatus[1]) and source exit code ($pipestatus[2])
    # If source fails, the function isn't replaced and we'd infinite-loop calling ourselves
    set -l tix_status $pipestatus[1]
    set -l source_status $pipestatus[2]
    test $tix_status -eq 0; or return $tix_status
    test $source_status -eq 0; or return $source_status
    wt $argv
end
