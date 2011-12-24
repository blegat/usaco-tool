#!/bin/bash

catbef () {
	#cat $1 | while read line; do for i in $(seq $2); do echo -en "\t"; done; echo $line; done
	cat $1 | while read line; do echo -e "$2$line"; done
}

cleanup () {
	if [ -e /tmp/standardoutput ] && [ -f /tmp/standardoutput ]; then
		rm /tmp/standardoutput
	fi
	if [ -e $1.in ] && [ -f $1.in ]; then
		rm $1.in
	fi
	if [ -e $1.out ] && [ -f $1.out ]; then
		rm $1.out
	fi
}

testn () {
	cp Test$1/in $3.in
	if $2 ; then
		gdb a.out
		cleanup $3
		exit
	else
		timeinfo=$( { /usr/bin/time -f "timeinfo:%U/%M:ofniemit" ./a.out > /tmp/standardoutput; } 2>&1 )
		let "exitstatus=$?"
		if [ $exitstatus -ne 0 ]; then
			let "exitstatus-=128" # see man time -> Diagnostic for why "-128"
		fi
		timing=$(echo $timeinfo | egrep 'timeinfo:[0-9.]*\/[0-9.]*:ofniemit' | sed s/".*timeinfo:\([0-9.]*\)\/\([0-9.]*\):ofniemit.*"/"\1"/g)
		memory=$(echo $timeinfo | egrep 'timeinfo:[0-9.]*\/[0-9.]*:ofniemit' | sed s/".*timeinfo:\([0-9.]*\)\/\([0-9.]*\):ofniemit.*"/"\2"/g)
	fi

	if [ $exitstatus -eq 0 ] && [ "`tail -c 1 $3.out`" = "" ] && [ "`cat $3.out`" = "`cat Test$1/out`" ]; then
		echo "   Test $1: TEST OK [$timing secs, $memory KB]"
	else
		if [ $exitstatus -eq 0 ]; then
			echo "   > Run $1: Execution error: Your program did not produce an answer"
			echo "         that was judged as correct. It stopped at $timing seconds;"
			echo "         it used $memory KB of memory."
			echo -e "\n         Here are the respective outputs:"
			echo "         ----- our output ---------"
			catbef Test$1/out "         "
			echo "         ---- your output ---------"
			catbef $3.out "         "
			if [ "`tail -c 1 $3.out`" != "" ]; then
				echo
			fi
			echo -e "         --------------------------\n"
			if [ -z "`cat $3.out`" ]; then
				echo -e "         Your program created an empty file.\n"
			elif [ "`tail -c 1 $3.out`" != "" ]; then
				echo "         Note that your output did not end in a newline!  This is an error and"
				echo -e "         must be repaired.\n"
			fi
		else
			echo "   > Run $1: Execution error: Your program exited with"
			echo "         signal #$exitstatus (segmentation violation [maybe caused by accessing"
			echo "         memory out of bounds, array indexing out of bounds, using a bad"
			echo "         pointer (failed open(), failed malloc), or going over the maximum"
			echo "         specified memory limit]). The program ran for $timing CPU seconds"
			echo -e "         before the signal. It used $memory KB of memory.\n"
		fi
		echo "         ------ Data for Run $1 ------"
		catbef "Test$1/in" "         "
		echo "         -----------------------------"
		if [ $exitstatus -eq 0 ]; then
			if [ ! -z "$(cat /tmp/standardoutput)" ]; then
				echo -e "\n         Your program printed data to stdout.  Here is the data:"
				echo "         --------------------"
				catbet /tmp/standardoutput "         "
				echo "         --------------------"
			fi
			echo "   Test $1: BADCHECK $timing ($timing secs, $memory KB)"
		fi
		cleanup $3
		exit
	fi
	cleanup $3
}

id=""
taskname=$(pwd | sed s/".*\/\([^\/]*\)"/"\1"/g)
db=false
for arg in $*; do
	case "$arg" in
		-d) db=true
			;;
		-s) ../.tool/submit.py
			exit
			;;
		-*)
			;;
		*) id=$arg
	esac
done

echo 'Compiling...'
g++ main.cpp -g > /tmp/compilerrors 2>&1
if [ $? -eq 1 ]; then
	echo 'Compile error: your program did not compile correctly:'
	cat /tmp/compilerrors
	echo -e "\nCompile errors; end of this run."
	rm /tmp/compilerrors
	exit
fi
echo 'Compile: OK'
rm /tmp/compilerrors
echo
echo 'Executing...'
if [ "$id" = "" ]; then
	for i in $(ls | egrep '^Test[0-9]+' | sed 's/Test//g' | sort -g); do
		if [ -e "Test$i" ] && [ -d "Test$i" ] && [ -r "Test$i" ] && [ -e "Test$i/in" ] && [ -f "Test$i/in" ] && [ -r "Test$i/in" ] && [ -e "Test$i/out" ] && [ -f "Test$i/out" ]
		then
			testn $i $db $taskname
		fi
	done
	exit
else
	if [ ! -e "Test$id" ]; then
		echo "No data for Test $id"
	elif [ ! -d "Test$id" ]; then
		echo "Test$id is not a directory"
	elif [ ! -r "Test$id" ]; then
		echo "Test$id is not readable"
	elif [ ! -e "Test$id/in" ]; then
		echo "No input file for Test $id"
	elif [ ! -f "Test$id/in" ]; then
		echo "Test$id/in is not a file"
	elif [ ! -r "Test$id/in" ]; then
		echo "Test$id/in is not readable"
	elif [ ! -e "Test$id/out" ]; then
		echo "No output file for Test $id"
	elif [ ! -f "Test$id/out" ]; then
		echo "Test$id/out is not a file"
	elif [ ! -r "Test$id/out" ]; then
		echo "Test$id/out is not readable"
	else
		testn $id $db $taskname
	fi
fi
