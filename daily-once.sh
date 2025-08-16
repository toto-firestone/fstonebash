#!/bin/bash

# ONLY ONCE PER DAY TASKS
# DO NOT RUN TWICE A DAY

source glob-coord.conf
source master.conf
source function-lib.sh
source visual-lib.sh
source tricky-dailies.sh

source daily.conf

if [ "$1" == "force" ]; then
	echo "** enforce doing daily now **"
	read -p "MAKE SURE YOU RUN IT ONCE A DAY. Press return or CTRL+C"
elif [ "$1" == "reset" ]; then
	echo "** reset for servers : $2 **"
	if $WITHOUT_NODRIFT; then
		nodrift_mode=false
		echo "** without drift compensation on global setting"
		## GLOBAL SETTING OVERRIDES FIRST
	elif [ "$3" == "nodrift" ]; then
		nodrift_mode=true
		echo "** enables drift compensation"
	else
		nodrift_mode=false
		echo "** disables drift compensation"
	fi

	for serv in $2; do
		if [ ! -f "$serv.firestone.conf" ]; then
			echo "* server $serv not set : skip"
			continue
		else
			echo "* reset daily timer and schecule task on $serv"
		fi
		# NOT REACHED IF INVALID SERVER
		time_file="$serv.daily.timestamp"

		if $nodrift_mode; then
			t_drift_abs=$(get_elapsed_sec $time_file)
			t_24h=$((60*60*24))
			t_drift=$((t_drift_abs % t_24h))
			echo "* drift on server $serv : $t_drift sec"
		else
			t_drift=""
		fi
		reset_timestamp $time_file $t_drift
		log_msg "** reset of $time_file"
		# remove is necessary because of non empty task file
		remove_task "$serv.daily.todo"
		schedule_task "$serv.daily.todo"

		### write split tasks ###
		f_task="./tmp/$serv.daily.todo"
		if ${do_libe_H[$serv]}; then
			#echo "libe_dung" >> $f_task
			echo "libe_1to4" >> $f_task
			echo "libe_5more" >> $f_task
			echo "dung" >> $f_task
		fi
		if ${do_collect_H[$serv]}; then
			echo "gift_exotic" >> $f_task
			echo "pickaxe_crystal" >> $f_task
			echo "beer" >> $f_task
			echo "scarab" >> $f_task
			echo "chest_mail" >> $f_task
		fi
		source $serv.firestone.conf
		if $ENABLE_AUTO_RIFT; then
			echo "holy_rift" >> $f_task
		fi
	done

	exit
	# CANNOT REACH FURTHER
else
	echo "** automatic daily : checks before doing it **"

	auto_daily_flag=${auto_daily_H[$current_servname]-false}
	if $auto_daily_flag; then
		echo "* auto daily enabled on $current_servname : go on"
	else
		echo "* auto daily disabled on $current_servname : exit"
		exit
	fi
	# NOT REACHED IF AUTO DAILY DISABLED

	todo_file="./tmp/$current_servname.daily.todo"
	if [ -f "$todo_file" ]; then
		echo "* daily task has been scheduled : go on"
	else
		echo "* daily task not scheduled : exit"
		exit
	fi
	# NOT REACHED IF SCHEDULE FILE NOT CREATED BY RESET

	## the creation time of todo file is same as last modification
	## time of timestamp file (creation time not available with stat)
	time_file="./tmp/$current_servname.daily.timestamp"
	todo_time=$(stat -c '%Y' $time_file)
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
	# NOT REACHED IF BELOW DELAY AFTER ACTUAL RESET
fi
# NOT REACHED IF CANCELED FOR ANY REASON

echo "** Let's start auto dailies on $current_servname"
source $current_servname.firestone.conf

### ### ### ### ### ##
### SPLIT WORKLOAD ###
### ### ### ### ### ##

## force option disables split workload
if $ENABLE_SPLIT_DAILY && [ "$1" != "force" ]; then
	echo "** workload split enabled **"
	./split-dailies.sh
	exit
fi

### ### ### ### ### ##
### ### ### ### ### ##
# NOT REACHED IF WORKLOAD SPLIT IS ENABLED AND force OPTION IS OFF

# So the following part is executed if workload split is DISABLED
# OR force option is ON

# actually force option does not matter when workload split is off
# workload split option does not count when force option on

Nlibe=${Nlibe_H[$current_servname]-"0"}
Ndung=${Ndung_H[$current_servname]-"0"}
TFight=${TFightSec_H[$current_servname]-"60"}
if ${do_libe_H[$current_servname]}; then
	echo "* expedition check before liberation"
	launch_and_claim_expedition

	echo "* doing $Nlibe liberations and $Ndung dungeons"
	#./auto-wm-run.sh $Nlibe $Ndung $TFight
	auto_liberation_dungeon $Nlibe $Ndung $TFight
else
	echo "* skip WM daily missions"
fi
if ${do_collect_H[$current_servname]}; then
	echo "* expedition check before daily collect"
	launch_and_claim_expedition

	echo "* doing auto daily collect"
	./auto-collect-run.sh

	#echo "* map check after daily collect"
	#./auto-map.sh
else
	echo "* skip daily collect"
fi

### ### ### ### ### ### ##
### Handling auto rift ###
### ### ### ### ### ### ##

if $ENABLE_AUTO_RIFT; then
	echo "*** Auto Rift enabled on $current_servname ***"
	auto_guardian_holy_upgrade $current_servname
	auto_chaos_rift_play $current_servname
else
	echo "*** Auto Rift disabled on $current_servname ***"
fi

# TASK FILE HAS TO BE REMOVED ON CALLING CONTEXT IF force OPTION IS USED #
# last instruction is executed when workload split is DISABLED
# AND force option is OFF
if [ "$1" != "force" ]; then
	remove_task "$current_servname.daily.todo"
fi
