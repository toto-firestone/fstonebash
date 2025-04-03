#!/bin/bash

# THIS IS RADISH AUTOMATION TOOL
# SERVER CONFIGURATION SCRIPT

echo "THIS IS RADISH AUTOMATION TOOL \\o/"
echo "SERVER CONFIGURATION SCRIPT"
echo "DISCLAIMER : always keep in mind what a happy radish is"
read -p "press return key..."

if [ -z "$1" ]; then
	echo Error : expecting at least 1 server name as argument
	exit 1
fi

echo "Configuring servers : $@"
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

prompt_mouse_position() {
	echo "click back to the terminal where the script is running"
	read -p "put your mouse pointer above $1 and hit return key"
}

click_and_go() {
	echo "let's move to $3..."
	sleep 1
	xdotool windowactivate $gamewin_id
	sleep 1
	xdotool mousemove $1 $2 click 1
}

### ### ### ###

echo "now let's find the setting button"
back_to_root_screen
prompt_mouse_position "setting button"
mouseloc=$(xdotool getmouselocation)
X_settings=$(echo "$mouseloc" | grep -oP 'x:\K\d+')
Y_settings=$(echo "$mouseloc" | grep -oP 'y:\K\d+')
echo "settings button at x: $X_settings, y: $Y_settings"
click_and_go $X_settings $Y_settings "settings button"
echo

echo "now let's find the server switch button"
prompt_mouse_position "server switch"
mouseloc=$(xdotool getmouselocation)
X_server_switch=$(echo "$mouseloc" | grep -oP 'x:\K\d+')
Y_server_switch=$(echo "$mouseloc" | grep -oP 'y:\K\d+')
echo "server switch at x: $X_server_switch, y: $Y_server_switch"
click_and_go $X_server_switch $Y_server_switch "server switch"
echo

echo "now let's find the favorite servers button"
prompt_mouse_position "favorite servers"
mouseloc=$(xdotool getmouselocation)
X_fav_servers=$(echo "$mouseloc" | grep -oP 'x:\K\d+')
Y_fav_servers=$(echo "$mouseloc" | grep -oP 'y:\K\d+')
echo "favorite servers at x: $X_fav_servers, y: $Y_fav_servers"
click_and_go $X_fav_servers $Y_fav_servers "favorite servers"
echo

echo "now configuration of each server's coordiantes"
for servname in "$@"; do
	echo "server $servname"
	prompt_mouse_position "$servname"
	mouseloc=$(xdotool getmouselocation)
	X_serv_i=$(echo "$mouseloc" | grep -oP 'x:\K\d+')
	Y_serv_i=$(echo "$mouseloc" | grep -oP 'y:\K\d+')
	echo "server $servname: $X_serv_i, y: $Y_serv_i"
	echo "Creating/overwriting file $servname"
	echo "X_serv_i=${X_serv_i}" > $servname
	echo "Y_serv_i=${Y_serv_i}" >> $servname
done
echo

echo "now let's find the servers switch confirmation button"
echo "Go to game window and select eany server that is not current"
echo "the confirmation button should appear"
prompt_mouse_position "server confirmation"
mouseloc=$(xdotool getmouselocation)
X_serv_confirm=$(echo "$mouseloc" | grep -oP 'x:\K\d+')
Y_serv_confirm=$(echo "$mouseloc" | grep -oP 'y:\K\d+')
echo "server confirmation at x: $X_serv_confirm, y: $Y_serv_confirm"
echo

echo "completing configuration of each server's coordiantes"
for servname in "$@"; do
	echo "server $servname"
	echo "X_settings=${X_settings}" >> $servname
	echo "Y_settings=${Y_settings}" >> $servname
	echo "X_server_switch=${X_server_switch}" >> $servname
	echo "Y_server_switch=${Y_server_switch}" >> $servname
	echo "X_fav_servers=${X_fav_servers}" >> $servname
	echo "Y_fav_servers=${Y_fav_servers}" >> $servname
	echo "X_serv_confirm=${X_serv_confirm}" >> $servname
	echo "Y_serv_confirm=${Y_serv_confirm}" >> $servname
done
echo 

echo "Initializing current server with switch.conf file"
read -p "write the current server name and type return > " current_servname
echo "writing $current_servname to switch file"
echo "current_servname=${current_servname}" > switch.conf
echo "configuration done"
back_to_root_screen
