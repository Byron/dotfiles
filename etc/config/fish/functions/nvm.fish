function nvm --description 'Use the existing nvm-sh installation from Fish'
    set -l nvm_env_file (mktemp); or return
    command bash -c '
        export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
        . "$NVM_DIR/nvm.sh" --no-use || exit
        nvm "${@:2}"
        nvm_result=$?
        for nvm_variable in PATH MANPATH NODE_PATH NVM_BIN NVM_INC NVM_DIR; do
            printf "%s\0%s\0" "${!nvm_variable+x}" "${!nvm_variable}"
        done > "$1"
        exit "$nvm_result"
    ' nvm "$nvm_env_file" $argv
    set -l nvm_result $status
    if test -s "$nvm_env_file"
        for nvm_variable in PATH MANPATH NODE_PATH NVM_BIN NVM_INC NVM_DIR
            read --null --local nvm_is_set
            read --null --local nvm_value
            if test "$nvm_is_set" = x
                set --global --export $nvm_variable "$nvm_value"
            else
                set --erase --global $nvm_variable
            end
        end < "$nvm_env_file"
    end
    command rm -- "$nvm_env_file"
    return $nvm_result
end
