#!/bin/bash
source function-lib.sh

serv_list="s27 s1 s14 s25"

radish_message "FRIDAY CODE FOR SERVERS : $serv_list"

if [ -z "$1" ]; then
	echo "Error : expect friday code as argument 1"
	exit 1
fi
echo "typing $1 on $serv_list"

source win_id.conf

focus_and_back_to_root_screen
set_mouse_coordinates "settings" "X_settings" "Y_settings"
click_and_go $X_settings $Y_settings
set_mouse_coordinates "more tab" "X_more" "Y_more"
click_and_go $X_more $Y_more
set_mouse_coordinates "write code" "X_code" "Y_code"
set_mouse_coordinates "submit" "X_submit" "Y_submit"

for i_serv in $serv_list; do
	./switch-server.sh $i_serv
	click_and_go $X_settings $Y_settings
	click_and_go $X_more $Y_more
	click_and_go $X_code $Y_code
	xdotool type --delay 600 $1
	click_and_go $X_submit $Y_submit
done
