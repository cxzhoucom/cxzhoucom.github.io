#!/bin/bash

clear

# saves the absolute path of the current working directory
cwd=$(pwd)

pc_type="normal"
while true; do
    read -p "[$(date)] Plese select the computer type (1 normal; 2 server): " yn
    case $yn in
        [1]* ) break;;
        [2]* ) pc_type="server"; echo "[$(date)] You are on server, will not install X software"; break;;
        * ) echo "[$(date)] Please input 1 or 2.";;
    esac
done

# use UPDATE to create configs symlink from Dropbox
setup_type="first"
if [ "$pc_type" = "server" ]; then
	while true; do
		read -p "[$(date)] Plese select the setup type (1 first time; 2 update): " yn
		case $yn in
			[1]* ) break;;
			[2]* ) setup_type="update"; echo "[$(date)] You are update the configs, will NOT git clone your configs"; break;;
			* ) echo "[$(date)] Please input 1 or 2.";;
		esac
	done
fi

# default config directory
config_path=$HOME/.local/zconfigs

# if $1 exists, use $1 as config directory
if [ $# -eq 1 ]; then
	if [ -d "$1" ]; then
		config_path="$1"
	else
		echo "[$(date)] $1 dose not exist... use default path"
	fi
fi
echo "[$(date)] set ZHOU_CONFIG_PATH to $config_path"

# include my functions
# . $config_path/scripts/func.sh # 'source' not working with /bin/sh, '.' works
# . ./func.sh # 'source' not working with /bin/sh, '.' works
wget -O /tmp/func.sh http://memo.czhou.cc/scripts/func.sh && . /tmp/func.sh || exit

echo "[$(date)] Adding PPAs"

if [ "$pc_type" = "normal" ]; then
	# add vscode repository
	wget -O- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > /tmp/microsoft.gpg
	sudo install -o root -g root -m 644 /tmp/microsoft.gpg /etc/apt/trusted.gpg.d/
	sudo sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'
	sudo apt-get install apt-transport-https

	# add chrome repository
	wget -O- https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
	sudo sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list'

	# add Synapse repository
	sudo add-apt-repository -y ppa:synapse-core/ppa

	# add shutter repository
	sudo add-apt-repository -y ppa:shutter/ppa

	# add nextcloud repository
	sudo add-apt-repository -y ppa:nextcloud-devs/client
fi

if [ "$pc_type" = "server" ]; then
	curl -fsSL https://get.docker.com -o get-docker.sh
	sudo sh get-docker.sh
	apt install docker-compose
fi


echo "[$(date)] Updating repositories"
sudo apt-get update

sudo apt-get install build-essential cmake cmake-curses-gui python3-dev python3-pip ctags

# if git not exist, install it
installProgramIfNotExist git

if [ "$setup_type" = "first" ]; then
	# git clone my configs
	if [ ! -d $config_path ]; then
		echo "[$(date)] Creating zconfigs directory."
		mkdir -p $config_path && git clone https://gitlab.com/czhoucc/configs.git $config_path
	else
		echo "[$(date)] Updating zconfigs directory."
		cd $config_path && git pull origin master && cd $cwd
	fi
elif [ "$setup_type" = "update" ]; then
	if ! [ -x "$(command -v dropbox)" ]; then
		echo "[$(date)] Dropbox is not installed."
		exit
	else
		createSymbolicLinkAndBackupFile $HOME/Dropbox/codes/configs $config_path
	fi
else
	echo "[$(date)] Not correct setup_type."
	exit
fi

# if zsh not exist, install it
installProgramIfNotExist zsh

# operator > to newly wirte to a file
# operator >> to append to a file
# 
# fill my .zshrc file
backupFileIfExist $HOME/.zshrc
echo "ZHOU_CONFIG_PATH=$config_path" > ~/.zshrc
echo 'source $ZHOU_CONFIG_PATH/zsh/antigenrc' >> ~/.zshrc
echo 'source $HOME/.zshrc.local' >> ~/.zshrc # add local zsh configs, usually are pc-dependent environment variables

# if .zshrc.local not exist, create it and add default values
if [ ! -e $HOME/.zshrc.local ]; then
	echo 'export HOME_CLOUD_PATH="$HOME/HomeCloud"' > ~/.zshrc.local
	if [ "$pc_type" = "normal" ]; then
		echo 'export HISTFILE="$ZHOU_CONFIG_PATH/zsh/.zsh_history"' >> ~/.zshrc.local
	fi
fi

# for python2
# if pip not exist, install it
# installProgramIfNotExist pip python-pip
# sudo apt-get install -y python-setuptools

# setup wakatime
# pip install wakatime
# createSymbolicLinkAndBackupFile $config_path/wakatime/.wakatime.cfg $HOME/.wakatime.cfg

# create symbolic link of .zsh_history
createSymbolicLinkAndBackupFile $config_path/zsh/.zsh_history $HOME/.zsh_history

# create symbolic link of gitignore_global
createSymbolicLinkAndBackupFile $config_path/git/ignore $HOME/.config/git/ignore

# if vim not exist, install it
installProgramIfNotExist vim
git clone https://github.com/VundleVim/Vundle.vim.git $HOME/.vim/bundle/Vundle.vim
echo "[$(date)] in vim, run :PluginInstall"
echo "[$(date)] then, cd ~/.vim/bundle/YouCompleteMe"
echo "[$(date)] then, python3 install.py --all"
# create symbolic link of vim config file
createSymbolicLinkAndBackupFile $config_path/vim/.vimrc $HOME/.vimrc

# create symbolic link of keyboard mapping
createSymbolicLinkAndBackupFile $config_path/xmodmap/.Xmodmap $HOME/.Xmodmap

# if tmux not exist, install it
installProgramIfNotExist tmux
# create symbolic link of tmux config file
createSymbolicLinkAndBackupFile $config_path/tmux/.tmux.conf $HOME/.tmux.conf
createSymbolicLinkAndBackupFile $config_path/tmux/.tmux.conf.local $HOME/.tmux.conf.local

# if rg not exist, install it
# installProgramIfNotExist rg ripgrep # for Ubuntu 18.10 or above

# if tree not exist, install it
installProgramIfNotExist tree

# install rg
curl -LO https://github.com/BurntSushi/ripgrep/releases/download/11.0.1/ripgrep_11.0.1_amd64.deb
sudo dpkg -i ripgrep_11.0.1_amd64.deb && rm ripgrep_11.0.1_amd64.deb

# install softwares with X window
if [ "$pc_type" = "normal" ]; then
	# if terminator not exist, install it
	installProgramIfNotExist terminator
	# create symbolic link of terminator config file
	createSymbolicLinkAndBackupFile $config_path/terminator/config $HOME/.config/terminator/config

	# if vscode not exist, install it and setup settings-sync extension
	installProgramIfNotExist code
	code --install-extension shan.code-settings-sync # https://marketplace.visualstudio.com/items?itemName=Shan.code-settings-sync
	copyAndBackupFile $config_path/vscode/User/syncLocalSettings.json $HOME/.config/Code/User/syncLocalSettings.json
	copyAndBackupFile $config_path/vscode/User/settings.json $HOME/.config/Code/User/settings.json
	echo "[$(date)] Press Shift+Ctrl+D when you first open vscode."

	# if chrome not exist, install it
	installProgramIfNotExist google-chrome google-chrome-stable

	# if synapse not exist, install it
	installProgramIfNotExist synapse
	# create symbolic link of synapse config file
	createSymbolicLinkAndBackupFile $config_path/synapse/config.json $HOME/.config/synapse/config.json

	# if shutter not exist, install it
	installProgramIfNotExist shutter
	# TODO: need to add Ctrl+a shortcut later

	# if kazam not exist, install it
	installProgramIfNotExist kazam

	# if goldendict not exist, install it
	installProgramIfNotExist goldendict
	# TODO: setup dictionaries later

	# if meld not exist, install it
	installProgramIfNotExist meld

	# if meld not exist, install it
	installProgramIfNotExist nextcloud nextcloud-client
fi


if [ "$pc_type" = "server" ]; then
	docker pull zerotier/zerotier-containerized
	mkdir -p /var/lib/zerotier-one && git clone https://gitlab.com/czhoucc/zerotier-vultr.git /var/lib/zerotier-one
	docker run --device=/dev/net/tun --net=host --cap-add=NET_ADMIN --cap-add=SYS_ADMIN -d -v /var/lib/zerotier-one:/var/lib/zerotier-one --name=zerotier-one zerotier/zerotier-containerized
	# docker exec zerotier-one /zerotier-cli join 1d71939404566c40
fi


# if not already use zsh; change the login shell to zsh
if [[ ! $SHELL =~ "zsh" ]]; then
	echo "[$(date)] Changing user ($USER) shell to zsh"
	chsh -s $(which zsh) $USER && exec zsh
fi

echo "[$(date)] You are all set, keep working and have fun!"




