#!/bin/bash
source function-lib.sh
source visual-lib.sh

# THIS IS RADISH AUTOMATION TOOL
# SERVER SWITCH COMMAND
echo "MAKE SURE switch.conf IS UP TO DATE WITH YOUR CURRENT SERVER"
radish_message_noprompt "SERVER SWITCH COMMAND"

source win_id.conf
echo read id: $gamewin_id
echo

source switch.conf
if [ -z "$current_servname" ]; then
	echo Error : invalid switch.conf
	exit 1
fi

if [ -z "$1" ]; then
	echo Error : expecting 1 server name as argument
	exit 1
fi
if [ ! -f "$1" ]; then
	echo Error : expecting configured server name as argument
	exit 1
fi

log_msg "** switch from $current_servname to $1 **"
xdotool windowactivate --sync $gamewin_id
if [ "$current_servname" == "$1" ]; then
	echo "server switch not required"
	anti_ad
else
	echo "switch to $1"
	source $1
	anti_ad
	go_to_settings
	# additional tempo for server switch task
	move_wait_click $X_server_switch $Y_server_switch 3
	# this one deserves a triple click
	move_wait_click $X_fav_servers $Y_fav_servers 3
	move_wait_click $X_fav_servers $Y_fav_servers 2
	move_wait_click $X_fav_servers $Y_fav_servers 1
	echo "server $1"
	move_wait_click $X_serv_i $Y_serv_i 3
	move_wait_click $X_serv_confirm $Y_serv_confirm 3
	echo "overwriting $1 to switch file"
	echo "current_servname=${1}" > switch.conf
	cat switch.conf
	xdotool windowactivate --sync $termwin_id
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
fi
focus_and_back_to_root_screen

echo "end of server switch"
