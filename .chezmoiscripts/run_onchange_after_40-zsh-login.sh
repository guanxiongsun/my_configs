#!/usr/bin/env bash
# Make zsh the interactive shell without chsh (which needs sudo, or fails for LDAP accounts):
# add a marked block to the login file bash actually reads, which hands interactive logins over to zsh.
# Non-interactive logins (scp, rsync, `ssh host cmd`, VS Code's server) stay on bash.
set -euo pipefail

begin='# >>> my_configs: zsh handoff >>>'
end='# <<< my_configs: zsh handoff <<<'
read -r -d '' block <<'EOF' || true
# >>> my_configs: zsh handoff >>>
# Managed by chezmoi (github.com/guanxiongsun/my_configs). Tools installed by pixi live in ~/.pixi/bin.
case ":$PATH:" in *":$HOME/.pixi/bin:"*) ;; *) PATH="$HOME/.local/bin:$HOME/.pixi/bin:$PATH"; export PATH ;; esac
# Interactive terminal logins switch to zsh. Stay in bash for one login with:  ssh -t host NO_ZSH=1 bash -l
# (`bash -lic 'cmd'`, as used by editors to read the environment, keeps running cmd in bash.)
case $- in
  *i*)
    if [ -z "${ZSH_VERSION:-}" ] && [ -z "${NO_ZSH:-}" ] && [ -z "${BASH_EXECUTION_STRING:-}" ] && [ -t 0 ]; then
      for _zsh in "$HOME/.pixi/bin/zsh" /usr/bin/zsh /bin/zsh; do
        if [ -x "$_zsh" ] && "$_zsh" -c 'exit 0' >/dev/null 2>&1; then
          SHELL="$_zsh"; export SHELL
          exec "$_zsh" -l
        fi
      done
      unset _zsh
    fi
    ;;
esac
# <<< my_configs: zsh handoff <<<
EOF

# bash reads the first of these that exists for login shells.
target=""
for f in .bash_profile .bash_login .profile; do
  if [ -f "$HOME/$f" ]; then target="$HOME/$f"; break; fi
done
if [ -z "$target" ]; then
  target="$HOME/.bash_profile"
  # shellcheck disable=SC2016 # written literally; expands when bash reads the file
  printf '%s\n' '[ -f "$HOME/.bashrc" ] && . "$HOME/.bashrc"' >"$target"
fi

# Replace an existing block (if any) with the current one; append otherwise.
tmp="$(mktemp)"
awk -v b="$begin" -v e="$end" '$0 == b { skip = 1 } !skip { print } $0 == e { skip = 0 }' "$target" >"$tmp"
printf '\n%s\n' "$block" >>"$tmp"
# Collapse the blank lines a replaced block could leave behind.
cat -s "$tmp" >"$target"
rm -f "$tmp"
echo "zsh handoff installed in ${target/#$HOME/~}"
