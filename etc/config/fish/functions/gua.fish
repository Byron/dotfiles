function gua --description 'Run git pull --rebase in nested repos up to depth 2'
    for dir in (find . -type d -name .git 2>/dev/null)
        if test (count (string split '/' -- $dir)) -gt 4
            continue
        end

        begin
            cd (dirname $dir)
            and git pull --rebase
        end
    end
end
