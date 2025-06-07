# this one can remain non executable
# use it with source function-lib.sh


radish_message() {
	echo "THIS IS RADISH AUTOMATION TOOL \\o/"
	echo "$1"
	echo "DISCLAIMER : always keep in mind what a happy radish is"
	read -p "press return key... or CTRL+C :)"
}

radish_message_noprompt() {
	echo "THIS IS RADISH AUTOMATION TOOL \\o/"
	echo "$1"
	echo "DISCLAIMER : always keep in mind what a happy radish is"
}

set_mouse_coordinates() {
	#sleep 1
	xdotool windowactivate --sync $termwin_id
	echo "stay in the terminal where the script is running"
	read -p "put your mouse pointer above $1 and hit return key"
	local mouseloc=$(xdotool getmouselocation)
	local cmd_X="$2=\$(echo "\$mouseloc" | grep -oP 'x:\\K\\d+')"
	#echo $cmd_X
	local cmd_Y="$3=\$(echo "\$mouseloc" | grep -oP 'y:\\K\\d+')"
	#echo $cmd_Y
	eval $cmd_X
	eval $cmd_Y
}

test_and_exit() {
	X_max=$((X_WIN_POS+WIN_WIDTH))
	Y_max=$((Y_WIN_POS+WIN_HEIGHT))
	if [ "$1" -gt "$X_max" ] || [ "$2" -gt "$Y_max" ]; then
		exit 0
	fi
}

roll_scroll_down() {
	echo "*** WARNING : UNSAFE FUNCTION ***"
	local i=0
	while [ "$i" -lt "$1" ]; do
		xdotool click 5
		sleep 1
		i=$((i+1))
	done
}

roll_scroll_up() {
	echo "*** WARNING : UNSAFE FUNCTION ***"
	local i=0
	while [ "$i" -lt "$1" ]; do
		xdotool click 4
		sleep 1
		i=$((i+1))
	done
}

drag_and_drop() {
	xdotool mousemove $1 $2
	sleep 1
	xdotool mousedown 1
	sleep 2
	xdotool mousemove $3 $4
	sleep 1
	xdotool mouseup 1
	sleep 1
}

smooth_drag_and_drop() {
	#xdotool windowactivate --sync $gamewin_id
	local x1=$1
	local y1=$2
	xdotool mousemove $x1 $y1
	sleep 1

	local x2=$3
	local y2=$4
	local nx=$((x2-x1))
	local ny=$((y2-y1))
	local incr_x=1
	if [ "$nx" -lt "0" ]; then
		incr_x="-1"
	fi
	local incr_y=1
	if [ "$ny" -lt "0" ]; then
		incr_y="-1"
	fi

	xdotool click 1
	sleep 1
	xdotool mousedown 1
	sleep 2

	while [ "$x1" -ne "$x2" ]; do
		x1=$((x1+incr_x))
		xdotool mousemove_relative -- $incr_x 0
		sleep .04
	done
	while [ "$y1" -ne "$y2" ]; do
		y1=$((y1+incr_y))
		xdotool mousemove_relative -- 0 $incr_y
		sleep .04
	done

	sleep 2
	xdotool mouseup 1
	sleep 1
}

### ### ### ### ### ###
## MOTION FUNCTIONS  ##
### ### ### ### ### ###

super_slow_click() {
	xdotool mousedown 1
	sleep 1
	xdotool mouseup 1
	sleep 1
}

slow_safe_click() {
	xdotool mousedown 1
	sleep .4
	xdotool mouseup 1
	sleep .4
}

move_wait_click() {
	xdotool mousemove $1 $2
	sleep $3
	#xdotool click 1
	slow_safe_click
	# constant micro temporisatrion now included in click function
}

move_wait_only() {
	xdotool mousemove $1 $2
	sleep $3
}

click_and_go() {
	if [ -n "$3" ]; then
		echo "let's move to $3"
	fi
	#sleep 1
	# gamewin_id is a global variable defined by
	# source win_id.conf
	xdotool windowactivate --sync $gamewin_id
	# Move, Wait, Click paradigm
	move_wait_click $1 $2 1
}

