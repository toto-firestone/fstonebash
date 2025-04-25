#!/bin/bash
source view.conf

termwin_id=$(xdotool getwindowfocus)
game_url="https://armorgames.com/firestone-idle-rpg-game/18485?tag-referral=idle"

firefox $game_url &
echo
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
sleep 5
echo "ready to load"

X_load=678
Y_load=823
xdotool mousemove $X_load $Y_load
sleep 1
xdotool click 1
sleep 10

xdotool windowactivate --sync $termwin_id
sleep 1
./restore-game-view.sh
