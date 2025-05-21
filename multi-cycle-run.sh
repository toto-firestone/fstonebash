#!/bin/bash
source function-lib.sh

# THIS IS RADISH AUTOMATION TOOL
# MULTI SERVER RUN SCRIPT
# JUST EXPECT ./auto-cycle-config.sh has been successfully executed

radish_message_noprompt "MULTISERVER RUN SCRIPT FOR CURRENCY FARM CYCLES"

if [ ! -f "win_id.conf" ]; then
	echo "please provide a window id file with setwin_id.sh"
	exit 1
fi

source win_id.conf

if [ -z "$1" ]; then
	echo Error : expecting at least 1 server name as argument
	exit 1
fi

if [ -f "switch.conf" ]; then
	echo "Server swich file detected"

	for i_serv in $@; do
		server_config="$i_serv.firestone.conf"
		echo "looking for $server_config"
		if [ -f "$server_config" ]; then
			echo "$server_config found"
		else
			echo "error $server_config not found"
			exit 1
		fi
	done
else
	echo "error : switch.conf not found"
	exit 1
fi

if [ ! -f "auto-accept.conf" ]; then
	echo "error : missing auto-accept.conf file"
	exit 1
fi
source auto-accept.conf

echo "very basic checks performed..."

### ### ### ###

manual_reset_timestamps() {
	if [ -z "$1" ]; then
		echo "Warning : no argument for manual_reset_timestamps"
		echo "doing nothig"
		return
	fi
	# NOW REACHED if arguments 1 is not provided
	if [ -n "$2" ]; then
		echo "With time correction of $2 secs"
	fi
	local time_file="$current_servname.$1.timestamp"
	echo "*** Manual reset timestamp ***"
	reset_timestamp $time_file $2
	log_msg "** manual reset of $time_file"
	if [ -n "$2" ]; then
		log_msg "* time correction : $2 secs"
	fi
}

dialog_reset_timestamps() {
	local actions="Quit mapcycle daily"
	local i_reset map_time ts_6h ts_map ts_diff

	select i_reset in $actions; do
		case $i_reset in
			Quit ) echo "Choice : $i_reset"
				break;;
			mapcycle ) echo "Choice : $i_reset"
				echo "*** input remaining map time for correct clock ***"

				read -p "type [ hh:mm or nothing ] + RETURN > " map_time

				if [ -n "$map_time" ]; then
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
					# no tweek required
					ts_diff=""
				fi
				manual_reset_timestamps "mapcycle" $ts_diff
				continue;;
			daily ) echo "Choice : $i_reset"
				manual_reset_timestamps "daily"
				schedule_task "$current_servname.daily.todo"
				continue;;
			* ) echo "Invalid choice : $i_reset"
				continue;;
		esac
	done
}

interactive_session() {
	local actions="Quit Assisted-Map Brute-Force Learn-Map Reset-Timestamps"
	local i_todo

	xdotool windowactivate --sync $gamewin_id
	sleep 2
	xdotool windowactivate --sync $termwin_id
	select i_todo in $actions; do
		case $i_todo in
			Quit ) echo "Choice : $i_todo"
				break;;
			Assisted-Map ) echo "Choice : $i_todo"
				./assisted-map.sh
				continue;;
			Brute-Force ) echo "Choice : $i_todo"
				./brute-force.sh
				continue;;
			Learn-Map ) echo "Choice : $i_todo"
				./learning.sh
				continue;;
			Reset-Timestamps ) echo "Choice : $i_todo"
				dialog_reset_timestamps
				continue;;
			* ) echo "Invalid choice : $i_todo"
				continue;;
		esac
	done
}

read_timestamps() {
	if [ -z "$1" ]; then
		echo "Warning : no argument for read_timestamps"
		echo "doing nothig"
		return
	fi
	if [ -z "$2" ]; then
		echo "Warning : no duration before reset for read_timestamps"
		echo "doing nothig"
		return
	fi
	# NOW REACHED if arguments 1 and 2 are not provided
	local time_file="$current_servname.$1.timestamp"
	local elapsed=$(get_elapsed $time_file)
	echo
	echo "* reading $time_file"
	echo "Elapsed $1 Time since reset : $elapsed / $2 half hours"
}

