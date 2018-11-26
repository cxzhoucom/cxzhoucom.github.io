#!/bin/bash

clear

# saves the absolute path of the current working directory
CWD=$(pwd)

# default config directory
CONFIG_PATH=$HOME/.local/zconfigs

# if $1 exists, use $1 as config directory
if [ $# -eq 1 ]; then
	if [ -d "$1" ]; then
		CONFIG_PATH="$1"
	else
		echo "$1 dose not exist... use default path"
	fi
fi
echo "set ZHOU_CONFIG_PATH to $CONFIG_PATH"

# include my functions
# . $CONFIG_PATH/scripts/func.sh # 'source' not working with /bin/sh, '.' works
# . ./func.sh # 'source' not working with /bin/sh, '.' works
wget -O /tmp/func.sh http://memo.czhou.cc/scripts/func.sh && . /tmp/func.sh || exit

sudo apt-get update

# if git not exist, install it
installProgramIfNotExist git

# git clone my configs
if [ ! -d $CONFIG_PATH ]; then
	echo "create zconfigs directory."
	mkdir -p $CONFIG_PATH && git clone https://gitlab.com/czhoucc/configs.git $CONFIG_PATH
else
	echo "update zconfigs directory."
	cd $CONFIG_PATH && git pull origin master && cd $CWD
fi

# if zsh not exist, install it
installProgramIfNotExist zsh

# operator > to newly wirte to a file
# operator >> to append to a file
# 
# fill my .zshrc file
backupFileIfExist $HOME/.zshrc
echo "ZHOU_CONFIG_PATH=$CONFIG_PATH" > ~/.zshrc
echo 'source $ZHOU_CONFIG_PATH/antigen/antigenrc' >> ~/.zshrc

# if pip not exist, install it
installProgramIfNotExist pip python-pip

# setup wakatime
pip install wakatime
createSymbolicLinkAndBackupFile $CONFIG_PATH/wakatime/.wakatime.cfg $HOME/.wakatime.cfg

# create symbolic link of .zsh_history
createSymbolicLinkAndBackupFile $CONFIG_PATH/antigen/.zsh_history $HOME/.zsh_history

# if terminator not exist, install it
installProgramIfNotExist terminator
# create symbolic link of terminator config file
createSymbolicLinkAndBackupFile $CONFIG_PATH/terminator/config $HOME/.config/terminator/config

# if vim not exist, install it
installProgramIfNotExist vim
# create symbolic link of vim config file
createSymbolicLinkAndBackupFile $CONFIG_PATH/vim/.vimrc $HOME/.vimrc

# create symbolic link of keyboard mapping
createSymbolicLinkAndBackupFile $CONFIG_PATH/xmodmap/.Xmodmap $HOME/.Xmodmap

# if not already use zsh; change the login shell to zsh
if [[ ! $SHELL =~ "zsh" ]]; then
	echo "change user ($USER) shell to zsh"
	chsh -s $(which zsh) $USER && exec zsh
fi

echo "You are all set, keep working and have fun!"




