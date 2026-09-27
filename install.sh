#!/usr/bin/env bash
# Bootstrap these dotfiles with chezmoi, without root.
#
#   From anywhere:        bash -c "$(curl -fsSL https://raw.githubusercontent.com/guanxiongsun/my_configs/master/install.sh)"
#   From a local clone:   ./install.sh
#
# Same result as `sh -c "$(curl -fsLS get.chezmoi.io/lb)" -- init --apply guanxiongsun/my_configs`,
# but only needs github.com (handy where get.chezmoi.io is blocked). Extra arguments go to `chezmoi init`,
# e.g. to skip the questions (keys are the prompt texts):
#   ./install.sh --promptString "Git user.name=Your Name" --promptString "Git user.email=you@example.com" \
#     --promptChoice "Install Miniforge (conda) into ~/miniforge3=no"
set -euo pipefail

repo="${DOTFILES_REPO:-guanxiongsun/my_configs}"
branch="${DOTFILES_BRANCH:-}"
bindir="$HOME/.local/bin"

download() {
  if command -v curl >/dev/null 2>&1; then curl -fsSL --retry 3 -o "$2" "$1"; else wget -qO "$2" "$1"; fi
}

if command -v chezmoi >/dev/null 2>&1; then
  chezmoi="$(command -v chezmoi)"
elif [ -x "$bindir/chezmoi" ]; then
  chezmoi="$bindir/chezmoi"
else
  case "$(uname -m)" in
    x86_64 | amd64) arch=amd64 ;;
    aarch64 | arm64) arch=arm64 ;;
    *) echo "unsupported architecture: $(uname -m)" >&2; exit 1 ;;
  esac
  echo "Installing chezmoi into ~/.local/bin"
  mkdir -p "$bindir"
  download "https://github.com/twpayne/chezmoi/releases/latest/download/chezmoi-linux-$arch" "$bindir/chezmoi"
  chmod +x "$bindir/chezmoi"
  chezmoi="$bindir/chezmoi"
fi

script_dir=""
if [ -n "${BASH_SOURCE[0]:-}" ] && [ -f "${BASH_SOURCE[0]}" ]; then
  script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
fi

if [ -n "$script_dir" ] && [ -f "$script_dir/.chezmoi.toml.tmpl" ]; then
  # Running from a clone: use it as chezmoi's source directory.
  exec "$chezmoi" init --apply --source "$script_dir" "$@"
fi
exec "$chezmoi" init --apply ${branch:+--branch "$branch"} "$@" "$repo"
