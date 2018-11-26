#!/bin/bash

CONFIG_PATH="$1"
if [ $# -ne 1 ]; then
    echo "Usage: $0 {configs-dir-name}"
    exit 1
fi

# if input CONFIG_PATH doesn't exist, reset to default, if default doesn't exist, exit.
if [ ! -d "$CONFIG_PATH" ]; then
	echo "$CONFIG_PATH dose not exist..."
	CONFIG_PATH=$HOME/HomeCloud/appdata # set default path
	if [ ! -d "$CONFIG_PATH" ]; then
		echo "Please check your path and run this script again."
		exit 1
	fi
fi
echo "set ZHOU_CONFIG_PATH to $CONFIG_PATH"

# sudo apt-get update

# include my functions
. $CONFIG_PATH/script/func.sh # 'source' not working with /bin/sh, '.' works


# if zsh not exist, install it
installProgramIfNotExist zsh

# operator > to newly wirte to a file
# operator >> to append to a file
# 
# fill my .zshrc file
backupFileIfExist $HOME/.zshrc
echo "ZHOU_CONFIG_PATH=$CONFIG_PATH" > ~/.zshrc
echo 'source $ZHOU_CONFIG_PATH/antigen/antigenrc' >> ~/.zshrc

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

echo "change user ($USER) shell to zsh"
chsh -s $(which zsh) $USER && exec zsh





