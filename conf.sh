#!/bin/bash

if [ ! -d 0tool ]; then
	echo "ERROR 0tool directory doesn't exists or is not a directory, aborting"
	exit
fi
if [ ! -f new.sh ]; then
	echo "ERROR new.sh script doesn't exists or is not a file, aborting"
	exit
fi
read -p "USACO UserName " username
read -sp "Password " password
echo
echo -e "'user':'$username'\n'password':'$password'" > 0tool/config
chmod u+x new.sh
chmod u+x 0tool/*.sh 0tool/*.py
