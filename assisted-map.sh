#!/bin/bash
source function-lib.sh
source win_id.conf
source view.conf


radish_message_noprompt "Assisted Map tool"
X_max=$((X_WIN_POS+WIN_WIDTH))
Y_max=$((Y_WIN_POS+WIN_HEIGHT))
echo "**************************************************"
echo "INTERRUPT BY SELECTING AN OUT OF WINDOW COORDINATE"
echo "**************************************************"
test_and_exit() {
	if [ "$1" -gt "$X_max" ] || [ "$2" -gt "$Y_max" ]; then
		exit 0
	fi
}

faster_click_and_go() {
	xdotool windowactivate --sync $gamewin_id
	xdotool mousemove $1 $2 click 1
}

go_to_map

set_mouse_coordinates "a mission to start" "X_mission" "Y_mission"
test_and_exit $X_mission $Y_mission
faster_click_and_go $X_mission $Y_mission

set_mouse_coordinates "start button" "X_start" "Y_start"
test_and_exit $X_start $Y_start
faster_click_and_go $X_start $Y_start

while true; do
	set_mouse_coordinates "a mission to start" "X_mission" "Y_mission"
	test_and_exit $X_mission $Y_mission
	faster_click_and_go $X_mission $Y_mission
	sleep 1
	faster_click_and_go $X_start $Y_start
done
