#!/bin/bash
source function-lib.sh
source win_id.conf

source ftree.conf
source switch.conf

radish_message_noprompt "AUTOMATIC FTREE TOOL"
echo
echo "for manual configuration of ftree.conf. Use :"
echo "./auto-ftree config"
echo "for running ftree automation, use command without argument"
echo

### ### ###

ftree_rewind() {
	go_to_ftree
	xdotool mousemove --window $gamewin_id 700 450
	sleep 1
	roll_scroll_up $ftree_n_scroll
	roll_scroll_up $((ftree_n_scroll/2))
	FtreeGlob_currPage="1"
}

ftree_page_forward() {
	go_to_ftree
	if [ "$FtreeGlob_currPage" -lt "2" ]; then
		xdotool mousemove --window $gamewin_id 700 450
		sleep 1
		roll_scroll_down $ftree_n_scroll
		FtreeGlob_currPage=$((FtreeGlob_currPage+1))
	fi
}

ftree_page_backward() {
	go_to_ftree
	if [ "$FtreeGlob_currPage" -gt "1" ]; then
		xdotool mousemove --window $gamewin_id 700 450
		sleep 1
		roll_scroll_up $ftree_n_scroll
		FtreeGlob_currPage=$((FtreeGlob_currPage-1))
	fi
}

ftree_page_1() {
	if [ "$FtreeGlob_currPage" -gt "1" ]; then
		ftree_page_backward
	fi
}

ftree_page_2() {
	if [ "$FtreeGlob_currPage" -lt "2" ]; then
		ftree_page_forward
	fi
}

load_ftree_from_file() {
	echo "*** loading $1 ***"
	source $1
	ftree_rewind
	if [ "$FtreeGlob_currPage" -eq "2" ]; then
		ftree_page_2
	else
		ftree_page_1
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

	echo "** NODE $node_number **"
	for attr in $attributes; do
		local var_name="FtreeNode_${node_number}_$attr"
		echo "$var_name=$(get_node_attribute $node_number $attr)"
	done
}

