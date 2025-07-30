#!/bin/bash
source glob-coord.conf
source function-lib.sh

# THIS IS RADISH AUTOMATION TOOL
# DAILY WM RUN SCRIPT

radish_message_noprompt "DAILY WM RUN SCRIPT"

if [ ! -f "win_id.conf" ]; then
	echo "please provide a window id file with setwin_id.sh"
	exit 1
fi

source win_id.conf

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

if [ -n "$3" ]; then
	T_fight_sec=$3
	echo "* liberation time set to $T_fight_sec secs."
else
	T_fight_sec=60
	echo "* liberation time defaut value is $T_fight_sec secs."
fi

echo "** Runnung with $N_liber liberations and $N_dung dungeons"

if [[ "$N_liber" -le "0" && "$N_dung" -le "0" ]]; then
	echo "Nothing to do"
	exit 0
fi

mission_ok() {
	xdotool windowactivate --sync $gamewin_id
	sleep 1
	xdotool key Escape
	sleep 5
}

liberation_click() {
	move_wait_only $1 $2 $3
	super_slow_click
}

### ### ### ###

xdotool windowactivate --sync $gamewin_id
anti_ad
go_to_map
move_wait_click $X_camp_map $Y_camp_map 4
move_wait_click $X_mission_button $Y_mission_button 6

move_wait_click $X_liberations $Y_liberations 4
sleep 4

i=0
if [ "$i" -lt  "$N_liber" ]; then
	i=$((i+1))
	echo "liberation $i"
	liberation_click $X_liberation_1 $Y_liberation_1 2
	sleep $T_fight_sec
	mission_ok
fi
if [ "$i" -lt  "$N_liber" ]; then
	i=$((i+1))
	echo "liberation $i"
	liberation_click $X_liberation_2 $Y_liberation_2 2
	sleep $T_fight_sec
	mission_ok
fi
if [ "$i" -lt  "$N_liber" ]; then
	i=$((i+1))
	echo "liberation $i"
	liberation_click $X_liberation_3 $Y_liberation_3 2
	sleep $T_fight_sec
	mission_ok
fi
if [ "$i" -lt  "$N_liber" ]; then
	i=$((i+1))
	echo "liberation $i"
	liberation_click $X_liberation_4 $Y_liberation_4 2
	sleep $T_fight_sec
	mission_ok
fi

# scrolled part
echo "DON'T MOVE MOUSE NOW"
xdotool mousemove $X_liberation_4 $Y_liberation_4
sleep 4
while [ "$i" -lt  "$N_liber" ]; do
	i=$((i+1))
	echo "let's scroll to liberation $i"
	smooth_drag_and_drop $X_liber_scroll_right $Y_liber_scroll $X_liber_scroll_left $Y_liber_scroll

	#slow_safe_click
	liberation_click $X_liberation_4 $Y_liberation_4 2
	sleep $T_fight_sec
	mission_ok
	# tempo correction
	sleep 4
done


mission_ok
move_wait_click $X_dungeons $Y_dungeons 6

i=0
if [ "$i" -lt  "$N_dung" ]; then
	i=$((i+1))
	echo "dungeons $i"
	liberation_click $X_dungeon_1 $Y_dungeon_1 2
	sleep $T_fight_sec
	mission_ok
fi
if [ "$i" -lt  "$N_dung" ]; then
	i=$((i+1))
	echo "dungeons $i"
	liberation_click $X_dungeon_2 $Y_dungeon_2 2
	sleep $T_fight_sec
	mission_ok
fi

focus_and_back_to_root_screen
echo "Daily WM missions done"
