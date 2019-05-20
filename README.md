# Introduction
This repo is used for setting up useful config files on a new Linux server(local machine). Including the following configs:
- [The Ultimate vimrc (.vimrc)](https://github.com/amix/vimrc)
- [Oh My Tmux! (.tmux)](https://github.com/gpakosz/.tmux)
- [Oh My Zsh! (.zshrc)](https://github.com/robbyrussell/oh-my-zsh)
- [Useful alias](#Useful-alias)

And some practical modifications on specific files, listed [blew](#Practical-modifications)

Optional:
- [Anaconda](https://www.anaconda.com/distribution/)

# Usage
```
git clone https://github.com/sunguanxiong/my_configs.git
cd my_configs
ln -s $PWD/setup_config.sh ~
cd
sh setup_config.sh
```


# Practical modifications
## Vim
```
## Unwarning go version
echo "\nlet g:go_version_warning = 0" >> ~/.vimrc

## Enable mouse
echo "\nset mouse=a" >> ~/.vimrc

## Enable line number
echo "\nset nu" >> ~/.vimrc

## Show hidden files
echo "\nlet NERDTreeShowHidden=1" >> ~/.vimrc
```

## Tmux
```
## Disable auto name
echo "\nset-option -g allow-rename off" >> ~/.tmux.conf.local

## Enable mouse
echo "\nset -g mouse on" >> ~/.tmux.conf.local

## Keep directory
echo "\nbind '%' split-window -h -c '#{pane_current_path}'  # Split panes horizontal" >> ~/.tmux.conf.local
echo "\nbind '\"' split-window -v -c '#{pane_current_path}'  # Split panes vertically" >> ~/.tmux.conf.local
echo "\nbind c new-window -c '#{pane_current_path}' # Create new window" >> ~/.tmux.conf.local
```
**TODO**:

-[] Vim clipboard
-[] System clipboard

## Oh my zsh
- Do not change to zsh immediately after installation 


# Useful alias
- nsmi: `nvidia-smi`
- wsmi: `watch -n 1 nvidia-smi`

```
echo "\nalias nsmi='nvidia-smi'" >> ~/.alias
echo "\nalias wsmi='watch -n 1 nvidia-smi'" >> ~/.alias
```
