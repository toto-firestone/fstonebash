#!/bin/bash
source glob-coord.conf
source master.conf
source function-lib.sh

radish_message_noprompt "AUTOMATIC ALCHEMY TOOL"
echo "WARNING : START AUTOMATION WITH NO UNCLAIMED EXPERIMENT SLOTS"
echo
echo "for auto claim mode, use :"
echo "./auto-alch claim command"
echo

### ### ### ###

alchemy_special_click() {
	super_slow_click
	# extra click in case timing is screwed up
	move_wait_click $X_alch_close_gem $Y_alch_close_gem 2
}

claim_alch_experiments() {
	local expes=$1
	if [ -z "$expes" ]; then
		echo "empty command : nothing to claim and exit"
		return
	fi
	# NOT REACHED IF ARGUMENT IS EMPTY
	if [[ ! "$expes" =~ ^[01]{3}$ ]]; then
		echo "invalid command : nothing to claim and exit"
		return
	fi
	# NOT REACHED IF COMMAND IS INVALID

	if [ "${expes:0:1}" == "1" ]; then
		echo "* claim blood experiment"
		move_wait_only $X_alch_blood_exp $Y_alch_experiments 4
		alchemy_special_click
	fi
	if [ "${expes:1:1}" == "1" ]; then
		echo "* claim dust experiment"
		move_wait_only $X_alch_dust_exp $Y_alch_experiments 4
		alchemy_special_click
	fi
	if [ "${expes:2:1}" == "1" ]; then
		echo "* claim coin experiment"
		move_wait_only $X_alch_coin_exp $Y_alch_experiments 4
		alchemy_special_click
	fi
}


### ### ### ###

echo "*** doing atree on server $current_servname ***"

conf_file="$current_servname.firestone.conf"
if [ ! -f "$conf_file" ]; then
	echo "Error : cannot find config file $conf_file"
	exit
fi
# don't go further if no config file
source $conf_file

if [ -n "$atree_level" ] && [ -n "$atree_reduce_stack" ]; then
	echo "*** go for alchemy ***"
else
	echo "*** skip alchemy ***"
	exit
fi
# don't go further if no variables

alch_h=$(alch_base_hours $atree_level)
alch_timer=$(reduction_from_stack $alch_h $atree_reduce_stack)
if [ -z "$alch_timer" ]; then
	echo "Error : timer undefined"
	exit
else
	echo "** alchemy experiment wait is $alch_timer secs"
	echo "* timer is $(secs_to_hhmm $alch_timer)"
fi

wait_fullpath="./tmp/${current_servname}.alchwait.todo"
if [ ! -f "$wait_fullpath" ]; then
	echo "** no wait directive $wait_fullpath **"
	no_wait=true
	do_wait=false
else
	echo "** wait directive scheduled in $wait_fullpath **"
	no_wait=false
	do_wait=true
fi

### CLAIM OPTION ###

if [ "$1" == "claim" ]; then
	if $do_wait; then
		echo "** wait directive detected : do nothing and exit **"
		exit
	fi

	go_to_alchemy
	# no cancel chance at 2 secs.
	read -t 2 -p "last chance to cancel claim = NON SPACE + RETURN > " do_cancel

	echo
	if [ -n "$do_cancel" ]; then
		echo "** cancel auto claim session **"
		exit
	fi
	echo "** claiming finished experiments **"
	claim_alch_experiments $2

	exit
fi
# NOT REACHED IF CLAIM

todo_fullpath="./tmp/${current_servname}.alchstart.todo"
if [ ! -f "$todo_fullpath" ]; then
	if $no_wait; then
		echo "Error : cannot find schedule file $todo_fullpath"
		exit
	else
		echo "No more schedule file $todo_fullpath"
		echo "but wait has been sceduled"
	fi
fi
# CAN REACH HERE IF WAIT IS SCHEDULED WITH NO TASK FILE
# BUT IF NO WAIT, THEN NO TASK LEADS TO EXIT

if $do_wait; then
	echo "** check if wait directive has expired **"
	now_timestamp=$(date +%s)
	wait_info=$(cat $wait_fullpath)
	wait_timestamp=${wait_info%/*}
	claim_command=${wait_info#*/}
	if [ "$now_timestamp" -gt "$wait_timestamp" ]; then
		echo "* end of wait directive *"
		remove_task ${wait_fullpath#./tmp/}
		echo "* claiming..."
		./auto-alch.sh claim $claim_command
	else
		echo "* still waiting and do nothing *"
		exit
	fi
fi

# AT THIS POINT, SLOTS SHOULD BE EMPTY
echo "***** claim is over and slots should be empty *****"

atree_cmd=""
if [ -s "$todo_fullpath" ]; then
	atree_cmd=$(head -n 1 $todo_fullpath)
	sed -i '1d' $todo_fullpath
else
	echo "Warning : $todo_fullpath is empty on startup. removing"
	remove_task ${todo_fullpath#./tmp/}
	echo "* nothing to do"
	exit
fi
# NOT REACHED IF TASK FILE IS EMPTY

if [[ ! "$atree_cmd" =~ ^[01]{3}$ ]]; then
	echo "* read invalid command : $atree_cmd"
	echo "* eliminating this command"
	echo "* nothing to do this turn"
	exit
else
	echo "* read valid command and queued it again : $atree_cmd"
	echo $atree_cmd >> $todo_fullpath
fi
# NOT REACHED IF INVALID COMMAND

go_to_alchemy
if [ "${atree_cmd:0:1}" == "1" ]; then
	echo "* start blood experiment"
	move_wait_only $X_alch_blood_exp $Y_alch_experiments 4
	alchemy_special_click
fi
if [ "${atree_cmd:1:1}" == "1" ]; then
	echo "* start dust experiment"
	move_wait_only $X_alch_dust_exp $Y_alch_experiments 4
	alchemy_special_click
fi
if [ "${atree_cmd:2:1}" == "1" ]; then
	echo "* start coin experiment"
	move_wait_only $X_alch_coin_exp $Y_alch_experiments 4
	alchemy_special_click
fi

echo "* schedule a wait of $alch_timer seconds"
schedule_task ${wait_fullpath#./tmp/}
now_timestamp=$(date +%s)
echo "now timestamp = $now_timestamp"
wait_expire=$((now_timestamp+alch_timer))
echo "${wait_expire}/${atree_cmd}" >> $wait_fullpath
echo "* wait directive scheduled *"
cat $wait_fullpath
