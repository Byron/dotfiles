function cd-repo-corpus --description 'Change to a selected repository under the corpus checkout'
    set -l dest (select-corpus $argv)
    test -n "$dest"
    or return 1

    cd "$dest"
end
