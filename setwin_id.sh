#!/bin/bash

# PROMPT USER FOR GAME WINDOW AND SAVE ID IN FILE


echo "put your mouse above the game window, do not click"
read -p "press return key..."
gamewin_id=$(xdotool getmouselocation | grep -oP 'window:\K\d+')
echo id: $gamewin_id
echo "writing to win_id.conf"
echo "gamewin_id=${gamewin_id}" > win_id.conf
