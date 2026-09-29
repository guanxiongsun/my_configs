# my_configs

My dotfiles, managed with [chezmoi](https://www.chezmoi.io). One command sets up a new Linux machine,
**no sudo needed**: everything installs into `$HOME`. Built for shared/GPU servers.

Want this setup on your own servers? [Fork it](#use-it-for-your-own-servers) and install from your fork.

## Install

```sh
sh -c "$(curl -fsLS get.chezmoi.io/lb)" -- init --apply guanxiongsun/my_configs
```

If `get.chezmoi.io` is blocked, this does the same thing and only needs github.com:

```sh
bash -c "$(curl -fsSL https://raw.githubusercontent.com/guanxiongsun/my_configs/master/install.sh)"
```

It asks three things once per machine: your git name, your git email, and whether to install Miniforge.
Answer the Miniforge question with `y` or `n` (Enter means no). The answers are stored in
`~/.config/chezmoi/chezmoi.toml`, never in this repo; to change them later run `chezmoi init --prompt`
followed by `chezmoi apply`. Then it:

1. backs up any existing dotfiles to `~/.dotfiles_backup/<time>/`;
2. installs [pixi](https://pixi.sh) and, through it, all the tools below (prebuilt conda-forge
   packages in `~/.pixi`);
3. writes the config files and downloads the zsh, tmux and Neovim plugins;
4. makes interactive logins start zsh (no `chsh` needed, see below);
5. creates an SSH key for this machine and registers it with GitHub (see below).

Log out and back in, or run `exec zsh`, to start using it.

Prerequisites on the machine: `git` (2.19 or newer), `curl` or `wget`, and `tar`. Neovim's syntax
parsers also need a C compiler (`gcc`); see [Troubleshooting](#troubleshooting) if there is none.

## What you get

| Area | Tools and config |
|---|---|
| Shell | zsh + [antidote](https://antidote.sh) plugins (autosuggestions, fast-syntax-highlighting, completions, oh-my-zsh `git`/`extract`/`ssh-agent`), [Starship](https://starship.rs) prompt showing `user@host`, git and conda env. `Up`/`Down` search history for what you've typed (`ssh` + `Up` recalls your last `ssh ...`). Starts in about 50 ms. |
| Terminal | tmux (`~/.config/tmux/tmux.conf`): prefix `C-b` or `C-a`, mouse on, splits and new windows keep the current directory, vi copy mode (`v`, `C-v` block, `y`), OSC 52 clipboard, catppuccin theme via tpm. Pop-ups: `prefix g` lazygit, `prefix G` nvitop, `prefix t` scratch shell. Sessions are saved every 15 min and come back after a reboot (tmux-resurrect + continuum; `prefix C-s` / `C-r` to save/restore by hand). |
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

## Use it for your own servers

You're welcome to use these dotfiles on your own machines ([MIT license](LICENSE)). Install them from a
fork rather than from this repo: `chezmoi update` pulls from the repo you installed from, so with this
one you'd get whatever I push next, and your own changes would have nowhere to go.

1. Fork this repo on GitHub. Forks of public repos are public too, so keep private hostnames and anything
   secret in the `*.local` files listed under [Everyday use](#everyday-use), not in the repo.
2. Install from your fork, with your GitHub username in place of `YOUR_USERNAME`:
   ```sh
   sh -c "$(curl -fsLS get.chezmoi.io/lb)" -- init --apply YOUR_USERNAME/my_configs
   ```
   If `get.chezmoi.io` is blocked:
   ```sh
   DOTFILES_REPO=YOUR_USERNAME/my_configs bash -c "$(curl -fsSL https://raw.githubusercontent.com/YOUR_USERNAME/my_configs/master/install.sh)"
   ```
   So that your fork's own README installs your fork, change `guanxiongsun` to your username in the two
   commands under [Install](#install) and in the `repo=` line of `install.sh`.
3. Make it yours with the commands under [Everyday use](#everyday-use), then commit and push to your
   fork. `chezmoi update` brings the changes to your other machines.
4. To get later changes from this repo, click **Sync fork** on your fork's GitHub page, then run
   `chezmoi update`.

Before you run it on a machine you already use, know that it:

- replaces your shell, git, vim/Neovim, tmux and SSH config. The old files are saved to
  `~/.dotfiles_backup/<time>/` and your SSH hosts keep working from `~/.ssh/config.local`, but settings
  in an old `~/.gitconfig` don't carry over: copy what you still need into `~/.gitconfig.local`;
- makes interactive logins start zsh, through a block it adds to your bash login file
  (see [No sudo? No problem](#no-sudo-no-problem));
- sends every `git push` to GitHub over SSH, even in repos cloned over HTTPS. If you push with an HTTPS
  token instead, delete the `[url "git@github.com:"]` block from `dot_gitconfig.tmpl` in your fork;
- creates `~/.ssh/id_ed25519` if you don't have one and offers to add it to your GitHub account;
- replaces `~/.pixi/manifests/pixi-global.toml`, and `pixi global sync` then uninstalls every tool that
  isn't in the new one. If you already use `pixi global`, add your tools to your fork's
  `dot_pixi/manifests/pixi-global.toml` before installing, or copy them back from the backup afterwards.

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
  `ssh -t host NO_ZSH=1 bash -l`. (`chsh` won't accept `~/.pixi/bin/zsh` unless an admin lists it in
  `/etc/shells`, which is why the hand-off exists.)
- **Shared (NFS) home directories** across cluster nodes are fine: ssh-agent state is kept per host.

## Troubleshooting

- **Boxes or `?` in the tmux status bar or Neovim:** install a [Nerd Font](https://www.nerdfonts.com) (for example JetBrainsMono Nerd Font) and select it in the terminal on your laptop.

- **pixi downloads are slow or blocked** (for example from mainland China): point conda-forge at a mirror in
  `~/.pixi/config.toml`:
  ```toml
  [mirrors]
  "https://prefix.dev/conda-forge" = ["https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud/conda-forge"]
  "https://conda.anaconda.org/conda-forge" = ["https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud/conda-forge"]
  ```
- **Neovim says "No C compiler found" when installing syntax parsers:** the machine has no `gcc`.
  Without root, uncomment the `c-compiler` block in `~/.pixi/manifests/pixi-global.toml` (use
  `chezmoi edit`) and run `chezmoi apply`.
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

## License

[MIT](LICENSE). The Neovim config in `dot_config/nvim/` started from the
[LazyVim starter](https://github.com/LazyVim/starter) (Apache-2.0).
