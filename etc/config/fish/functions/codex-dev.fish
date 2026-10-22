function codex-dev --description 'Run development Codex with Azure OpenAI by default'
    __codex_with_azure_key "$HOME/.cargo/bin/codex-dev/bin/codex" --profile azure $argv
end
