# Codex launchers in Fish

`codex` (via `codex-azure`) and `codex-dev` launch with `--profile azure`.
They reuse `AZURE_OPENAI_API_KEY` from the shell or invocation, including a
shell variable that has not been exported. With no key set, macOS tries the
`azure-openai-codex` Keychain entry for the current user. Linux skips Keychain.
If neither supplies a key, the launcher prompts with masked input on a terminal.
Empty input and cancellation stop the launch. Noninteractive calls require a
key already set so that the launcher does not consume input intended for Codex.

For a key kept only in the current shell:

```fish
read --silent --prompt-str 'Azure OpenAI API key: ' --global AZURE_OPENAI_API_KEY
codex
codex-dev
set --erase --global AZURE_OPENAI_API_KEY
```

For a key supplied by an existing variable to one invocation:

```fish
AZURE_OPENAI_API_KEY="$azure_key" codex-dev
```

Alternatively, run either launcher without a key and enter it at the prompt.
Prompted and Keychain keys are exported only for that invocation; the launchers
do not save credentials or alter the caller's key. Credential handling suppresses
Fish command tracing. Arguments and the Codex exit status pass through unchanged.

The `azure` profile must already be configured in the active Codex configuration.
`codex-dev` runs `~/.cargo/bin/codex-dev/bin/codex`; `codex` uses the executable
on `PATH`. Existing OpenAI launchers retain their separate authentication.

To verify the wrappers without real credentials or API requests:

```sh
python3 tests/test_codex_fish.py
```
