#!/usr/bin/env bash
# First run on a machine: keep a copy of any pre-existing dotfiles that chezmoi is about to manage,
# and move aside the ones that would shadow the new config.
set -euo pipefail

# Only ever on the very first apply: chezmoi re-runs run_once_ scripts whenever their content changes,
# and by then these paths are chezmoi's own files.
marker="$HOME/.dotfiles_backup/.first-apply-done"
[ -e "$marker" ] && exit 0
mkdir -p "$HOME/.dotfiles_backup"
backup="$HOME/.dotfiles_backup/$(date +%Y%m%d-%H%M%S)"

save() { # save <copy|move> <path>
  local mode=$1 path=$2
  [ -e "$path" ] || [ -L "$path" ] || return 0
  mkdir -p "$backup/$(dirname "${path#"$HOME"/}")"
  if [ "$mode" = move ]; then
    mv "$path" "$backup/${path#"$HOME"/}"
  else
    cp -a "$path" "$backup/${path#"$HOME"/}"
  fi
  echo "  backed up ${path/#$HOME/~}"
}

for f in .zshrc .zshenv .gitconfig .vimrc .ssh/config .config/tmux/tmux.conf .config/starship.toml; do
  save copy "$HOME/$f"
done
# These would take precedence over / mix with the new config, so move them out of the way.
save move "$HOME/.tmux.conf"
save move "$HOME/.config/nvim"

# Keep existing ssh hosts working: they become ~/.ssh/config.local, which the new config includes.
# (An old ~/.gitconfig is only backed up; copy what you still need into ~/.gitconfig.local.)
if [ -f "$HOME/.ssh/config" ] && [ ! -e "$HOME/.ssh/config.local" ]; then
  cp -a "$HOME/.ssh/config" "$HOME/.ssh/config.local"
fi

if [ -d "$backup" ]; then
  echo "Existing dotfiles saved to ${backup/#$HOME/~}"
fi
touch "$marker"
