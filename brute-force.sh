#!/bin/bash
source glob-coord.conf
source master.conf
source function-lib.sh

radish_message_noprompt "BRUTE FORCE ON WM CAMPAIGN MISSION"

if [ -n "$1" ]; then
	echo "battle timer provided : $1 sec"
	battle_timer=$1
else
	echo "default timer : 40 sec"
	battle_timer=40
fi

select map_position in "no-move" "map-bug" "map-bug+north"; do
	echo "* selected map position option : $map_position"
	break
done

# could be deprecated some day
	X1_map_bug=335
	Y1_map_bug=585
	X2_map_bug=323
	Y2_map_bug=700

map_position_handle() {
	if [ "$map_position" == "map-bug" ]; then
		echo "* compensation of map bug"
		drag_and_drop $X1_map_bug $Y1_map_bug $X2_map_bug $Y2_map_bug
	elif [ "$map_position" == "map-bug+north" ]; then
		echo "* compensation of map bug and move to north islands"
		drag_and_drop $X1_map_bug $Y1_map_bug $X2_map_bug $Y2_map_bug
		drag_and_drop $X2_map_bug $Y2_map_bug $X_north_island $Y_north_island

	else
		echo "* no map position change"
	fi
}

wm_campaign_safe_path() {
	go_to_town
	move_wait_click $X_battle_building $Y_battle_building 3
	move_wait_click $X_campaign_access $Y_campaign_access 3
}

# go back to root screen after each try to avoid uncontrolled infinite clicks
#go_to_map
#move_wait_click $X_camp_map $Y_camp_map 3
wm_campaign_safe_path

# handle map positioning issues
map_position_handle

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
	#go_to_map
	#move_wait_click $X_camp_map $Y_camp_map 3
	wm_campaign_safe_path
	# this one is not required as long as battle timer is short enough
	#map_position_handle
	move_wait_click $X_WM_mission $Y_WM_mission 2
done
