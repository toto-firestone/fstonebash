#!/bin/bash
source function-lib.sh
source win_id.conf

radish_message "FRIDAY CODE FOR SERVERS : $serv_list"

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

X_more=977
Y_more=209

X_code=456
Y_code=588

X_submit=848
Y_submit=592

for i_serv in $serv_list; do
	#click_and_go $X_more $Y_more
	#click_and_go $X_code $Y_code
	#xdotool type --delay 600 $1
	#click_and_go $X_submit $Y_submit

	task_file="$i_serv.fridaycode.todo"
	schedule_task $task_file
	echo "X_more=$X_more" >> ./tmp/$task_file
	echo "Y_more=$Y_more" >> ./tmp/$task_file
	echo "X_code=$X_code" >> ./tmp/$task_file
	echo "Y_code=$Y_code" >> ./tmp/$task_file
	echo "X_submit=$X_submit" >> ./tmp/$task_file
	echo "Y_submit=$Y_submit" >> ./tmp/$task_file
	echo "reward_code=$reward_code" >> ./tmp/$task_file
done
