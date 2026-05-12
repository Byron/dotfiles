function stg_top_stack_id
    set -l count (stg series --count); or return
    test "$count" -gt 0; or return 1
    stg id (math $count - 1)
end
