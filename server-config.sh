#!/bin/bash
source function-lib.sh

# THIS IS RADISH AUTOMATION TOOL
# SERVER CONFIGURATION SCRIPT

radish_message "SERVER CONFIGURATION SCRIPT"

if [ -z "$1" ]; then
	echo Error : expecting at least 1 server name as argument
	exit 1
fi

echo "Configuring servers : $@"
source win_id.conf
echo read id: $gamewin_id
echo

echo "now let's find the setting button"
focus_and_back_to_root_screen
set_mouse_coordinates "setting button" "X_settings" "Y_settings"
echo "settings button at x: $X_settings, y: $Y_settings"
click_and_go $X_settings $Y_settings "settings button"
echo

echo "now let's find the server switch button"
set_mouse_coordinates "server switch" "X_server_switch" "Y_server_switch"
echo "server switch at x: $X_server_switch, y: $Y_server_switch"
click_and_go $X_server_switch $Y_server_switch "server switch"
echo

echo "now let's find the favorite servers button"
set_mouse_coordinates "favorite servers" "X_fav_servers" "Y_fav_servers"
echo "favorite servers at x: $X_fav_servers, y: $Y_fav_servers"
click_and_go $X_fav_servers $Y_fav_servers "favorite servers"
echo

echo "now configuration of each server's coordiantes"
for servname in "$@"; do
	echo "server $servname"
	set_mouse_coordinates "$servname" "X_serv_i" "Y_serv_i"
	echo "server $servname x: $X_serv_i, y: $Y_serv_i"
	echo "Creating/overwriting file $servname"
	echo "X_serv_i=${X_serv_i}" > $servname
	echo "Y_serv_i=${Y_serv_i}" >> $servname
done
echo

echo "now let's find the servers switch confirmation button"
echo "Go to game window and select eany server that is not current"
echo "the confirmation button should appear"
set_mouse_coordinates "server confirmation" "X_serv_confirm" "Y_serv_confirm"
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
focus_and_back_to_root_screen
