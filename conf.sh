#!/bin/bash

if [ ! -d .tool ]; then
	echo "ERROR .tool directory doesn't exists or is not a directory, aborting"
	exit
fi
if [ ! -f new.sh ]; then
	echo "ERROR new.sh script doesn't exists or is not a file, aborting"
	exit
fi
read -p "USACO UserName " username
read -sp "Password " password
echo
echo -e "'user':'$username'\n'password':'$password'" > .tool/config
chmod u+x new.sh
chmod u+x .tool/*.sh .tool/*.py
