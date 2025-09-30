#!/bin/bash
source glob-coord.conf
source master.conf
source function-lib.sh
source visual-lib.sh
source remote-tools.sh

# THIS IS RADISH AUTOMATION TOOL
# SERVER SWITCH COMMAND
echo "MAKE SURE switch.conf IS UP TO DATE WITH YOUR CURRENT SERVER"
radish_message_noprompt "SERVER SWITCH COMMAND"

echo read id: $gamewin_id
echo

if [ -z "$current_servname" ]; then
	echo Error : invalid switch.conf
	exit 1
fi

if [ -z "$1" ]; then
	echo Error : expecting 1 server name as argument
	exit 1
fi

if [ ! -f "$1.firestone.conf" ]; then
	echo Error : expecting $1 is a configured server
	exit 1
fi
eval "X_serv_i=\$X_server_$1"
eval "Y_serv_i=\$Y_server_$1"


if [ -z "$DETACHED_BOT" ]; then
	echo "* Warning : DETACHED_BOT undefined,setup now"
	env_for_remote_or_local
fi

try_reach_fav_servers() {
	anti_ad
	go_to_settings
	# additional tempo for server switch task
	move_wait_click $X_server_switch $Y_server_switch 3
	# this one deserves a triple click
	move_wait_click $X_fav_servers $Y_fav_servers 3
	move_wait_click $X_fav_servers $Y_fav_servers 2
	move_wait_click $X_fav_servers $Y_fav_servers 1
}

log_msg "** switch from $current_servname to $1 **"
xdotool windowactivate --sync $gamewin_id
if [ "$current_servname" == "$1" ]; then
	echo "server switch not required"
	anti_ad
else
	echo "switch to $1"
	i_try=0
	reach_crit=""
	n_try=6
	while [ "$i_try" -lt "$n_try" ]; do
		try_reach_fav_servers
		check_switch_to_fav_reached
		reach_crit=$(tail -n 1 ./tmp/firestone.log | grep 'switch_fav_reached=1')

		i_try=$((i_try+1))
		if [ -n "$reach_crit" ]; then
			break
		fi
		# NOT REACHED IF SUCCESS
		if [ "$i_try" -lt "$n_try" ]; then
			echo "* WARNING : favorite servers not reached at $i_try/$n_try attempts"

			echo "* 30 secs. before retry"
			sleep 30
		fi
	done
	if [ -n "$reach_crit" ]; then
		echo "* favorite servers reached at try $i_try/$n_try"
	else
		echo "* WARNING : favorite servers not reached after $i_try/$n_try attempts"
		echo "*** SKIP THIS SERVER SWITCH ***"
		exit
	fi
	# NOT REACHED IF FAILED TO REACH FAVORITE SERVERS PAGE
	move_wait_click $X_serv_i $Y_serv_i 6
	move_wait_click $X_serv_confirm $Y_serv_confirm 3

	# for the sake of failure detection
	# we will write real server name
	# at the end of successful loading process
	#echo "overwriting $1 to switch file"
	#echo "current_servname=${1}" > switch.conf
	#cat switch.conf

	if ! $DETACHED_BOT; then
		xdotool windowactivate --sync $termwin_id
	fi
	#sleep 20
	wait_game_start 8 20 "non-blocking"
	fail_crit=$(tail -n 1 ./tmp/firestone.log | grep 'success=0')
	if [ -n "$fail_crit" ]; then
		echo "* game did non restarted after server switch"
		echo "* try to quit and restart once"
		#read -p "stop with CTRL+C or continue with RETURN " dummy
		# the blocking read statement is in firestone starter
		log_msg "*** quit firestone ***"
		safe_quit
		./firestone-starter.sh
		log_msg "*** firestone restarted ***"
		source win_id.conf
	else
		echo "* game restarted without error after server switch"
	fi
	# now we know that game has loaded successfully
	# hard restart (download timeout) or soft restart (no download lag)
	# NOT REACHED IF HARD RESTART FAILS (BLOCKING WAIT)

	find_real_servername
	find_result=$(tail -n 1 ./tmp/firestone.log)
	echo "$find_result"
	real_servername=$(echo "$find_result" | grep -oP 'real_servername=\K[^[:space:]]+$')

	echo "overwriting $real_servername to switch file"
	echo "current_servname=$real_servername" > switch.conf
	cat switch.conf

	# if current_servname does not match wanted server
	# it will be handled outside here
	# this script only guarantees game loaded and started on exit
	# and not allow further processing if hard reload is stuck
	source switch.conf
	if [ "$current_servname" != "$1" ]; then
		echo "WARNING : switch to $1 finished in $current_servname"
	else
		echo "* switch to $1 matches with $current_servname"
	fi
fi
focus_and_back_to_root_screen

echo "end of server switch"
