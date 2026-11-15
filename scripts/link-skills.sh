#!/usr/bin/env bash
# Symlinks every skill in this repo into the local agent skill directories.
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
target_dirs=("$HOME/.claude/skills" "$HOME/.agents/skills")

for target_dir in "${target_dirs[@]}"; do
  mkdir -p "$target_dir"
  for skill_dir in "$repo_root"/skills/*/; do
    skill_name="$(basename "$skill_dir")"
    link_path="$target_dir/$skill_name"
    if [[ -e "$link_path" && ! -L "$link_path" ]]; then
      echo "skip: $link_path already exists and is not a symlink" >&2
      continue
    fi
    ln -sfn "${skill_dir%/}" "$link_path"
    echo "linked: $link_path"
  done
done
