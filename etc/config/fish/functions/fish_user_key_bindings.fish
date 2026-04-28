function fish_user_key_bindings --description 'User key bindings'
    bind ctrl-e 'if commandline --search-mode; or commandline --paging-mode; commandline -f execute; else; commandline -f end-of-line; end'
    bind ctrl-x,ctrl-e edit_command_buffer
end