print_ftree_info() {
	local ftree_file=$1

	echo "****************************************************************"
	echo "**** $ftree_file"
	echo "*** $FtreeGlob_name ; $FtreeGlob_time half-hours per node"
	echo "*** currently on page $FtreeGlob_currPage"
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

append_var_and_val() {
	local var_name=$1
	local save_file=$2
	local value=$(eval "echo \$$var_name")
	echo "${var_name}=\"$value\"" >> $save_file
}

save_ftree_to_file() {
	echo "*** saving $1 ***"
	local save_file=$1
	local attributes="name levelMax levelCurr unlockReq pageNumber columnIndex slotKind slotIndex"

	echo "# automatically written" > $save_file

	echo >> $save_file
	echo "### GLOBAL DATA ###" >> $save_file
	append_var_and_val "FtreeGlob_name" $save_file
	append_var_and_val "FtreeGlob_time" $save_file
	append_var_and_val "FtreeGlob_currPage" $save_file

	local num_node=1
	while [ "$num_node" -le "16" ]; do
		echo >> $save_file
		echo "### NODE $num_node ###" >> $save_file
		for attr in $attributes; do
			local var_name="FtreeNode_${num_node}_$attr"
			append_var_and_val $var_name $save_file
		done
		num_node=$((num_node+1))
	done
}

X_ftree_node() {
	local i_column=$(get_node_attribute "$1" "columnIndex")
	local n_page=$(get_node_attribute "$1" "pageNumber")
	local X_node=""
	if [ "$n_page" -eq "2" ]; then
		i_column=$((i_column-4))
		X_node=${X_ftree_page_2[$i_column]}
	else
		X_node=${X_ftree_page_1[$i_column]}
	fi
	echo "$X_node"
}

Y_ftree_node() {
	local n_line=$(get_node_attribute "$1" "slotKind")
	local i_line=$(get_node_attribute "$1" "slotIndex")
	local Y_node=""
	if [ "$n_line" -eq "3" ]; then
		Y_node=${Y_ftree_3_slot[$i_line]}
	elif [ "$n_line" -eq "2" ]; then
		Y_node=${Y_ftree_2_slot[$i_line]}
	else
		Y_node=${Y_ftree_1_slot[$i_line]}
	fi
	echo "$Y_node"
}

goto_ftree_node() {
	local n_page=$(get_node_attribute "$1" "pageNumber")
	if [ "$n_page" -eq "2" ]; then
		ftree_page_2
	else
		ftree_page_1
	fi
	xdotool mousemove $(X_ftree_node $1) $(Y_ftree_node $1)
	sleep 2
}

### ### ###


## first things to do ##

#test_file="ftree/s31.ftree.dat"
#load_ftree_from_file $test_file
#print_ftree_info $test_file

if [ ! -f "switch.conf" ]; then
	echo "Error : switch.conf not found. Cannot determine server"
	exit
fi
echo "*** doing ftree on server $current_servname ***"

ftree_fullpath="./ftree/${current_servname}.ftree.dat"
if [ ! -f "$ftree_fullpath" ]; then
	echo "Error : cannot find ftree file $ftree_fullpath"
	exit
fi

# do not load now
#load_ftree_from_file $ftree_fullpath

## manual setting of node coordinates ##

if [ "$1" == "config" ]; then
	load_ftree_from_file $ftree_fullpath
	echo "**** manual configuration ****"
	ftree_page_1
	read -p "press RETURN for next page"
	ftree_page_2
	read -p "press RETURN to finish"
	exit
fi

## back to normal ##
# NOT REACHED IF CONFIGURATION IS CHOSEN

wait_fullpath="./tmp/${current_servname}.ftreewait.todo"
if [ ! -f "$wait_fullpath" ]; then
	echo "** no wait directive $wait_fullpath **"
	no_wait=true
else
	echo "** wait directive scheduled in $wait_fullpath **"
	no_wait=false
fi

todo_fullpath="./tmp/${current_servname}.ftreestart.todo"
if [ ! -f "$todo_fullpath" ]; then
	echo "Error : cannot find schedule file $todo_fullpath"
	exit
fi

## automation starts here ##
# todo file format is one node number or w letter (actually anything invalid)
# per line. each call to automation script reads 2 lines exactly
# one ftree slot per node number (they must be different)
# if a line contains 1 invalid entry (not a node number) then it means that
# 1 slot remains unused

valid_cmd() {
	if [[ "$1" =~ ^[0-9]+$ ]]; then
		if [ "$1" -ge "1" ] && [ "$1" -le "16" ]; then
			echo true
			return
		fi
	fi
	# NOT REACHED IF VALID
	echo false
}

ftree_cmd_1=""
ftree_cmd_2=""
n_read=0
if [ -s "$todo_fullpath" ]; then
	ftree_cmd_1=$(head -n 1 $todo_fullpath)
	n_read=1
	sed -i '1d' $todo_fullpath
else
	echo "Warning : $todo_fullpath is empty on startup. removing"
	rm -f $todo_fullpath
	echo "* nothing to do"
	exit
fi

# NOT REACHED IF SCHEDULE FILE WAS EMPTY ON START UP
if $(valid_cmd $ftree_cmd_1); then
	echo "Command 1 : node $ftree_cmd_1"
else
	echo "Error : command 1 value is $ftree_cmd_1"
	echo "must be valid (1...16)"
	exit
fi

# NOT REACHED IF FIRST COMMAND IS INVALID
if [ -s "$todo_fullpath" ]; then
	ftree_cmd_2=$(head -n 1 $todo_fullpath)
	n_read=2
	sed -i '1d' $todo_fullpath
else
	ftree_cmd_2="w"
fi

if $(valid_cmd $ftree_cmd_2); then
	echo "Command 2 : node $ftree_cmd_2"
else
	ftree_cmd_2="w"
	echo "Command 2 : ${ftree_cmd_2}ait"
fi

if [ ! -s "$todo_fullpath" ]; then
	echo "Schedule file is empty now. Removing"
	rm -f $todo_fullpath
fi


#load_ftree_from_file $ftree_fullpath


#save_ftree_to_file "ftree/testfile.dat"
