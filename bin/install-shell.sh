#!/bin/bash
# Install the shell configuration and custom skills without the macOS setup.
set -euo pipefail

repo_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
config_dir=${XDG_CONFIG_HOME:-$HOME/.config}
backup_suffix=dotfiles-backup-$(date +%Y%m%dT%H%M%S)-$$

link_config() {
    local source_path=$1 destination_path=$2
    mkdir -p -- "$(dirname -- "$destination_path")"
    if [[ -L "$destination_path" ]] && [[ $(readlink -- "$destination_path") == "$source_path" ]]; then
        return
    fi
    if [[ -e "$destination_path" || -L "$destination_path" ]]; then
        mv -- "$destination_path" "$destination_path.$backup_suffix"
    fi
    ln -s -- "$source_path" "$destination_path"
    printf 'Linked %s\n' "$destination_path"
}

# Keep fish's mutable universal variables local, and link its scripts individually.
while IFS= read -r -d '' source_path; do
    relative_path=${source_path#"$repo_dir/etc/config/fish/"}
    link_config "$source_path" "$config_dir/fish/$relative_path"
done < <(find "$repo_dir/etc/config/fish" -type f ! -name fish_variables -print0)

link_config "$repo_dir/etc/config/starship.toml" "$config_dir/starship.toml"
link_config "$repo_dir/etc/config/tmuxx/tmux.conf" "$config_dir/tmuxx/tmux.conf"

# Codex follows directory symlinks in its user-wide skills directory.
for skill_dir in "$repo_dir"/etc/codex/skills/*; do
    [[ -d "$skill_dir" ]] || continue
    link_config "$skill_dir" "$HOME/.agents/skills/${skill_dir##*/}"
done

printf 'Reload tmuxx with: tmuxx source-file "%s/tmuxx/tmux.conf"\n' "$config_dir"
