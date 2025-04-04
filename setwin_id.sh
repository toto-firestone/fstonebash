#!/bin/bash
source function-lib.sh

# PROMPT USER FOR GAME WINDOW AND SAVE ID IN FILE


echo "put your mouse above the game window, do not click"
read -p "press return key..."
gamewin_id=$(xdotool getmouselocation | grep -oP 'window:\K\d+')
echo id: $gamewin_id
echo "writing to win_id.conf"
echo "gamewin_id=${gamewin_id}" > win_id.conf

echo "put your mouse above the terminal window of the scripts"
read -p "press return key..."
termwin_id=$(xdotool getmouselocation | grep -oP 'window:\K\d+')
echo id: $termwin_id
echo "writing to win_id.conf"
echo "termwin_id=${termwin_id}" >> win_id.conf

set_mouse_coordinates "game tab selector" "X_game_tab" "Y_game_tab"
echo "game tab selector at x: $X_game_tab, y: $Y_game_tab"
echo "X_game_tab=${X_game_tab}" >> win_id.conf
echo "Y_game_tab=${Y_game_tab}" >> win_id.conf