focus_and_back_to_root_screen() {
	#sleep 1
	xdotool windowactivate --sync $gamewin_id
	xdotool mousemove --window $gamewin_id 700 450
	sleep 1
	# i don't know why but this one is not so good
	#xdotool key --delay 1000 Escape Escape Escape Escape Escape Escape
	xdotool key Escape
	sleep .5
	xdotool key Escape
	sleep .5
	xdotool key Escape
	sleep .5
	xdotool key Escape
	sleep .5
	xdotool key Escape
	sleep .5
	xdotool key Escape
	sleep .5
}

go_to_town() {
	focus_and_back_to_root_screen
	xdotool key t
	# constant micro temporisatrion
	sleep .5
}

go_to_oracle() {
	focus_and_back_to_root_screen
	xdotool key o
	# constant micro temporisatrion
	sleep .5
}

go_to_guardian() {
	focus_and_back_to_root_screen
	xdotool key g
	# constant micro temporisatrion
	sleep .5
}

go_to_map() {
	focus_and_back_to_root_screen
	xdotool key m
	# constant micro temporisatrion
	sleep .5
}

go_to_exotic() {
	focus_and_back_to_root_screen
	xdotool key x
	# constant micro temporisatrion
	sleep .5
}

go_to_settings() {
	focus_and_back_to_root_screen
	xdotool key s
	# constant micro temporisatrion
	sleep .5
}

go_to_ftree() {
	focus_and_back_to_root_screen
	xdotool key l
	sleep 2
	move_wait_click $X_ftree_tab $Y_ftree_tab 1
	# need to do it 3 times
	move_wait_click $X_ftree_tab $Y_ftree_tab 1
	move_wait_click $X_ftree_tab $Y_ftree_tab 2
	# constant micro temporisatrion
	sleep .5
}

go_to_alchemy() {
	focus_and_back_to_root_screen
	xdotool key a
	# constant micro temporisatrion
	sleep .5
}

go_to_daily_quests() {
	focus_and_back_to_root_screen
	xdotool key q
	sleep 2
	move_wait_click $X_daily_quests $Y_daily_quests 3
	move_wait_click $X_daily_quests $Y_daily_quests 2
	move_wait_click $X_daily_quests $Y_daily_quests 1
}

go_to_weekly_quests() {
	focus_and_back_to_root_screen
	xdotool key q
	sleep 2
	move_wait_click $X_weekly_quests $Y_weekly_quests 3
	move_wait_click $X_weekly_quests $Y_weekly_quests 2
	move_wait_click $X_weekly_quests $Y_weekly_quests 1
}

anti_ad() {
	#click_and_go $X_game_tab $Y_game_tab "anti-ad"
	# this one is not move_wait_click since it requires
	# --windows parameter for relative coodinates
	echo "anti-AD"
	# for pop-ups
	xdotool windowactivate --sync $gamewin_id
	sleep 1
	# for extra tabs
	xdotool mousemove --window $gamewin_id 220 40
	sleep 1
	xdotool click 1
	sleep .5
	xdotool mousemove --window $gamewin_id 700 450
	# and puts back mouse to window at the end
	# keys do not work if mouse is on tab selector
	# outside windows keys still work
}

### ### ### ### ### ###
## ACTION FUNCTIONS  ##
### ### ### ### ### ###

claim_and_restart() {
	move_wait_click $1 $2 $3
	sleep $4
	#move_wait_click $1 $2 $3
	# let's assume that mouse has not moved
	slow_safe_click
}

launch_and_claim_expedition() {
	go_to_town
	move_wait_click $X_guild_portal $Y_guild_portal 2
	#move_wait_click $X_exped $Y_exped 6
	# real issues with timing on this
	move_wait_only $X_exped $Y_exped 6
	super_slow_click

	claim_and_restart $X_exped_but $Y_exped_but 2 2
}

launch_and_claim_rituals() {
	go_to_oracle
	move_wait_click $X_ritual $Y_ritual 3

	claim_and_restart $X_ritual_1 $Y_ritual_1 2 2
	claim_and_restart $X_ritual_2 $Y_ritual_2 2 2
	claim_and_restart $X_ritual_3 $Y_ritual_3 2 2
	claim_and_restart $X_ritual_4 $Y_ritual_4 2 2
}

train_guardian() {
	go_to_guardian
	move_wait_click $X_guard $Y_guard 2
	move_wait_click $X_guard_train $Y_guard_train 2
}

claim_campaign_loot() {
	go_to_map
	move_wait_click $X_campaign $Y_campaign 3
	move_wait_click $X_campaign_loot $Y_campaign_loot 2
}

