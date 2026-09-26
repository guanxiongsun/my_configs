# Aliases, sourced by ~/.zshrc. Managed by chezmoi (github.com/guanxiongsun/my_configs).

# GPU
alias nsmi='nvidia-smi'
alias wsmi='watch -n 1 nvidia-smi'
command -v nvitop >/dev/null 2>&1 && alias gpu='nvitop'

alias cl='clear'

# Modern replacements, only where installed.
if command -v eza >/dev/null 2>&1; then
  alias ls='eza --group-directories-first'
  alias ll='eza -lh --git --group-directories-first'
  alias la='eza -lah --git --group-directories-first'
  alias lt='eza --tree --level=2'
fi
command -v nvim >/dev/null 2>&1 && alias vi='nvim'
command -v lazygit >/dev/null 2>&1 && alias lg='lazygit'

# Dotfiles
alias dots='chezmoi cd'
