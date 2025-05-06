#!/bin/bash
source function-lib.sh

source win_id.conf

# User defined variables
# default values
X_WIN_POS="-26"
Y_WIN_POS="2"
WIN_WIDTH="1430"
WIN_HEIGHT="947"
# overwrite with user defined values in file
source view.conf

echo "MAKE SURE ./setwin_id HAS BEEN RUN"
echo "AND THE GAME IS LOADING OR LOADED BEFORE DOING THIS"
radish_message "RESTORE GAME STANDARD VIEW"

xdotool windowactivate --sync $gamewin_id
sleep 1
echo "selected game window"
xdotool windowsize --sync $gamewin_id $WIN_WIDTH $WIN_HEIGHT
sleep 1
echo "resized"
xdotool windowmove --sync $gamewin_id $X_WIN_POS $Y_WIN_POS
sleep 1
echo "moved to top left"

X_sidebar=$((X_WIN_POS+WIN_WIDTH-30))
Y_sidebar=$((WIN_HEIGHT/4))
xdotool mousemove --sync $X_sidebar $Y_sidebar
sleep 1
xdotool click --delay 100 --repeat 15 4
sleep 1

xdotool mousedown 1
sleep 1
echo "hold left button"
xdotool mousemove_relative --sync 0 112
sleep 1
echo "... and drag"

# adjustment due to gui change on armor games platform
xdotool mousemove_relative --sync 0 -59

xdotool mouseup 1
sleep 1
echo "release left button"