auto_reset_timestamps() {
	if [ -z "$1" ]; then
		echo "Warning : no argument for auto_reset_timestamps"
		echo "doing nothig"
		return
	fi
	if [ -z "$2" ]; then
		echo "Warning : no duration before reset for auto_reset_timestamps"

		echo "doing nothig"
		return
	fi
	# NOW REACHED if arguments 1 and 2 are not provided
	local time_file="$current_servname.$1.timestamp"
	echo "* auto reset for $time_file"
	local elapsed=$(get_elapsed $time_file)
	echo
	#echo "Elapsed $1 Time since reset : $elapsed / $2 half hours"
	if [ "$elapsed" -ge "$2" ]; then
		echo "*** Auto reset timestamp ***"
		reset_timestamp $time_file
		log_msg "** auto reset of $time_file"
		read_timestamps $1 $2
		case $1 in
			daily ) echo "* reschedule task : $1"
				schedule_task "$current_servname.daily.todo";;
			* ) echo "* no task to reschedule for $1";;
		esac
	else
		echo "*** Nothing to do ***"
	fi
}

check_scheduled_tasks() {
	local ls_todo=$(ls ./tmp/$current_servname.*.todo)
	local i_file

	echo "*** sceduled todo list ***"
	if [ -z "$ls_todo" ]; then
		echo "Nothing"
	else
		for i_file in $ls_todo; do
			echo $i_file
		done
	fi
	echo "*** *** ***"
}

check_before_doit() {
	select ans in "do" "cancel"; do
		echo $ans
		break;
	done
}

interactive_scheduled() {
	local ls_todo=$(ls ./tmp/$current_servname.*.todo)
	local actions="Quit"
	local i_file i_choice

	xdotool windowactivate --sync $gamewin_id
	sleep 2
	xdotool windowactivate --sync $termwin_id
	for i_file in $ls_todo; do
		# remove directory
		local i_task=${i_file##*/}
		# remove server name
		i_task=${i_task#*.}
		# remove todo word
		i_task=${i_task%.*}
		actions="$actions $i_task"
	done

	echo "**** check if server is $current_servname and timer is ok before accepting ****"

	select i_choice in $actions; do
		case $i_choice in
			Quit ) echo "Choice : $i_choice"
				break;;
			dummy ) echo "Choice : $i_choice"
				if [ $(check_before_doit) == "do" ]; then
					echo "doing it"
					#
					# Some commands here
					#
					log_msg "* doing dummy on $current_servname"

				else
					echo "canceling it"
					log_msg "* canceling dummy on $current_servname"

				fi
				remove_task "$current_servname.dummy.todo"
				break;;
			daily ) echo "Choice : $i_choice"
				if [ $(check_before_doit) == "do" ]; then
					echo "doing it"
					./daily-once.sh
					log_msg "* doing daily on $current_servname"

				else
					echo "canceling it"
					log_msg "* canceling daily on $current_servname"

				fi
				remove_task "$current_servname.daily.todo"
				break;;
			* ) echo "Invalid choice : $i_choice"
				continue;;
		esac
	done
}

handle_fridaycode() {
	local friday_task="$current_servname.fridaycode.todo"
	if [ -f "./tmp/$friday_task" ]; then
		echo "* handling friday code on $current_servname"
		source "./tmp/$friday_task"
		go_to_settings
		move_wait_click $X_more $Y_more 2
		move_wait_click $X_code $Y_code 2
		xdotool type --delay 600 $reward_code
		move_wait_click $X_submit $Y_submit 2
		remove_task $friday_task
	fi
}

### ### ### ###
log_msg "***** multi server script starts *****"
ctrl_c() {
	log_msg "**** multi server script exits ****"
	echo
	exit 0
}
# disturbs stdin... not now
#trap ctrl_c SIGINT

