function codex-dev --description 'Run development Codex with Azure OpenAI by default'
    set -lx AZURE_OPENAI_API_KEY (security find-generic-password -a "$USER" -s azure-openai-codex -w); or return
    command "$HOME/.cargo/bin/codex-dev/codex" --profile azure $argv
end
