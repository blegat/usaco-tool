#! /bin/bash

exitclean () {
	if [ -e tmp ] && [ -d tmp ]; then
		rm -r tmp
	fi
	exit
}

taskname=""
let "desc=0"
for arg in $*; do
	case "$arg" in
		-d) let "desc=1"
			;;
		-*)
			;;
		*) taskname=$arg
	esac
done

if [ "$taskname" == "" ]; then
	if [ -e tmp ]; then
		echo "Remove tmp or give a problem name"
		exit
	fi
	mkdir tmp
	cd tmp
	mkdir tmp
	cd tmp
	let "remove=0"
	echo "Getting the input/output for Test0 and the problem name..."
	echo "$desc" | ../../0tool/inout.py
	if [ $? -eq 1 ]; then
		read -p "Do you want to remove the problem environment [y/N]? "
		[ "$REPLY" == "y" ] && let "remove=1"
	fi
	if [ $remove -eq 1 ]; then
		cd ../..
		exitclean
	fi
	taskname=$(cat taskname)
	cd ../..
fi

if [ -e $taskname ]; then
	if [ ! -d $taskname ]; then
		read -p "$taskname already exists and is not a directory. Delete it and proceed [y/N]? "
		[ "$REPLY" == "y" ] || exitclean
		rm $taskname
		mkdir $taskname
	else
		read -p "$taskname already exists. Proceed anyway ? [y/N] "
		[ "$REPLY" == "y" ] || exitclean
	fi
else
	mkdir $taskname
fi
cd $taskname

sed s/"<PROGNAME>"/"$taskname"/g < ../0tool/s.sh > s.sh

user=$(grep 'user' < ../0tool/config | sed s/"[ \t]*[\"']user[\"'][ \t]*:[ \t]*[\"']\(.*\)[\"']"/"\1"/g)
sed -e s/"<USER>"/"$user"/g -e s/"<PROGNAME>"/"$taskname"/g < ../0tool/main.cpp > main.cpp

if [ -e Test0 ]; then
	if [ ! -d Test0 ]; then
		read -p "Test0 already exists and is not a directory. Delete it and proceed [y/N]? "
		cd ..
		[ "$REPLY" == "y" ] || exitclean
		cd $taskname
		rm Test0
		mkdir Test0
	else
		read -p "Test0 already exists. Proceed anyway ? [y/N] "
		cd ..
		[ "$REPLY" == "y" ] || exitclean
		cd $taskname
	fi
else
	mkdir Test0
fi
cd Test0
let "remove=0"
if [ $# -eq 0 ]; then
	mv "../../tmp/tmp/in" ../../tmp/tmp/out ./
	mv ../../tmp/tmp/desc ../
	rm -r ../../tmp
else
	echo "Getting the input/output for Test0..."
	echo -e "$desc\n$taskname" | python ../../0tool/inout.py
	if [ $? -eq 1 ]; then
		read -p "Do you want to remove the problem environment [y/N]? "
		[ "$REPLY" == "y" ] && let "remove=1"
	fi
	if [ $remove -eq 1 ]; then
		cd ../..
		rm -r $taskname
		exitclean
	fi
	mv desc ..
fi
chmod u+x ../s.sh
