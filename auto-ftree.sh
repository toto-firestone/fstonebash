#!/bin/bash
source function-lib.sh
source win_id.conf

source ftree.conf
source switch.conf

radish_message_noprompt "AUTOMATIC FTREE TOOL"

### ### ###

Ftree_current_page=1

ftree_page_forward() {
	if [ "$Ftree_current_page" -lt "2" ]; then
		xdotool mousemove --window $gamewin_id 700 450
		sleep 1
		roll_scroll_down $ftree_n_scroll
		Ftree_current_page=$((Ftree_current_page+1))
	fi
}

ftree_page_backward() {
	if [ "$Ftree_current_page" -gt "1" ]; then
		xdotool mousemove --window $gamewin_id 700 450
		sleep 1
		roll_scroll_up $ftree_n_scroll
		Ftree_current_page=$((Ftree_current_page-1))
	fi
}

ftree_page_1() {
	if [ "$Ftree_current_page" -gt "1" ]; then
		ftree_page_backward
	fi
}

ftree_page_2() {
	if [ "$Ftree_current_page" -lt "2" ]; then
		ftree_page_forward
	fi
}

X_ftree_mouse_test() {
	local Y_test=${Y_ftree_1_slot[0]}
	xdotool mousemove $1 $Y_test
	sleep 4
}

### ### ###

go_to_ftree

#ftree_page_2
#ftree_page_1
