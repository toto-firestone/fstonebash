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

get_node_attribute() {
	local node_number=$1
	local attr=$2
	local var_name="FtreeNode_${node_number}_$attr"
	local get_value
	eval "get_value=\$$var_name"
	echo "$get_value"
}

print_node_info() {
	local node_number=$1
	local attributes="name levelMax levelCurr unlockReq pageNumber columnIndex slotKind slotIndex"

	for attr in $attributes; do
		local var_name="FtreeNode_${node_number}_$attr"
		echo "$var_name=$(get_node_attribute $node_number $attr)"
	done
}

print_ftree_info() {
	local ftree_file=$1

	echo "****************************************************************"
	echo "**** $ftree_file"
	echo "****************************************************************"
	print_node_info "1"
	local prev_col_index=$(get_node_attribute "1" "columnIndex")
	local prev_page_num=$(get_node_attribute "1" "pageNumber")
	local i=2
	while [ "$i" -le "16" ]; do
		local curr_col_index=$(get_node_attribute "$i" "columnIndex")
		if [ "$curr_col_index" -gt "$prev_col_index" ]; then
			echo "************************************************"
		else
			echo "***********************"
		fi
		local curr_page_num=$(get_node_attribute "$i" "pageNumber")
		if [ "$curr_page_num" -gt "$prev_page_num" ]; then
			echo "************************************************"
		fi
		print_node_info "$i"
		prev_col_index=$curr_col_index
		prev_page_num=$curr_page_num
		i=$((i+1))
	done
	echo "****************************************************************"
	echo "**** end of ftree"
	echo "****************************************************************"
}

### ### ###

go_to_ftree

#ftree_page_2
#ftree_page_1

test_file="ftree/s31.ftree.dat"

source $test_file
print_ftree_info $test_file
