#
# Tools for remote management
#

enable_remote_ssh() {
	export DISPLAY=:0.0
	export XAUTHORITY=$HOME/.Xauthority
}

env_for_remote_or_local() {
	if [ -n "$SSH_CONNECTION" ]; then
		echo "* remote environment setup *"
		enable_remote_ssh
		export DETACHED_BOT=true
	else
		echo "* local environment setup *"
		export DETACHED_BOT=false
	fi
	## DETACHED_BOT needs to be defined as often and as soon as possible
}

detached_launcher() {
	if [ -n "$1" ] && [ -n "$2" ]; then
		local cmd=$1
		local out_f=$2
	else
		echo "not enough arguments provided"
		echo "detached_launcher <command> <stdout_file>"
		echo "all arguments are non optional"
		return
	fi
	# NOT REACHED IF ARGUMENT NUMBER CHECK FAILS

	local cmd_chk=$(which "$cmd")
	if [ -z "$cmd_chk" ]; then
		echo "no chance that $cmd is executable - skip"
		return
	else
		echo "command=$cmd_chk"
	fi
	# NOT REACHED IF RUN COMMAND CHECK FAILS

	echo "stdout_file=$out_f"

	enable_remote_ssh
	nohup $cmd > $out_f 2>&1 &
	disown
}

detached_cmd_line_launcher() {
	if [ -n "$1" ] && [ -n "$2" ] && [ -n "$3" ]; then
		local cmd=$1

		## WARNING : argument 2 may contain spaces
		local args="$2"

		local out_f=$3
	else
		echo "not enough arguments provided"
		echo "detached_cmd_line_launcher <command> <\"arguments\"> <stdout_file>"

		echo "all arguments are non optional"
		return
	fi
	# NOT REACHED IF ARGUMENT NUMBER CHECK FAILS

	local cmd_chk=$(which "$cmd")
	if [ -z "$cmd_chk" ]; then
		echo "no chance that $cmd is executable - skip"
		return
	else
		echo "command=$cmd_chk"
	fi
	# NOT REACHED IF RUN COMMAND CHECK FAILS

	echo "arguments=\"$args\""
	echo "stdout_file=$out_f"

	enable_remote_ssh
	nohup $cmd "$args" > $out_f 2>&1 &
	disown
}

remote_screenshot() {
	enable_remote_ssh
	import -window root /tmp/remote-shot.png
}

