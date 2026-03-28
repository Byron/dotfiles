function select-corpus --description 'Select a repository under the corpus checkout'
    set -l root /Volumes/gix-corpus/github.com
    set -l query $argv[1]

    printf '%s/' $root
    begin
        cd $root
        and ein --quiet t find
    end | sk -q "$query"
end
