#!/bin/bash
source function-lib.sh

if [ ! -f "wm.conf" ]; then
	echo "Error : expect to find wm.conf"
	exit 1
fi
source wm.conf

if [ ! -f "win_id.conf" ]; then
	echo "Error : expect to find win_id.conf"
	exit 1
fi
source win_id.conf

if [ -n "$1" ]; then
	echo "battle timer provided : $1 sec"
	battle_timer=$1
else
	echo "default timer : 25 sec"
	battle_timer=25
fi

radish_message "BRUTE FORCE ON WM CAMPAIGN MISSION"

# go back to root screen after each try to avoid uncontrolled infinite clicks
go_to_map
move_wait_click $X_camp_map $Y_camp_map 3

# select mission and start button
set_mouse_coordinates "wm mission" "X_WM_mission" "Y_WM_mission"
xdotool windowactivate --sync $gamewin_id

move_wait_click $X_WM_mission $Y_WM_mission 2
set_mouse_coordinates "mission starter" "X_mission_but" "Y_mission_but"
xdotool windowactivate --sync $gamewin_id

i=0
while true; do
	i=$((i+1))
	echo "Attempt $i"
	move_wait_click $X_mission_but $Y_mission_but 2
	sleep 5
	xdotool windowactivate --sync $termwin_id
	sleep 1
	echo "type ANY KEY + RETURN for loop exit"
	read -t $battle_timer -p "> " user_input
	echo
	if [ -n "$user_input" ]; then
		break
	fi
	go_to_map
	move_wait_click $X_camp_map $Y_camp_map 3
	move_wait_click $X_WM_mission $Y_WM_mission 2
done
