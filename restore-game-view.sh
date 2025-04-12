#!/bin/bash
source function-lib.sh

source win_id.conf

# User defined variables
X_WIN_POS="-26"
Y_WIN_POS="2"
WIN_WIDTH="1430"
WIN_HEIGHT="947"

echo "MAKE SURE ./setwin_id HAS BEEB RUN BEFORE THIS"
radish_message "RESTORE GAME STANDARD VIEW"

xdotool windowactivate $gamewin_id
echo "selected game window"
xdotool windowsize --sync $gamewin_id $WIN_WIDTH $WIN_HEIGHT
echo "resized"
xdotool windowmove --sync $gamewin_id $X_WIN_POS $Y_WIN_POS
echo "moved to top left"

X_sidebar=$((X_WIN_POS+WIN_WIDTH-30))
Y_sidebar=$((WIN_HEIGHT/4))
xdotool mousemove $X_sidebar $Y_sidebar
xdotool click --delay 100 --repeat 15 4

xdotool mousedown 1
echo "hold left button"
xdotool mousemove_relative --sync 0 112
echo "... and drag"
xdotool mouseup 1
echo "release left button"
