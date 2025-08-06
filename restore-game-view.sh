#!/bin/bash
source glob-coord.conf
source function-lib.sh

source win_id.conf

# User defined variables
# default values
# identation makes variables invisible to coordinate manager
	X_WIN_POS="-26"
	Y_WIN_POS="2"
WIN_WIDTH="1430"
WIN_HEIGHT="947"
# overwrite with user defined values in file
source view.conf

echo "MAKE SURE ./setwin_id HAS BEEN RUN"
echo "AND THE GAME IS LOADING OR LOADED BEFORE DOING THIS"
radish_message_noprompt "RESTORE GAME STANDARD VIEW"

xdotool windowactivate --sync $gamewin_id
sleep 1
echo "selected game window"
xdotool windowsize --sync $gamewin_id $WIN_WIDTH $WIN_HEIGHT
sleep 1
echo "resized"
xdotool windowmove --sync $gamewin_id $X_WIN_POS $Y_WIN_POS
sleep 1
echo "moved to top left"

# identation makes variables invisible to coordinate manager
	X_sidebar=$((X_WIN_POS+WIN_WIDTH-30))
	Y_sidebar=$((WIN_HEIGHT/4))

xdotool mousemove --sync $X_sidebar $Y_sidebar
sleep 1
move_wait_only $X_sidebar $Y_sidebar 2
#xdotool click --delay 100 --repeat 15 4
roll_scroll_up 15 ".1"
sleep 1

#xdotool mousedown 1
#sleep 1
echo "hold left button"
#xdotool mousemove_relative --sync 0 112
echo "... and drag"
sleep 1

# adjustment due to gui change on armor games platform
#xdotool mousemove_relative --sync 0 -59

#xdotool mouseup 1

smooth_drag_and_drop $X_sidebar $Y_sidebar $X_sidebar $((Y_sidebar+112-59)) ".01"

sleep 1
echo "release left button"
