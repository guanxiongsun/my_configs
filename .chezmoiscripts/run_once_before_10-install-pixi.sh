#!/usr/bin/env bash
# Install pixi (https://pixi.sh) into ~/.pixi/bin. No root needed; pixi then installs every other tool.
set -euo pipefail

pixi_home="$HOME/.pixi"
if [ -x "$pixi_home/bin/pixi" ]; then
  exit 0
fi

case "$(uname -m)" in
  x86_64 | amd64) arch=x86_64 ;;
  aarch64 | arm64) arch=aarch64 ;;
  *) echo "pixi: unsupported architecture $(uname -m)" >&2; exit 1 ;;
esac
url="https://github.com/prefix-dev/pixi/releases/latest/download/pixi-${arch}-unknown-linux-musl.tar.gz"

echo "Installing pixi into ${pixi_home/#$HOME/~}/bin"
mkdir -p "$pixi_home/bin"
if command -v curl >/dev/null 2>&1; then
  curl -fsSL --retry 3 "$url"
else
  wget -qO- "$url"
fi | tar -xz -C "$pixi_home/bin" pixi
chmod +x "$pixi_home/bin/pixi"
