#!/bin/bash
source function-lib.sh

# THIS IS RADISH AUTOMATION TOOL
# DAILY WM RUN SCRIPT
# JUST EXPECT ./auto-wm-config.sh has been successfully executed

radish_message "DAILY WM RUN SCRIPT"

if [ ! -f "win_id.conf" ]; then
	echo "please provide a window id file with setwin_id.sh"
	exit 1
fi

source win_id.conf

if [ ! -f "wm.conf" ]; then
	echo "error : wm.conf not found. run ./auto-wm-config.sh N_SCROLL"
	exit 1
fi

if [ -z "$1" ]; then
	echo "error : argument 1 should be number of liberation missions"
	exit 1
fi
N_liber=$1

if [ -z "$2" ]; then
	echo "error : argument 2 should be number of dungeon missions"
	exit 1
fi
N_dung=$2

echo "Runnung with $N_liber liberations and $N_dung dungeons"

if [[ "$N_liber" -le "0" && "$N_dung" -le "0" ]]; then
	echo "Nothing to do"
	exit 0
fi

source wm.conf

### ### ### ###
# retype the functions and make some changes

focus_and_back_to_root_screen() {
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
	sleep 1
	xdotool key Escape
}

focus_and_go_to_map() {
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
	sleep 1
	xdotool key Escape
	sleep 1
	xdotool key m
}

click_and_go() {
	sleep 1
	xdotool windowactivate $gamewin_id
	sleep 1
	xdotool mousemove $1 $2 click 1
}

mission_ok() {
	xdotool windowactivate $gamewin_id
	sleep 1
	xdotool key Escape
}

### ### ### ###

focus_and_go_to_map
click_and_go $X_camp_map $Y_camp_map
click_and_go $X_mission_button $Y_mission_button

click_and_go $X_liberations $Y_liberations

i=0
if [ "$i" -lt  "$N_liber" ]; then
	click_and_go $X_liberation_1 $Y_liberation_1
	sleep 60
	mission_ok
	i=$((i+1))
fi
if [ "$i" -lt  "$N_liber" ]; then
	click_and_go $X_liberation_2 $Y_liberation_2
	sleep 60
	mission_ok
	i=$((i+1))
fi
if [ "$i" -lt  "$N_liber" ]; then
	click_and_go $X_liberation_3 $Y_liberation_3
	sleep 60
	mission_ok
	i=$((i+1))
fi
if [ "$i" -lt  "$N_liber" ]; then
	click_and_go $X_liberation_4 $Y_liberation_4
	sleep 60
	mission_ok
	i=$((i+1))
fi

# scrolled part
echo "DON'T MOVE MOUSE NOW"
sleep 4
xdotool windowactivate $gamewin_id
sleep 1
xdotool mousemove $X_liberation_4 $Y_liberation_4
while [ "$i" -lt  "$N_liber" ]; do
	xdotool click --repeat $n_scroll_libe --delay 200 5
	sleep 1
	xdotool click 1
	sleep 60
	mission_ok
	i=$((i+1))
done


mission_ok
click_and_go $X_dungeons $Y_dungeons

i=0
if [ "$i" -lt  "$N_dung" ]; then
	click_and_go $X_dungeon_1 $Y_dungeon_1
	sleep 60
	mission_ok
	i=$((i+1))
fi
if [ "$i" -lt  "$N_dung" ]; then
	click_and_go $X_dungeon_2 $Y_dungeon_2
	sleep 60
	mission_ok
	i=$((i+1))
fi

focus_and_back_to_root_screen
echo "Daily WM missions done"
