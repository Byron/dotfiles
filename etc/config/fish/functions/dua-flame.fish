function dua-flame --description 'Open a disk-usage flame graph'
    if test (count $argv) -eq 0
        echo 'usage: dua-flame PATH [...PATH]' >&2
        return 2
    end

    set -l temp_dir (mktemp -d -t dua-flamegraph); or return
    set -l svg "$temp_dir/flame.svg"
    command dua a --stack -- $argv | command inferno-flamegraph >"$svg"
    set -l pipeline_status $pipestatus
    for exit_code in $pipeline_status
        if test $exit_code -ne 0
            command rm -f "$svg"
            command rmdir "$temp_dir"
            return $exit_code
        end
    end
    command open "$svg"
end