### game over ###
source gameover.conf

### visual tools ###
source visual-lib.sh

i=1
while true; do
	echo
	echo "macro cycle ${i}"

	for i_serv in $@; do
		test_freeze "before switch to $i_serv"
		freeze_crit=$(tail -n 1 ./tmp/firestone.log | grep 'freeze=1')
		if [ -n "$freeze_crit" ]; then
			echo "*** freeze detected before switch to $i_serv"
			echo "*** skip all remaining servers"
			echo "*** reach restart at next macro cycle"
			break
		else
			echo "*** no freeze before switch to $i_serv"
		fi

		./switch-server.sh $i_serv
		source switch.conf
		server_config="$current_servname.firestone.conf"
		echo "reading $server_config"
		source $server_config
		gameover_status=$(game_is_over_on_server $current_servname)
		if $gameover_status; then
			echo "***** game is over on this server *****"
		fi

		read_timestamps "mapcycle" 12
		auto_reset_timestamps "mapcycle" 12
		read_timestamps "daily" 48
		auto_reset_timestamps "daily" 48
		echo

		# Scheduling a dummy task
		# if todo file already exists, just change his date
		schedule_task "$current_servname.dummy.todo"
		# at this stage, we must be aware that server switch
		# might have failed. in that case, $current_servname is
		# just one or more steps in front of real server name
		# The worse case is server switch remains stuck. Then any
		# scheduling request will follow the bot's own data.
		# Re-schedule again and again, without having the task
		# actually done is fine.

		xdotool windowminimize --sync $gamewin_id
		echo "screen and cpu saving during idle mode"
		sleep 2
		xdotool windowactivate --sync $termwin_id
		echo
		echo "2 minutes idle mode... interrupt with CTRL+C"
		echo "type any key + RETURN for manual mode"
		read -t 60 -p "or hit only RETURN to speed-up > " user_input1
		echo
		if [ -n "$user_input1" ]; then
			interactive_session
		fi

		check_scheduled_tasks
		echo "1 minutes idle mode... interrupt with CTRL+C"
		echo "type any key + RETURN for manual mode"
		read -t 50 -p "or hit only RETURN to speed-up > " user_input2
		echo
		if [ -n "$user_input2" ]; then
			interactive_scheduled
		fi

		read_timestamps "mapcycle" 12
		auto_reset_timestamps "mapcycle" 12
		echo
		if [ -n "$user_input1" ] || [ -n "$user_input2" ]; then
			echo "WARNING : manual intervention detected"
			echo "10 seconds before SKIP AUTO-MAP"
			sleep 10
		else
			echo "10 seconds before AUTO-MAP"
			sleep 10
			./auto-map.sh
		fi

		echo "... then auto alchemy"
		./auto-alch.sh

		echo "... then auto ftree"
		./auto-ftree.sh

		handle_fridaycode

		xdotool windowactivate --sync $gamewin_id

		launch_claim_all_timer_income $gameover_status

		source auto-accept.conf
		curr_flag=${flags_H[$i_serv]-false}
		if $curr_flag; then
			echo "auto-accept on for $i_serv"
			go_to_town
			move_wait_click $X_guild_portal $Y_guild_portal 2
			move_wait_click $X_guild_hall $Y_guild_hall 6
			sleep 5
			move_wait_click $X_applications $Y_applications 2
			move_wait_click $X_accept_player $Y_accept_player 2
			focus_and_back_to_root_screen
		else
			echo "auto-accept off for $i_serv"
		fi

		xdotool windowactivate --sync $termwin_id
		read_timestamps "mapcycle" 12
		auto_reset_timestamps "mapcycle" 12
		echo
		echo "***** LAST CHANCE TO CTRL+C BEFORE SERVER SWITCH *****"
		sleep 10
	done
	log_msg "quit firestone"
	#./firestone-quit.sh
	safe_quit
	./firestone-starter.sh
	log_msg "firestone restarted"

	i=$((i+1))
done
