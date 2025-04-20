#!/bin/bash
source function-lib.sh
source win_id.conf
source view.conf


radish_message_noprompt "Assisted Map tool"
echo "**************************************************"
echo "INTERRUPT BY SELECTING AN OUT OF WINDOW COORDINATE"
echo "**************************************************"

### Move, Wait, Click
faster_click_and_go() {
	xdotool windowactivate --sync $gamewin_id
	move_wait_click $1 $2 .5
}

### Move, Wait, Click... and come back
fast_click_here_and_there() {
	xdotool windowactivate --sync $gamewin_id
	move_wait_click $1 $2 .5
	move_wait_click $3 $4 .5
	xdotool mousemove --sync $1 $2
}

source map.conf

go_to_map

while true; do
	set_mouse_coordinates "a mission to start" "X_mission" "Y_mission"
	test_and_exit $X_mission $Y_mission
	fast_click_here_and_there $X_mission $Y_mission $X_map_mission_start $Y_map_mission_start

done
