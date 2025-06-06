#!/bin/bash

# ONLY ONCE PER DAY TASKS
# DO NOT RUN TWICE A DAY

source daily.conf
source switch.conf
source function-lib.sh

if [ "$1" == "force" ]; then
	echo "** enforce doing daily now **"
	read -p "MAKE SURE YOU RUN IT ONCE A DAY. Press return or CTRL+C"
else
	echo "** automatic daily : checks before doing it **"

	auto_daily_flag=${auto_daily_H[$current_servname]-false}
	if $auto_daily_flag; then
		echo "* auto daily enabled on $current_servname : go on"
	else
		echo "* auto daily disabled on $current_servname : exit"
		exit
	fi

	todo_file="./tmp/$current_servname.daily.todo"
	if [ -f "$todo_file" ]; then
		echo "* daily task has been scheduled : go on"
	else
		echo "* daily task not scheduled : exit"
		exit
	fi

	todo_time=$(stat -c '%Y' $todo_file)
	now_time=$(date +%s)
	actual_delay=$((now_time-todo_time))
	echo "* $actual_delay seconds since task scheduling"

	wait_time_hh=${daily_start_delay_H[$current_servname]-"0"}
	wait_time_s=$((1800*wait_time_hh))
	echo "* wait time on $current_servname : $wait_time_s secs."
	if [ "$actual_delay" -ge "$wait_time_s" ]; then
		echo "* allowed to start auto daily on $current_servname"
	else
		echo "* need to wait more on $current_servname : exit"
		exit
	fi
fi
# NOT REACHED IF CANCELED FOR ANY REASON

echo "Let's start on $current_servname"

Nlibe=${Nlibe_H[$current_servname]-"0"}
Ndung=${Ndung_H[$current_servname]-"0"}
if ${do_libe_H[$current_servname]}; then
	echo "doing $Nlibe liberations and $Ndung dungeons"
	./auto-wm-run.sh $Nlibe $Ndung
else
	echo "skip WM daily missions"
fi
if ${do_collect_H[$current_servname]}; then
	echo "doing auto daily collect"
	./auto-collect-run.sh
else
	echo "skip daily collect"
fi

if [ "$1" != "force" ]; then
	remove_task "$current_servname.daily.todo"
fi
