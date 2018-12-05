#!/bin/bash

clear

# saves the absolute path of the current working directory
cwd=$(pwd)

# default config directory
config_path=$HOME/.local/zconfigs

# if $1 exists, use $1 as config directory
if [ $# -eq 1 ]; then
	if [ -d "$1" ]; then
		config_path="$1"
	else
		echo "$1 dose not exist... use default path"
	fi
fi
echo "set ZHOU_CONFIG_PATH to $config_path"

# include my functions
# . $config_path/scripts/func.sh # 'source' not working with /bin/sh, '.' works
# . ./func.sh # 'source' not working with /bin/sh, '.' works
wget -O /tmp/func.sh http://memo.czhou.cc/scripts/func.sh && . /tmp/func.sh || exit

# for vscode
wget -O- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
sudo install -o root -g root -m 644 microsoft.gpg /etc/apt/trusted.gpg.d/
sudo sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'
sudo apt-get install apt-transport-https


sudo apt-get update

# if git not exist, install it
installProgramIfNotExist git

# git clone my configs
if [ ! -d $config_path ]; then
	echo "create zconfigs directory."
	mkdir -p $config_path && git clone https://gitlab.com/czhoucc/configs.git $config_path
else
	echo "update zconfigs directory."
	cd $config_path && git pull origin master && cd $cwd
fi

# if zsh not exist, install it
installProgramIfNotExist zsh

# operator > to newly wirte to a file
# operator >> to append to a file
# 
# fill my .zshrc file
backupFileIfExist $HOME/.zshrc
echo "ZHOU_CONFIG_PATH=$config_path" > ~/.zshrc
echo 'source $ZHOU_CONFIG_PATH/antigen/antigenrc' >> ~/.zshrc
echo 'source $HOME/.zshrc.local' >> ~/.zshrc # add local zsh configs, usually are pc-dependent environment variables

# if .zshrc.local not exist, create it and add default values
if [ ! -e $HOME/.zshrc.local ]; then
	echo 'export HOME_CLOUD_PATH="$HOME/HomeCloud"' > ~/.zshrc.local
fi

# if pip not exist, install it
installProgramIfNotExist pip python-pip

# setup wakatime
pip install wakatime
createSymbolicLinkAndBackupFile $config_path/wakatime/.wakatime.cfg $HOME/.wakatime.cfg

# create symbolic link of .zsh_history
createSymbolicLinkAndBackupFile $config_path/antigen/.zsh_history $HOME/.zsh_history

# if terminator not exist, install it
installProgramIfNotExist terminator
# create symbolic link of terminator config file
createSymbolicLinkAndBackupFile $config_path/terminator/config $HOME/.config/terminator/config

# if vim not exist, install it
installProgramIfNotExist vim
# create symbolic link of vim config file
createSymbolicLinkAndBackupFile $config_path/vim/.vimrc $HOME/.vimrc

# create symbolic link of keyboard mapping
createSymbolicLinkAndBackupFile $config_path/xmodmap/.Xmodmap $HOME/.Xmodmap

# if tmux not exist, install it
installProgramIfNotExist tmux
# create symbolic link of tmux config file
createSymbolicLinkAndBackupFile $config_path/tmux/.tmux.conf $HOME/.tmux.conf
createSymbolicLinkAndBackupFile $config_path/tmux/.tmux.conf.local $HOME/.tmux.conf.local

# if vscode not exist, install it
installProgramIfNotExist code
code --install-extension shan.code-settings-sync # https://marketplace.visualstudio.com/items?itemName=Shan.code-settings-sync
copyAndBackupFile $config_path/vscode/User/syncLocalSettings.json $HOME/.config/Code/User/syncLocalSettings.json
copyAndBackupFile $config_path/vscode/User/settings.json $HOME/.config/Code/User/settings.json
echo "Press Shift+Ctrl+D when you first open vscode."



# if not already use zsh; change the login shell to zsh
if [[ ! $SHELL =~ "zsh" ]]; then
	echo "change user ($USER) shell to zsh"
	chsh -s $(which zsh) $USER && exec zsh
fi

echo "You are all set, keep working and have fun!"




