#!/bin/sh
# Use colors, but only if connected to a terminal, and that terminal
# supports them.
  if which tput >/dev/null 2>&1; then
      ncolors=$(tput colors)
  fi
  if [ -t 1 ] && [ -n "$ncolors" ] && [ "$ncolors" -ge 8 ]; then
    RED="$(tput setaf 1)"
    GREEN="$(tput setaf 2)"
    YELLOW="$(tput setaf 3)"
    BLUE="$(tput setaf 4)"
    BOLD="$(tput bold)"
    NORMAL="$(tput sgr0)"
  else
    RED=""
    GREEN=""
    YELLOW=""
    BLUE=""
    BOLD=""
    NORMAL=""
  fi

# Error to exit
set -e

# Check and set git
if ! command -v git>/dev/null 2>&1; then
    printf "${YELLOW}Git is not installed! Install first.${NORMAL}\n"i
    exit
fi

read -p "Do you want to set git config? y/[n] >> " text

if [ "$text" = "y" ]; then
    read -p "Input user.name: " name
    git config --global user.name "$name"
    read -p "Input user.email: " email
    git config --global user.email "$email"
fi


# 1.Install Vimrc

if [ -d ~/.vim_runtime ]; then
    mv ~/.vim_runtime ~/.vim_runtime.old
fi

git clone --depth=1 https://github.com/amix/vimrc.git ~/.vim_runtime
sh ~/.vim_runtime/install_awesome_vimrc.sh

## Unwarning go version
echo "let g:go_version_warning = 0" >> ~/.vimrc
## Enable mouse
echo "set mouse=a" >> ~/.vimrc
## Enable nu
echo "set nu" >> ~/.vimrc
## Show hidden files
echo "let NERDTreeShowHidden=1" >> ~/.vimrc

printf "${GREEN}Vimrc done.${NORMAL}\n"


# 2.Install Oh-my-tmux

## Check tmux
if ! command -v tmux>/dev/null 2>&1; then
    printf "${YELLOW}Tmux is not installed! Install first.${NORMAL}\n"
    exit
fi

if [ -d ~/.tmux ]; then
    mv ~/.tmux ~/.tmux.old
fi

git clone https://github.com/gpakosz/.tmux.git ~/.tmux
ln -s -f ~/.tmux/.tmux.conf ~/.tmux.conf
cp ~/.tmux/.tmux.conf.local ~

## Disable auto name
echo "set-option -g allow-rename off" >> ~/.tmux.conf.local
## Enable mouse
echo "set -g mouse on" >> ~/.tmux.conf.local
## Keep directory
echo "bind '%' split-window -h -c '#{pane_current_path}'  # Split panes horizontal" >> ~/.tmux.conf.local
echo "bind '\"' split-window -v -c '#{pane_current_path}'  # Split panes vertically" >> ~/.tmux.conf.local
echo "bind c new-window -c '#{pane_current_path}' # Create new window" >> ~/.tmux.conf.local

printf "${GREEN}Tmux done${NORMAL}\n"


# 3.Add alias

# echo "\nalias nsmi='nvidia-smi'" >> ~/.alias
# echo "\nalias wsmi='watch -n 1 nvidia-smi'" >> ~/.alias
cat .alias >> ~/.alias


# 4.Install Oh-my-zsh

## Check wget or curl
if ! command -v wget >/dev/null 2>&1; then
	printf "${YELLOW}Wget is not installed! Checking Curl${NORMAL}\n"

	if ! command -v curl >/dev/null 2>&1; then
		printf "${YELLOW}Curl is also not installed! Install one of them first.${NORMAL}\n"
		exit
	else
		printf "Find curl.\n"
		curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh --output ~/ohmyzsh_install.sh
	fi
else
	printf "Find wget.\n"
	wget https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O ~/ohmyzsh_install.sh
fi

## substitute the last zsh command in install file
sed -i 's/env zsh -l/# env zsh -l/g' ~/ohmyzsh_install.sh

## install oh my zsh
sh ~/ohmyzsh_install.sh
rm ~/ohmyzsh_install.sh

## change the prompt of robbyrussell to $USER@$HOST
cp .oh-my-zsh/custom/robbyrussell.zsh-theme ~/.oh-my-zsh/custom/

## source alias
echo "\nsource ~/.alias" >> ~/.zshrc


# 5.Anaconda
read -p "Do you want to install Anaconda? y/[n] >> " text

if [ "$text" = "y" ]; then
    echo "Install Anaconda...\n"
    wget https://repo.anaconda.com/archive/Anaconda3-2019.03-Linux-x86_64.sh -O Anaconda3_install.sh
    sh Anaconda3_install.sh
else
    echo "Skip Installation.\n"
fi


# TODO
# matlab


printf "${GREEN}Done!${NORMAL}\n"
