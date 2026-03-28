# cargo nextest completions

function __fish_cargo_nextest_at_top
    set -l words (commandline -opc)
    test (count $words) -eq 2
    and test "$words[1]" = cargo
    and test "$words[2]" = nextest
end

function __fish_cargo_nextest_in_self
    set -l words (commandline -opc)
    test (count $words) -ge 3
    and test "$words[1]" = cargo
    and test "$words[2]" = nextest
    and test "$words[3]" = self
end

complete -c cargo -n '__fish_use_subcommand' -f -a nextest -d 'A next-generation test runner for Rust'

set -l __cargo_nextest_condition '__fish_seen_subcommand_from nextest'

complete -c cargo -n '__fish_cargo_nextest_at_top' -f -a list -d 'List tests in workspace'
complete -c cargo -n '__fish_cargo_nextest_at_top' -f -a run -d 'Build and run tests'
complete -c cargo -n '__fish_cargo_nextest_at_top' -f -a bench -d 'Build and run benchmarks'
complete -c cargo -n '__fish_cargo_nextest_at_top' -f -a archive -d 'Build and archive tests'
complete -c cargo -n '__fish_cargo_nextest_at_top' -f -a show-config -d "Show information about nextest's configuration"
complete -c cargo -n '__fish_cargo_nextest_at_top' -f -a self -d 'Manage the nextest installation'
complete -c cargo -n '__fish_cargo_nextest_at_top' -f -a help -d 'Print help'

complete -c cargo -n '__fish_cargo_nextest_in_self' -f -a update -d 'Download and install updates to nextest'
complete -c cargo -n '__fish_cargo_nextest_in_self' -f -a help -d 'Print help'

complete -c cargo -n "$__cargo_nextest_condition" -l color -x -a 'auto always never' -d 'Produce color output'
complete -c cargo -n "$__cargo_nextest_condition" -l no-pager -d 'Do not pipe output through a pager'
complete -c cargo -n "$__cargo_nextest_condition" -s v -l verbose -d 'Verbose output'
complete -c cargo -n "$__cargo_nextest_condition" -s h -l help -d 'Print help'
complete -c cargo -n "$__cargo_nextest_condition" -s V -l version -d 'Print version'
complete -c cargo -n "$__cargo_nextest_condition" -l manifest-path -r -d 'Path to Cargo.toml'
complete -c cargo -n "$__cargo_nextest_condition" -l config-file -r -d 'Config file'
complete -c cargo -n "$__cargo_nextest_condition" -l tool-config-file -r -d 'Tool-specific config file'
complete -c cargo -n "$__cargo_nextest_condition" -l override-version-check -d 'Override minimum version checks'
complete -c cargo -n "$__cargo_nextest_condition" -s P -l profile -r -d 'Select the nextest profile'
