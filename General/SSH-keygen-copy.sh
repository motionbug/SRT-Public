#!/bin/bash

# This script was developed BY Stony River Technologies (SRT)
# ALL scripts are covered by SRT's Licnese found at:
# https://raw.github.com/stonyrivertech/SRT-Public/master/LICENSE 

# Created by Justin Rummel
# Version 1.0.0 - 11/15/2012

# Modified by
# Version 

### Description 
# The purpose of this script is to generate a SSH keypair, then copy to a remote server 
# so you can SSH into that server without having to type in a password.


### Variables
username="$1"
server="$2"
id_rsa="$HOME/.ssh/id_rsa"
id_rsaPub="$HOME/.ssh/id_rsa.pub"

intro () {
	echo "The purpose of this script is to generate a SSH keypair, then copy to a remote server.
Use the following flags to get info
	-h,-help,--help Dislplay help info

This script expects 
	${0##*/} 'username' 'Target Server FQDN'	# You will be prompted for a password.
	"

exit 0
}

info () {
	echo "This script performs the following actions:

First checking to make sure that a username and FQDN has been passed as input variables.  
I'm not performing any sanity checkes, only verifing that they are not NULL

Next we need to have an id_rsa file to copy to our remote server.  If one is not available, create one.

Finally we will copy the id_rsa.pub fingerprint to our remote server.  A couple of things will (or could) happen:
	1) you WILL be prompted for your password for the username provided on your remote server.  This is OK
	2) if you get a SECOND password prompt.  Something is wrong.  Most likely on your remote server you need
		to create ~/.ssh/ folder because you have never 'SSH' out of your system."

exit 0
}

validate () {
	# since we are checking two variables, we need double brackets
	[[ "${username}" == "" || "${server}" == "" ]] && { intro; }

	echo "First lets verify you have an id_rsa key in ~/.ssh folder.  If not, I'll create one for you."
	generate

	# validate id_rsa file exists
	[ -e "${id_rsa}" ] && { echo "id_rsa is available"; } || { echo "ERROR: Something went wrong.  I'll stop now"; exit 1; }

	copyID
}

generate () {
	[ ! -e "${id_rsa}" ] && { ssh-keygen -t rsa -N "" -f ~/.ssh/id_rsa; }
}

copyID () {
	echo "Copy our id_rsa.pub file to remote server.  This will prompt for your password (for the last time!)"
	ssh -q "${username}@${server}" "mkdir ~/.ssh 2>/dev/null; chmod 700 ~/.ssh; echo `cat $id_rsaPub` >> ~/.ssh/authorized_keys"
#	scp "${id_rsaPub}" "${username}@${server}":.ssh/authorized_keys

	# Security
	chmod 400 "${id_rsaPub}"
}

case "$1" in
	-h)
		info
		;;

	-help)
		info
		;;

	--help)
		info
		;;
	*)
		validate
esac