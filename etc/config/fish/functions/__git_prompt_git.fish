function __git_prompt_git --description 'Run git with prompt-safe locking behavior'
    env GIT_OPTIONAL_LOCKS=0 command git $argv
end
