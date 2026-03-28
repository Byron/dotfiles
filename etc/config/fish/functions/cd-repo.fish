function cd-repo --description 'Change to a selected repository under ~/dev'
    set -l dest (select-repo $argv)
    test -n "$dest"
    or return 1

    cd "$dest"
end