claim_tools() {
	go_to_town
	move_wait_click $X_engi $Y_engi 2
	move_wait_click $X_engi_shop $Y_engi_shop 3
	move_wait_click $X_toolclaim $Y_toolclaim 2
}

launch_claim_all_timer_income() {
	anti_ad
	echo "claim timer income"
	launch_and_claim_expedition
	if $1; then
		echo "*** game over : expedition only ***"
		return
	fi
	launch_and_claim_rituals
	train_guardian
	claim_campaign_loot
	claim_tools
	focus_and_back_to_root_screen
}

### ### ### ### ### ### ### ###
## TIME MANAGEMENT FUNCTIONS ##
### ### ### ### ### ### ### ###

reset_timestamp() {
	local time_file=$1
	if [ -z "$time_file" ]; then
		echo "Warning : expect file name as argument 1"
		time_file="default.timestamp"
	fi
	if [ ! -d "./tmp/" ]; then
		echo "Warning : ./tmp/ directory not found"
		echo "creating it"
		mkdir tmp
	fi
	local time_full_path="./tmp/$time_file"
	echo "reset timestamp using $time_full_path"
	# overwrite any existing file without check
	if [ -z "$2" ]; then
		# no tweek
		date +%F/%T/%s > $time_full_path
	else
		local ts_diff=$2
		local part_true=$(date +%F/%T)
		local ts_true=$(date +%s)
		local part_fake=$((ts_true-ts_diff))
		echo "$part_true/$part_fake" > $time_full_path
	fi
	cat $time_full_path
	# just check
	#echo "... actual timestamp is $(date +%s)"
}

get_elapsed() {
	local time_file=$1
	if [ -z "$time_file" ]; then
		echo "9999"
		return
	fi
	# NOT REACHED if argument 1 not provided
	if [ ! -d "./tmp/" ]; then
		echo "9999"
		return
	fi
	# NOT REACHED if tmp/ directory not found
	local time_full_path="./tmp/$time_file"
	if [ ! -f "$time_full_path" ]; then
		echo "9999"
		return
	fi
	# NOT REACHED if timestamp file not found
	local ts_txt=$(cat $time_full_path)
	local ts_num=${ts_txt#*/*/}
	if [ -z "$ts_num" ]; then
		echo "9999"
		return
	fi
	# NOT REACHED if timestamp file read fails
	local ts_now=$(date +%s)
	local n_halfhour=$(( (ts_now - ts_num) / 1800))
	echo "$n_halfhour"
}

log_msg() {
	if [ ! -d "./tmp/" ]; then
		echo "Warning : ./tmp/ directory not found"
		echo "creating it"
		mkdir tmp
	fi
	local log_file="./tmp/firestone.log"
	if [ ! -f "$log_file" ]; then
		echo "Warning : $log_file not found"
		echo "creating it"
		touch $log_file
	fi
	echo "$(date +%F/%T) $1" >> $log_file
}

schedule_task() {
	local task_file=$1
	if [ -z "$task_file" ]; then
		echo "Warning : argument 1 not provided. Nothing to schedule"
		return
	fi
	# NOT REACHED if argument 1 not provided
	if [ ! -d "./tmp/" ]; then
		echo "Warning : ./tmp/ not found. Nothing to schedule"
		return
	fi
	# NOT REACHED if tmp/ directory not found
	local task_full_path="./tmp/$task_file"
	if [ ! -f "$task_full_path" ]; then
		log_msg "* Scheduling $task_full_path"
	else
		log_msg "* Re-scheduling $task_full_path"
	fi
	touch "$task_full_path"
}

remove_task() {
	local task_file=$1
	if [ -z "$task_file" ]; then
		echo "Warning : argument 1 not provided. Nothing to remove"
		return
	fi
	# NOT REACHED if argument 1 not provided
	if [ ! -d "./tmp/" ]; then
		echo "Warning : ./tmp/ not found. Nothing to remove"
		return
	fi
	# NOT REACHED if tmp/ directory not found
	local task_full_path="./tmp/$task_file"
	if [ ! -f "$task_full_path" ]; then
		echo "Warning : $task_full_path not found. Nothing to remove"
	else
		rm -f "$task_full_path"
		log_msg "* Removing $task_full_path"
	fi
}

### ### ### ### ###