clear_locks() {
	remove_task ${PAUSE_LOCK##*/}
	remove_task ${STOP_LOCK##*/}
	remove_task ${SLEEP_LOCK##*/}
}

search_bot_pid() {
	echo "-- search bot pid critical debug --" 1>&2

	local filter_ps_a=$(ps -ax | grep -v grep | grep -v vi | grep multi-cycle-run)

	echo "- filtered ps ax results" 1>&2
	echo "$filter_ps_a" 1>&2

	local tok n_pid
	for tok in $filter_ps_a; do
		echo "- token $tok" 1>&2
		# pid is first token separated by built-in separator
		n_pid=$tok
		break
	done
	echo "- check if n_pid variable is empty : n_pid=$n_pid" 1>&2
	if [ -z "$n_pid" ]; then
		echo "- really empty" 1>&2
	fi

	echo $n_pid
}

killall_bots() {
	local bot_pid=$(search_bot_pid)

	while [ -n "$bot_pid" ]; do
		echo "* found instance of multi-cycle-run.sh : $bot_pid"
		kill $bot_pid
		bot_pid=$(search_bot_pid)

	done
	clear_locks
	echo "*** killed all multi-cycle-run.sh ***"
}

get_server_cycle() {
	local start_server=$1
	local server_cycle
	if [ "$start_server" == "s1" ]; then
		server_cycle="s1 s31 s27 s1 s31 s27 s14"
	elif [ "$start_server" == "s27" ]; then
		server_cycle="s27 s1 s31 s27 s1 s31 s14"
	else
		server_cycle="s31 s27 s1 s31 s27 s1 s14"
	fi
	echo $server_cycle
}

restricted_server_cycle() {
	local start_server=$1
	local server_cycle
	if [ "$start_server" == "s1" ]; then
		server_cycle="s1 s1 s1 s1 s1 s1 s1"
	elif [ "$start_server" == "s27" ]; then
		server_cycle="s27 s27 s27 s27 s27 s27 s27"
	else
		server_cycle="s31 s31 s31 s31 s31 s31 s31"
	fi
	echo $server_cycle
}

remote_auto_firestone_start() {
	## always make sure that DISPLAY and XAUTHORITY are set
	enable_remote_ssh

	## helps detecting detached process
	export DETACHED_BOT=true

	## ensures that there is no running firefox with brute force
	killall firefox
	echo "*** blind killed all firefox ***"

	## kill all instances of multi-cycle-run.sh
	killall_bots

	./firestone-starter.sh
	starter_err=$?
	if [ "$starter_err" == "0" ]; then
		echo "*** firestone started ***"
		log_msg "*** firestone started before bot launch ***"
	else
		echo "*** firestone start failed ***"
		log_msg "*** firestone start failed before bot launch ***"
		return
	fi
	# NOT REACHED IF GAME START FAILS

	local server_cycle=$(get_server_cycle $1)
	#local server_cycle=$(restricted_server_cycle $1)

	detached_cmd_line_launcher ./multi-cycle-run.sh "$server_cycle" ./tmp/cycle-run.out

	echo "*** bot started ***"
}

local_auto_firestone_start() {
	## helps detecting local process
	export DETACHED_BOT=false

	## ensures that there is no running firefox with brute force
	killall firefox
	echo "*** blind killed all firefox ***"

	## kill all instances of multi-cycle-run.sh
	killall_bots

	./firestone-starter.sh
	starter_err=$?
	if [ "$starter_err" == "0" ]; then
		echo "*** firestone started ***"
	else
		echo "*** firestone start failed ***"
		return
	fi
	# NOT REACHED IF GAME START FAILS

	local server_cycle=$(get_server_cycle $1)

	echo "*** starting bot ***"
	./multi-cycle-run.sh "$server_cycle"
}

remote_only_bot_start() {
	## always make sure that DISPLAY and XAUTHORITY are set
	enable_remote_ssh

	## helps detecting detached process
	export DETACHED_BOT=true

	## kill all instances of multi-cycle-run.sh
	killall_bots

	local server_cycle=$(get_server_cycle $1)
	#local server_cycle=$(restricted_server_cycle $1)

	detached_cmd_line_launcher ./multi-cycle-run.sh "$server_cycle" ./tmp/cycle-run.out

	echo "*** bot started ***"
}

local_only_bot_start() {
	## helps detecting local process
	export DETACHED_BOT=false

	## kill all instances of multi-cycle-run.sh
	killall_bots

	## overwrite former value of termwin_id
	# this operation is performed in firestone-start.sh
	# need to compensate because of :
	# restarting locally after the end of a remote session
	# without firestone quit
	termwin_id=$(xdotool getwindowfocus)
	echo "termwin_id=${termwin_id}" >> win_id.conf

	local server_cycle=$(get_server_cycle $1)

	echo "*** starting bot ***"
	./multi-cycle-run.sh "$server_cycle"
}

# LOCK 1
PAUSE_LOCK="./tmp/pause.todo"
# Right now, use ${PAUSE_LOCK##*/} to remove path
#

pause_firestone_bot() {
	local t_pause=$1
	local minutes
	# restrict the range of possible pause time
	# for the sake of robustness : s, m, l, xl, xxl, defaults to s
	case $t_pause in
		"s") minutes="5";;
		"m") minutes="10";;
		"l") minutes="15";;
		"xl") minutes="20";;
		"xxl") minutes="25";;
		*) minutes="5";;
	esac
	schedule_task ${PAUSE_LOCK##*/}
	echo "$minutes" >> $PAUSE_LOCK
}

