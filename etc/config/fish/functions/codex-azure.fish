function codex-azure --description 'Run Codex with the Azure OpenAI API key from Keychain'
    set -lx AZURE_OPENAI_API_KEY (security find-generic-password -a "$USER" -s azure-openai-codex -w); or return
    command codex --profile azure $argv
end
