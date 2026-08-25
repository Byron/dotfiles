function pi --description 'Run Pi with the Azure OpenAI API key from Keychain'
    set -lx AZURE_OPENAI_API_KEY (security find-generic-password -a "$USER" -s azure-openai-pi -w); or return
    command pi $argv
end
