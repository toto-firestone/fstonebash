#!/bin/bash
source glob-coord.conf
source function-lib.sh

# PROMPT USER FOR GAME WINDOW AND SAVE ID IN FILE

radish_message_noprompt "RUN THIS AFTER BROWSER AND BEFORE ANY OTHER SCRIPT"
termwin_id=$(xdotool getwindowfocus)

echo "put your mouse above the game window, do not click"
read -p "press return key..."
gamewin_id=$(xdotool getmouselocation | grep -oP 'window:\K\d+')
echo "gamewin_id: $gamewin_id, termwin_id: $termwin_id"
echo "gamewin_id=${gamewin_id}" > win_id.conf
echo "termwin_id=${termwin_id}" >> win_id.conf

#set_mouse_coordinates "game tab selector" "X_game_tab" "Y_game_tab"
# xdotool mousemove --window $gamewin_id --sync 220 40
# no more game tab location
