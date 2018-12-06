#!/bin/bash

# Notes
# '': cannot use $VAR
# "": can use $VAR



######################################################################

# -e: Return true value if file exists.
# -f: Return true value if file exists and regular file.
# -r: Return true value if file exists and is readable.
# -w: Return true value if file exists and is writable.
# -x: Return true value if file exists and is executable.
# -d: Return true value if exists and is a directory.
# -L: Return true value if file is a symbolic link.
#
# if file $1 already exists, move it to ~/backup
function backupFileIfExist () {
	local _file_name=$(basename -- "$1") # get only file name
	if [ -e $1 ] || [ -L $1 ]; then
		echo "[$(date)] $1 already exist, move it to ~/backup/$_file_name"
		mkdir -p $HOME/backup && mv $1 $HOME/backup/$_file_name
	fi
}

# backup $2 and create symbolic link to $1
function createSymbolicLinkAndBackupFile () {
	if [ -e $2 ] || [ -L $2 ]; then
		backupFileIfExist $2
	fi
	local _symlink_path=$(dirname -- "$2") # get only dir name
	if [ ! -e $_symlink_path ]; then
		mkdir -p $_symlink_path
	fi
	ln -s $1 $2
	echo "[$(date)] create symbolic link: $1 -> $2"
}


# backup $2 and copy to $1
function copyAndBackupFile () {
	if [ -e $2 ] || [ -L $2 ]; then
		backupFileIfExist $2
	fi
	local _destination_path=$(dirname -- "$2") # get only dir name
	if [ ! -e $_destination_path ]; then
		mkdir -p $_destination_path
	fi
	cp $1 $2
	echo "[$(date)] create symbolic link: $1 -> $2"
}

# if program $1 not exist, install it
# $1 is the program name, $2 is the package name in apt-get
function installProgramIfNotExist () {
	if ! [ -x "$(command -v $1)" ]; then
		local _prog_name=$1
		if [ $# -eq 2 ]; then # $# variable: the number of input arguments
			_prog_name=$2
		fi
		echo "[$(date)] Error: $1 is not installed." >&2 # redirect 'stdout' (1) to 'stderr' (2)
		echo "[$(date)] install $1: sudo apt-get install $_prog_name"
		sudo apt-get -y install $_prog_name || exit
		echo "[$(date)] $1 is installed."
	else
		echo "[$(date)] $1 is already installed."
	fi
}