continue_firestone_bot() {
	remove_task ${PAUSE_LOCK##*/}
}

# LOCK 2
STOP_LOCK="./tmp/stop.todo"

# non cancelable
stop_firestone_bot() {
	schedule_task ${PAUSE_LOCK##*/}
	schedule_task ${STOP_LOCK##*/}
}

# LOCK 3
SLEEP_LOCK="./tmp/sleep.todo"

sleep_end_cycle() {
	schedule_task ${SLEEP_LOCK##*/}
}

### #### ### ### ### ### ### ### ### ### ### #### ###
### Functions for remote interactive intervention ###
### #### ### ### ### ### ### ### ### ### ### #### ###

mouse_center() {
	xdotool windowactivate --sync $gamewin_id
	xdotool mousemove --window $gamewin_id 630 450
}

mouse_up() {
	local offset=${1:-"20"}
	xdotool mousemove_relative -- 0 -$offset
}

mouse_down() {
	local offset=${1:-"20"}
	xdotool mousemove_relative -- 0 $offset
}

mouse_left() {
	local offset=${1:-"20"}
	xdotool mousemove_relative -- -$offset 0
}

mouse_right() {
	local offset=${1:-"20"}
	xdotool mousemove_relative -- $offset 0
}

hotkey() {
	local k=${1:-"Escape"}
	xdotool key $k
}

inspect_alchemy() {
	go_to_alchemy
	sleep 10
	move_wait_click $X_alch_current_tree $Y_alch_current_tree 2
}

mouse_location() {
	local mouseloc=$(xdotool getmouselocation)
	local xx=$(echo "$mouseloc" | grep -oP 'x:\K\d+')
	local yy=$(echo "$mouseloc" | grep -oP 'y:\K\d+')
	echo "$xx,$yy"
}

dragdrop_left() {
	local offset=${1:-"80"}
	local xy=$(mouse_location)
	local x_curr=${xy%,*}
	local y_curr=${xy#*,}

	local x_dest=$((x_curr - offset))
	local y_dest=$y_curr

	smooth_drag_and_drop $x_curr $y_curr $x_dest $y_dest ".01"
}

dragdrop_right() {
	local offset=${1:-"80"}
	local xy=$(mouse_location)
	local x_curr=${xy%,*}
	local y_curr=${xy#*,}

	local x_dest=$((x_curr + offset))
	local y_dest=$y_curr

	smooth_drag_and_drop $x_curr $y_curr $x_dest $y_dest ".01"
}

dragdrop_up() {
	local offset=${1:-"80"}
	local xy=$(mouse_location)
	local x_curr=${xy%,*}
	local y_curr=${xy#*,}

	local x_dest=$x_curr
	local y_dest=$((y_curr - offset))

	smooth_drag_and_drop $x_curr $y_curr $x_dest $y_dest ".01"
}

dragdrop_down() {
	local offset=${1:-"80"}
	local xy=$(mouse_location)
	local x_curr=${xy%,*}
	local y_curr=${xy#*,}

	local x_dest=$x_curr
	local y_dest=$((y_curr + offset))

	smooth_drag_and_drop $x_curr $y_curr $x_dest $y_dest ".01"
}

### ### ### ### ### ### ### ### ### ### ### ### ### ###
### Extra remote tools for mini event loot claiming ###
### ### ### ### ### ### ### ### ### ### ### ### ### ###

open_event_window() {
	focus_and_back_to_root_screen
	move_wait_click $X_events_window_open $Y_events_window_open 2
}

choose_event() {
	local ev_choice=$1
	if [ -z "$ev_choice" ]; then
		echo "* no event choice (1,2,3) given. skip"
		return
	elif [[ ! "$ev_choice" =~ ^[0-9]+$ ]]; then
		echo "* argument 1 is not a positive int : $ev_choice. skip"
		return
	elif [ "$ev_choice" -lt "1" ] || [ "$ev_choice" -gt "3" ]; then
		echo "* event number not in range (1,2,3) : $ev_choice. skip"
		return
	else
		echo "* select event $ev_choice"
	fi
	# NOT REACHED IF NO VALID ARGUMENT FOR EVENT CHOICE
	local xx_ev yy_ev
	eval "xx_ev=\$X_event_slot_$ev_choice"
	eval "yy_ev=\$Y_event_slot_$ev_choice"
	move_wait_click $xx_ev $yy_ev 2
}

event_challenge_tab() {
	move_wait_click $X_event_challenge_tab $Y_event_challenge_tab 2
}

claim_event_loot() {
	local i_quest=$1
	if [ -z "$i_quest" ]; then
		echo "* no quest choice (1,2,3) given. skip"
		return
	elif [[ ! "$i_quest" =~ ^[0-9]+$ ]]; then
		echo "* argument 1 is not a positive int : $i_quest. skip"
		return
	elif [ "$i_quest" -lt "1" ] || [ "$i_quest" -gt "3" ]; then
		echo "* quest number not in range (1,2,3) : $i_quest. skip"
		return
	else
		echo "* select quest $i_quest"
	fi
	# NOT REACHED IF NO VALID ARGUMENT FOR QUEST CHOICE
	local xx_qu yy_qu
	eval "xx_qu=\$X_claim_event_loot_$i_quest"
	eval "yy_qu=\$Y_claim_event_loot_$i_quest"
	move_wait_click $xx_qu $yy_qu 2
}

### ### ### ### ### ### ### ## ###
### Map-cycle timestamp change ###
### ### ### ### ### ### ### ## ###

fix_mapcycle_timestamp() {
	local map_time ts_6h ts_map ts_diff
	map_time=$1
	if [ -n "$map_time" ]; then
		echo "* user provided map-cycle reset time is : $map_time"

		ts_6h=$(date -d "06:00" +%s)
		ts_map=$(date -d "$map_time" +%s)
		if [ -z "$ts_map" ]; then
			# bad format
			ts_diff=""
		elif [ "$ts_map" -ge "$ts_6h" ]; then
			# another issue...
			# better avoid negative
			ts_diff=""
		else
			# all good
			ts_diff=$((ts_6h-ts_map))
		fi
	else
		echo "* default value of map-cycle reset time is 06:00"
		# no tweek required
		ts_diff=""
	fi

	if [ -n "$ts_diff" ]; then
		echo "With time correction of $ts_diff secs"
	fi
	source switch.conf
	local time_file="$current_servname.mapcycle.timestamp"
	echo "*** reset mapcycle timestamp ***"
	reset_timestamp $time_file $ts_diff
	log_msg "** reset of $time_file"
	if [ -n "$ts_diff" ]; then
		log_msg "* time correction : $ts_diff secs"
	fi
}

### #### ### #### ###
### Log shortcuts ###
### #### ### #### ###

shortcut_log() {
	case $1 in
		"cycle") tail -n 60 tmp/cycle-run.out;;
		"switch") tail -n 100 tmp/firestone.log | grep "switch from";;
		"crash") tail -n 20000 tmp/firestone.log | grep "crash";;
		*) echo "** usage : shortcut_log cycle|switch|crash";;
	esac
}
