function pie --description 'Run Pie with the Azure OpenAI API key from Keychain'
    set -lx AZURE_OPENAI_API_KEY (security find-generic-password -a "$USER" -s azure-openai-pi -w); or return
    set -lx PI_PROVIDER azure-openai-pi
    command pie $argv
end
