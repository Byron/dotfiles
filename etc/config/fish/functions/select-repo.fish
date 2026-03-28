function select-repo --description 'Select a repository under ~/dev'
    set -l root ~/dev
    set -l query $argv[1]

    printf '%s/' $root
    begin
        cd $root
        and ein --quiet t find
    end | sk -q "$query"
end
