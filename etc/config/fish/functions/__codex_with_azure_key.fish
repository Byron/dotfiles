function __codex_with_azure_key --description 'Run Codex with a shell, Keychain, or prompted Azure API key'
    # Keep credentials out of traces and scoped to this invocation.
    set -l fish_trace
    set -lx AZURE_OPENAI_API_KEY "$AZURE_OPENAI_API_KEY"

    if test -z "$AZURE_OPENAI_API_KEY"; and test (uname) = Darwin; and command -q security
        set AZURE_OPENAI_API_KEY (command security find-generic-password -a "$USER" -s azure-openai-codex -w 2>/dev/null); or set AZURE_OPENAI_API_KEY ''
    end

    if test -z "$AZURE_OPENAI_API_KEY"
        if not isatty stdin
            printf 'codex: set AZURE_OPENAI_API_KEY in this shell or for this invocation\n' >&2
            return 1
        end
        read --silent --prompt-str 'Azure OpenAI API key: ' AZURE_OPENAI_API_KEY; or begin
            printf 'codex: failed to read the Azure OpenAI API key\n' >&2
            return 1
        end
    end

    if test -z "$AZURE_OPENAI_API_KEY"
        printf 'codex: Azure OpenAI API key cannot be empty\n' >&2
        return 1
    end

    command $argv
end
