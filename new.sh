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

guess=false
if [ "$taskname" == "" ]; then
	guess=true
	if [ -e tmp ]; then
		echo "Remove tmp or give a problem name"
		exit
	fi
	mkdir tmp
	cd tmp
	mkdir tmp
	cd tmp
	remove=false
	echo "Getting the input/output for Test0 and the problem name..."
	echo "$desc" | ../../.tool/inout.py
	if [ $? -eq 1 ]; then
		read -p "Do you want to remove the problem environment [y/N]? "
		[[ "$REPLY" == "y" || ! -f taskname ]] && remove=true
	fi
	if $remove; then
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
		read -p "$taskname already exists. Proceed anyway [y/N]? "
		[ "$REPLY" == "y" ] || exitclean
	fi
else
	mkdir $taskname
fi
cd $taskname

sed s/"<PROGNAME>"/"$taskname"/g < ../.tool/s.sh > s.sh

user=$(grep 'user' < ../.tool/config | sed s/"[ \t]*[\"']user[\"'][ \t]*:[ \t]*[\"']\(.*\)[\"']"/"\1"/g)
sed -e s/"<USER>"/"$user"/g -e s/"<PROGNAME>"/"$taskname"/g < ../.tool/main.cpp > main.cpp

if [ -e Test0 ]; then
	if [ ! -d Test0 ]; then
		read -p "Test0 already exists and is not a directory. Delete it and proceed [y/N]? "
		cd ..
		[ "$REPLY" == "y" ] || exitclean
		cd $taskname
		rm Test0
		mkdir Test0
	else
		read -p "Test0 already exists. Proceed anyway [y/N]? "
		cd ..
		[ "$REPLY" == "y" ] || exitclean
		cd $taskname
	fi
else
	mkdir Test0
fi
cd Test0
remove=false
if $guess; then # inout.py has already been called to find the taskname
	mv '../../tmp/tmp/in' '../../tmp/tmp/out' './'
	if [ $desc -eq 1 ]; then
		mv ../../tmp/tmp/desc.html ../
	fi
	rm -r ../../tmp
else
	echo "Getting the input/output for Test0..."
	echo -e "$desc\n$taskname" | python ../../.tool/inout.py
	if [ $? -eq 1 ]; then
		read -p "Do you want to remove the problem environment [y/N]? "
		[ "$REPLY" == "y" ] && remove=true
	fi
	if $remove; then
		cd ../..
		rm -r $taskname
		exitclean
	fi
	if [ $desc -eq 1 ]; then
		mv desc.html ..
	fi
fi
chmod u+x ../s.sh
