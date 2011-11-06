if [ ! -d 0tool ]; then
	echo "ERROR 0tool directory doesn't exists or is not a directory, aborting"
	exit
fi
if [ ! -f new.sh ]; then
	echo "ERROR new.sh script doesn't exists or is not a file, aborting"
	exit
fi
read -p "USACO UserName " username
read -p "Password " username
echo -e "user:$user\npassword:$password\n" > 0tool/config
chmod u+x new.sh
