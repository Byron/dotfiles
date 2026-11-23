# Launch the local Codex development build with the Azure profile.
codex-dev() (
    set +x

    local azure_key
    azure_key="${AZURE_OPENAI_API_KEY-}"

    if [ -z "$azure_key" ]; then
        IFS= read -r -s -p 'Azure OpenAI API key: ' azure_key
        local read_status=$?
        printf '\n' >&2

        if [ "$read_status" -ne 0 ]; then
            printf 'codex-dev: failed to read the Azure OpenAI API key\n' >&2
            return 1
        fi
    fi

    if [ -z "$azure_key" ]; then
        printf 'codex-dev: Azure OpenAI API key cannot be empty\n' >&2
        return 1
    fi

    export AZURE_OPENAI_API_KEY="$azure_key"
    command "$HOME/.cargo/bin/codex-dev/bin/codex" --profile azure "$@"
)

# Launch the local Codex development build with the existing OpenAI login.
codex-dev-openai() (
    command "$HOME/.cargo/bin/codex-dev/bin/codex" "$@"
)
