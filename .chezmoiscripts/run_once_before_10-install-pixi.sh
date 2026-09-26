#!/usr/bin/env bash
# Install pixi (https://pixi.sh) into ~/.pixi/bin. No root needed; pixi then installs every other tool.
set -euo pipefail

PIXI_HOME="${PIXI_HOME:-$HOME/.pixi}"
if [ -x "$PIXI_HOME/bin/pixi" ]; then
  exit 0
fi

case "$(uname -m)" in
  x86_64 | amd64) arch=x86_64 ;;
  aarch64 | arm64) arch=aarch64 ;;
  *) echo "pixi: unsupported architecture $(uname -m)" >&2; exit 1 ;;
esac
url="https://github.com/prefix-dev/pixi/releases/latest/download/pixi-${arch}-unknown-linux-musl.tar.gz"

echo "Installing pixi into ${PIXI_HOME/#$HOME/~}/bin"
mkdir -p "$PIXI_HOME/bin"
if command -v curl >/dev/null 2>&1; then
  curl -fsSL --retry 3 "$url"
else
  wget -qO- "$url"
fi | tar -xz -C "$PIXI_HOME/bin" pixi
chmod +x "$PIXI_HOME/bin/pixi"
