#!/usr/bin/env bash
# First run on a machine: keep a copy of any pre-existing dotfiles that chezmoi is about to manage,
# and move aside the ones that would shadow the new config.
set -euo pipefail
umask 077   # backups (they include ~/.ssh/config) stay private on shared servers

# Only ever on the very first apply: chezmoi re-runs run_once_ scripts whenever their content changes,
# and by then these paths are chezmoi's own files. The marker lives outside ~/.dotfiles_backup so that
# deleting old backups can't trigger a second run (which used to copy our own ~/.ssh/config, with its
# Include line, into config.local: ssh then failed with "Too many recursive configuration includes").
marker="$HOME/.local/state/my_configs/first-apply-done"
legacy_marker="$HOME/.dotfiles_backup/.first-apply-done"
if [ -e "$marker" ] || [ -e "$legacy_marker" ]; then
  mkdir -p "$(dirname "$marker")" && touch "$marker"
  exit 0
fi
mkdir -p "$HOME/.dotfiles_backup" "$(dirname "$marker")"
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

# Every config file chezmoi is about to overwrite. The old pixi manifest matters most: `pixi global sync`
# uninstalls whatever isn't in the new one, and this copy is how to get those tools back.
for f in .zshrc .zshenv .zsh_plugins.txt .gitconfig .config/git/ignore .vimrc .ssh/config \
  .config/tmux/tmux.conf .config/starship.toml .config/shell/aliases.sh .pixi/manifests/pixi-global.toml; do
  save copy "$HOME/$f"
done
# These would take precedence over / mix with the new config, so move them out of the way.
save move "$HOME/.tmux.conf"
save move "$HOME/.config/nvim"

# Keep existing ssh hosts working: they become ~/.ssh/config.local, which the new config includes.
# (An old ~/.gitconfig is only backed up; copy what you still need into ~/.gitconfig.local.)
if [ -f "$HOME/.ssh/config" ] && [ ! -e "$HOME/.ssh/config.local" ] \
  && ! grep -q 'Managed by chezmoi' "$HOME/.ssh/config"; then
  cp -a "$HOME/.ssh/config" "$HOME/.ssh/config.local"
fi

if [ -d "$backup" ]; then
  echo "Existing dotfiles saved to ${backup/#$HOME/~}"
fi
touch "$marker"
