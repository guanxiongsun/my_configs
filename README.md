# my_configs

My dotfiles, managed with [chezmoi](https://www.chezmoi.io). One command sets up a new Linux machine,
**no sudo needed**: everything installs into `$HOME`. Built for shared/GPU servers.

## Install

```sh
sh -c "$(curl -fsLS get.chezmoi.io/lb)" -- init --apply guanxiongsun/my_configs
```

If `get.chezmoi.io` is blocked, this does the same thing and only needs github.com:

```sh
bash -c "$(curl -fsSL https://raw.githubusercontent.com/guanxiongsun/my_configs/master/install.sh)"
```

It asks three things once per machine: your git name, your git email, and whether to install Miniforge.
The answers are stored in `~/.config/chezmoi/chezmoi.toml`, never in this repo. Then it:

1. backs up any existing dotfiles to `~/.dotfiles_backup/<time>/`;
2. installs [pixi](https://pixi.sh) and, through it, all the tools below (prebuilt conda-forge
   packages in `~/.pixi`);
3. writes the config files and downloads the zsh, tmux and Neovim plugins;
4. makes interactive logins start zsh (no `chsh` needed, see below);
5. creates an SSH key for this machine and registers it with GitHub (see below).

Log out and back in, or run `exec zsh`, to start using it.

## What you get

| Area | Tools and config |
|---|---|
| Shell | zsh + [antidote](https://antidote.sh) plugins (autosuggestions, fast-syntax-highlighting, completions, oh-my-zsh `git`/`extract`/`ssh-agent`), [Starship](https://starship.rs) prompt showing `user@host`, git and conda env. Starts in about 50 ms. |
| Terminal | tmux (`~/.config/tmux/tmux.conf`): prefix `C-b` or `C-a`, mouse on, splits and new windows keep the current directory, vi copy mode, OSC 52 clipboard, catppuccin theme via tpm |
| Editor | Neovim + [LazyVim](https://www.lazyvim.org) (`~/.config/nvim`), plus a minimal `~/.vimrc` for plain vim |
| CLI | fzf (`Ctrl-R` history, `Ctrl-T` files), ripgrep, fd, bat, eza (`ls`/`ll`/`la`/`lt`), zoxide (`z`) |
| Git | gh, lazygit (`lg`), delta diffs, handy aliases, clone over HTTPS and push over SSH automatically |
| Python | uv. Optional Miniforge in `~/miniforge3`: `conda activate <env>`, and `conda init` is never needed. |
| GPU/servers | btop, nvitop (`gpu`), `nsmi` / `wsmi` for `nvidia-smi` / `watch -n 1 nvidia-smi` |

## Everyday use

```sh
chezmoi edit ~/.zshrc     # edit a managed file (opens the repo copy)
chezmoi apply             # apply your edits
chezmoi update            # pull the latest from GitHub and apply
chezmoi diff              # preview changes
dots                      # cd into the repo (alias for `chezmoi cd`), then commit and push as usual
```

**Adding a tool:** edit `~/.pixi/manifests/pixi-global.toml` with `chezmoi edit`, then run `chezmoi apply`;
`pixi global sync` runs automatically. Search for packages with `pixi search <name>`.

**Machine-specific settings** go in these files. They're never in the repo, and they win over the shared config:

| File | For |
|---|---|
| `~/.zshrc.local` | extra shell settings, module loads, CUDA paths |
| `~/.gitconfig.local` | per-machine git settings (for example a work email) |
| `~/.ssh/config.local` | your SSH hosts (keeps private hostnames out of this public repo) |

## GitHub SSH access

Each machine gets **its own key**. No private key is ever stored in this repo, which is public. On first
install, `github-ssh-setup`:

- creates `~/.ssh/id_ed25519` if it doesn't exist;
- uploads the public key with `gh`: approve a one-time code at github.com/login/device from your phone
  or laptop, which works on headless servers. Afterwards it offers to log gh out again;
- if you'd rather paste the key, prints it for https://github.com/settings/ssh/new;
- switches GitHub SSH to port 443 (`ssh.github.com`) if the network blocks port 22.

Re-run `github-ssh-setup` any time; it does nothing once `ssh -T git@github.com` works. If you lose a
machine, delete just that key at https://github.com/settings/keys.

## No sudo? No problem

- **Tools** come from conda-forge via pixi, prebuilt, so there's nothing to compile.
- **Login shell:** `chsh` usually isn't allowed on shared servers, so a small block in your bash login
  file (`~/.profile` or `~/.bash_profile`) hands interactive terminal logins over to zsh. `scp`,
  `rsync`, `ssh host cmd` and editors' `bash -lic` stay on bash. To get plain bash once:
  `ssh -t host NO_ZSH=1 bash -l`. If you can use `chsh`, `chsh -s ~/.pixi/bin/zsh` works too.
- **Shared (NFS) home directories** across cluster nodes are fine: ssh-agent state is kept per host.

## Troubleshooting

- **pixi downloads are slow or blocked** (for example from mainland China): point conda-forge at a mirror in
  `~/.pixi/config.toml`:
  ```toml
  [mirrors]
  "https://prefix.dev/conda-forge" = ["https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud/conda-forge"]
  ```
- **Something went wrong midway:** fix it and run `chezmoi apply` again. Every step is safe to repeat.
- **Old configs:** your previous dotfiles are in `~/.dotfiles_backup/`.

## Repo layout

Filenames follow chezmoi's [naming rules](https://www.chezmoi.io/reference/source-state-attributes/):
`dot_zshrc` becomes `~/.zshrc`, `private_` sets permissions to 0600/0700, and `executable_` makes the file executable.

```
.chezmoi.toml.tmpl        per-machine questions (git name/email, Miniforge)
.chezmoiexternal.toml     antidote + tpm (fetched and refreshed weekly by chezmoi)
.chezmoiscripts/          setup steps: backup, pixi, tool sync, Miniforge, zsh handoff, plugins, GitHub SSH
dot_pixi/manifests/       pixi-global.toml: the list of installed tools
dot_zshenv  dot_zshrc  dot_zsh_plugins.txt
dot_config/               starship.toml, tmux/, nvim/ (LazyVim), git/ignore, shell/aliases.sh
dot_gitconfig.tmpl  dot_vimrc  private_dot_ssh/
dot_local/bin/            github-ssh-setup
install.sh                bootstrap that needs only github.com
```
