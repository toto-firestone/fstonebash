#!/bin/bash
source glob-coord.conf
## not master.conf here because win_id.conf is not up to date
source view.conf

source function-lib.sh
source visual-lib.sh
source remote-tools.sh

termwin_id=$(xdotool getwindowfocus)
game_url="https://armorgames.com/firestone-idle-rpg-game/18485?tag-referral=idle"

#firefox $game_url &
# firefox can be launched with remote method
#detached_cmd_line_launcher firefox "$game_url" ./tmp/firefox.out ./tmp/firefox.pid

## launch firefox with non xterm method - avoids layout differences
## between local and ssh X11 settings
sleep 1
move_wait_click $X_window_manager_start $Y_window_manager_start 2
xdotool type --delay 200 "firefox"
xdotool key --delay 200 Return
sleep 30
xdotool type --delay 200 "$game_url"
xdotool key --delay 200 Return

echo "*** load armor games ***"
sleep 18
gamewin_id=$(xdotool getwindowfocus)

echo "gamewin_id: $gamewin_id, termwin_id: $termwin_id"
echo "gamewin_id=${gamewin_id}" > win_id.conf
echo "termwin_id=${termwin_id}" >> win_id.conf
echo "win_id.conf written"

xdotool windowactivate --sync $gamewin_id
sleep 1
echo "selected game window"
xdotool windowsize --sync $gamewin_id $WIN_WIDTH $WIN_HEIGHT
sleep 1
xdotool windowmove --sync $gamewin_id $X_WIN_POS $Y_WIN_POS
sleep 10
echo "ready to load"

start_load_game

sleep 1
./restore-game-view.sh

echo "***** wait for loading before close loot and event windows *****"
#echo "** interrupt with RETURN if loading finishes before time limit"
#read -t 180 -p " > " dummy

# 72 x 20 secs.
wait_game_start 16 20

xdotool windowactivate --sync $gamewin_id
move_wait_click $X_avatar $Y_avatar 2
move_wait_click $X_avatar $Y_avatar 2
focus_and_back_to_root_screen
echo
echo "***** ready to grind *****"
