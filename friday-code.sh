#!/bin/bash
source glob-coord.conf
source master.conf
source function-lib.sh

radish_message "FRIDAY CODE"

if [ -z "$1" ]; then
	echo "Error : expect friday code as argument 1"
	exit 1
fi
reward_code=$1

if [ -z "$2" ]; then
	echo "Error : expecting at least 1 server name as argument 2"
	exit 1
fi
serv_list=$2

echo "typing $reward_code on $serv_list"

for i_serv in $serv_list; do
	#click_and_go $X_more $Y_more
	#click_and_go $X_code $Y_code
	#xdotool type --delay 600 $1
	#click_and_go $X_submit $Y_submit

	task_file="$i_serv.fridaycode.todo"
	schedule_task $task_file
	echo "$reward_code" > ./tmp/$task_file
done
