#!/bin/bash

# THIS IS RADISH AUTOMATION TOOL
# SERVER SWITCH COMMAND
echo "MAKE SURE switch.conf IS UP TO DATE WITH YOUR CURRENT SERVER"

source win_id.conf
echo read id: $gamewin_id
echo

### ### ### ###

back_to_root_screen() {
	sleep 1
	xdotool windowactivate $gamewin_id
	sleep 1
	xdotool key Escape
	sleep 1
	xdotool key Escape
	sleep 1
	xdotool key Escape
	sleep 1
	xdotool key Escape
}

click_and_go() {
	echo "let's move to $3..."
	sleep 1
	xdotool windowactivate $gamewin_id
	sleep 1
	xdotool mousemove $1 $2 click 1
}

### ### ### ###

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

if [ "$current_servname" = "$1" ]; then
	echo "server switch not required"
else
	echo "switch to $1"
	source $1
	back_to_root_screen
	click_and_go $X_settings $Y_settings "settings button"
	click_and_go $X_server_switch $Y_server_switch "server switch"
	click_and_go $X_fav_servers $Y_fav_servers "favorite servers"
	click_and_go $X_serv_i $Y_serv_i "server $1"
	click_and_go $X_serv_confirm $Y_serv_confirm "confirmation"
	echo "overwriting $1 to switch file"
	echo "current_servname=${1}" > switch.conf
	cat switch.conf
	sleep 30
	back_to_root_screen
fi

echo "end of server switch"
