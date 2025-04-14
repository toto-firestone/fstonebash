#!/bin/bash
source function-lib.sh

# THIS IS RADISH AUTOMATION TOOL
# WM DAILY MISSIONS CONFIGURATION SCRIPT

radish_message "WM DAILY MISSIONS CONFIGURATION SCRIPT"

if [ -z "$1" ]; then
	echo "warning : expect the number of scroll down for next liberation"
	echo "missing argument 1"
	echo "using default value : 12"
	n_scroll_libe=12
else
	n_scroll_libe=$1
fi
echo "Testing with n_scroll_libe=$n_scroll_libe"

./setwin_id.sh
source win_id.conf
echo read id: $gamewin_id
echo

echo "let the script go to map first"
go_to_map

set_mouse_coordinates "campaign map" "X_camp_map" "Y_camp_map"
echo "campaign map at x: $X_camp_map, y: $Y_camp_map"
click_and_go $X_camp_map $Y_camp_map "campaign map"

set_mouse_coordinates "daily mission button" "X_mission_button" "Y_mission_button"
echo "daily mission button at x: $X_mission_button, y: $Y_mission_button"
click_and_go $X_mission_button $Y_mission_button "daily muission button"

set_mouse_coordinates "liberation open button" "X_liberations" "Y_liberations"
echo "liberation open button at x: $X_liberations, y: $Y_liberations"

set_mouse_coordinates "dungeon open button" "X_dungeons" "Y_dungeons"
echo "dungeon open button at x: $X_dungeons, y: $Y_dungeons"

echo "Let's start with dungeon missions"
click_and_go $X_dungeons $Y_dungeons "dungeon open button"

set_mouse_coordinates "dungeon 1" "X_dungeon_1" "Y_dungeon_1"
echo "dungeon 1 button at x: $X_dungeon_1, y: $Y_dungeon_1"

set_mouse_coordinates "dungeon 2" "X_dungeon_2" "Y_dungeon_2"
echo "dungeon 2 button at x: $X_dungeon_2, y: $Y_dungeon_2"

# tests 
echo tests dungeons
xdotool windowactivate --sync $gamewin_id
xdotool mousemove $X_dungeon_1 $Y_dungeon_1
sleep 4
xdotool mousemove $X_dungeon_2 $Y_dungeon_2
sleep 4
echo "interrupt with CTRL+C if something is wrong"

echo "back to mission window"
xdotool windowactivate --sync $gamewin_id
sleep 1
xdotool key Escape
click_and_go $X_liberations $Y_liberations "liberation open button"

# easy part : 4 first visible liberation missions

set_mouse_coordinates "liberation 1" "X_liberation_1" "Y_liberation_1"
echo "liberation 1 button at x: $X_liberation_1, y: $Y_liberation_1"
set_mouse_coordinates "liberation 2" "X_liberation_2" "Y_liberation_2"
echo "liberation 2 button at x: $X_liberation_2, y: $Y_liberation_2"
set_mouse_coordinates "liberation 3" "X_liberation_3" "Y_liberation_3"
echo "liberation 3 button at x: $X_liberation_3, y: $Y_liberation_3"

echo
echo "For liberation 4, try above i letter of Liberate"
set_mouse_coordinates "liberation 4" "X_liberation_4" "Y_liberation_4"
echo "liberation 4 button at x: $X_liberation_4, y: $Y_liberation_4"

# tests
echo "test liberation 1-4"
xdotool windowactivate --sync $gamewin_id
xdotool mousemove $X_liberation_1 $Y_liberation_1
sleep 4
xdotool mousemove $X_liberation_2 $Y_liberation_2
sleep 4
xdotool mousemove $X_liberation_3 $Y_liberation_3
sleep 4
xdotool mousemove $X_liberation_4 $Y_liberation_4
sleep 4
echo "interrupt with CTRL+C if something is wrong"

# the difficult part
echo "Calibration of right shift"
xdotool windowactivate --sync $gamewin_id
xdotool mousemove $X_liberation_4 $Y_liberation_4
sleep 4
xdotool click --repeat $n_scroll_libe --delay 200 5
echo "should be Goldfell"
sleep 4
xdotool click --repeat $n_scroll_libe --delay 200 5
echo "should be Xandor"
sleep 4
xdotool click --repeat $n_scroll_libe --delay 200 5
echo "should be Talamer"
sleep 4
xdotool click --repeat $n_scroll_libe --delay 200 5
echo "should be Hombor"
sleep 4
xdotool click --repeat $n_scroll_libe --delay 200 5
echo "should be Stormspire"
sleep 4
xdotool click --repeat $n_scroll_libe --delay 200 5
echo "should be Thal Badur"
sleep 4

xdotool windowactivate --sync $termwin_id
read -p "If everything is OK, type return. Else interrupt with CTRL+C"

echo "Saving coordinates to wm.conf"

echo "X_camp_map=${X_camp_map}" > wm.conf
echo "Y_camp_map=${Y_camp_map}" >> wm.conf
echo "X_mission_button=${X_mission_button}" >> wm.conf
echo "Y_mission_button=${Y_mission_button}" >> wm.conf
echo "X_liberations=${X_liberations}" >> wm.conf
echo "Y_liberations=${Y_liberations}" >> wm.conf
echo "X_dungeons=${X_dungeons}" >> wm.conf
echo "Y_dungeons=${Y_dungeons}" >> wm.conf
echo "X_dungeon_1=${X_dungeon_1}" >> wm.conf
echo "Y_dungeon_1=${Y_dungeon_1}" >> wm.conf
echo "X_dungeon_2=${X_dungeon_2}" >> wm.conf
echo "Y_dungeon_2=${Y_dungeon_2}" >> wm.conf
echo "X_liberation_1=${X_liberation_1}" >> wm.conf
echo "Y_liberation_1=${Y_liberation_1}" >> wm.conf
echo "X_liberation_2=${X_liberation_2}" >> wm.conf
echo "Y_liberation_2=${Y_liberation_2}" >> wm.conf
echo "X_liberation_3=${X_liberation_3}" >> wm.conf
echo "Y_liberation_3=${Y_liberation_3}" >> wm.conf
echo "X_liberation_4=${X_liberation_4}" >> wm.conf
echo "Y_liberation_4=${Y_liberation_4}" >> wm.conf
echo "n_scroll_libe=${n_scroll_libe}" >> wm.conf
