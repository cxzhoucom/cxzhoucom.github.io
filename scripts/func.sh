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
	_FILENAME=$(basename -- "$1") # get only file name
	if [ -e $1 ] || [ -L $1 ]; then
		echo "$1 already exist, move it to ~/backup/$_FILENAME"
		mkdir -p $HOME/backup && mv $1 $HOME/backup/$_FILENAME
	fi
}

# backup $2 and create symbolic link to $1
function createSymbolicLinkAndBackupFile () {
	if [ -e $2 ] || [ -L $2 ]; then
		backupFileIfExist $2
	fi
	ln -s $1 $2
	echo "create symbolic link: $1 -> $2"
}

# if program $1 not exist, install it
# $1 is the program name, $2 is the package name in apt-get
function installProgramIfNotExist () {
	if ! [ -x "$(command -v $1)" ]; then
		_PROG_NAME=$1
		if [ $# -eq 2 ]; then # $# variable: the number of input arguments
			_PROG_NAME=$2
		fi
		echo "Error: $1 is not installed." >&2 # redirect 'stdout' (1) to 'stderr' (2)
		echo "install $1: sudo apt-get install $_PROG_NAME"
		sudo apt-get -y install $_PROG_NAME || exit
		echo "$1 is installed."
	else
		echo "$1 is already installed."
	fi
}