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
	local time_file="$current_servname.$1.timestamp"
	echo "*** Manual reset timestamp ***"
	reset_timestamp $time_file
	log_msg "** manual reset of $time_file"
}

dialog_reset_timestamps() {
	local actions="Quit mapcycle daily"
	select i_reset in $actions; do
		case $i_reset in
			Quit ) echo "Choice : $i_reset"
				break;;
			mapcycle ) echo "Choice : $i_reset"
				manual_reset_timestamps "mapcycle"
				continue;;
			daily ) echo "Choice : $i_reset"
				manual_reset_timestamps "daily"
				continue;;
			* ) echo "Invalid choice : $i_reset"
				continue;;
		esac
	done
}

interactive_session() {
	local actions="Quit Assisted-Map Brute-Force Learn-Map Reset-Timestamps"

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
	local elapsed=$(get_elapsed $time_file)
	echo
	echo "Elapsed $1 Time since reset : $elapsed / $2 half hours"
	if [ "$elapsed" -ge "$2" ]; then
		echo "*** Auto reset timestamp ***"
		reset_timestamp $time_file
		log_msg "** auto reset of $time_file"
	fi
}

check_scheduled_tasks() {
	local ls_todo=$(ls ./tmp/$current_servname.*.todo)
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
			* ) echo "Invalid choice : $i_choice"
				continue;;
		esac
	done
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

i=1
while true; do
	echo
	echo "macro cycle ${i}"

	for i_serv in $@; do
		./switch-server.sh $i_serv
		source switch.conf
		server_config="$current_servname.firestone.conf"
		echo "reading $server_config"
		source $server_config

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
		read_timestamps "mapcycle" 12
		read_timestamps "daily" 48
		echo
		echo "3 minutes idle mode... interrupt with CTRL+C"
		echo "type any key + RETURN for manual mode"
		read -t 120 -p "or hit only RETURN to speed-up > " user_input
		echo
		if [ -n "$user_input" ]; then
			interactive_session
		fi

		check_scheduled_tasks
		echo "1 minutes idle mode... interrupt with CTRL+C"
		echo "type any key + RETURN for manual mode"
		read -t 50 -p "or hit only RETURN to speed-up > " user_input
		echo
		if [ -n "$user_input" ]; then
			interactive_scheduled
		fi
		echo "idle mode ends in 10 secdonds"
		sleep 10
		echo "starting automated sequence"

		auto_reset_timestamps "mapcycle" 12
		auto_reset_timestamps "daily" 48

		xdotool windowactivate --sync $gamewin_id

		launch_claim_all_timer_income

		curr_flag=${flags_H[$i_serv]-false}
		if $curr_flag; then
			echo "auto-accept on for $i_serv"
			go_to_town
			click_and_go $X_guild_portal $Y_guild_portal
			click_and_go $X_guild_hall $Y_guild_hall
			click_and_go $X_applications $Y_applications
			click_and_go $X_accept_player $Y_accept_player
			focus_and_back_to_root_screen
		else
			echo "auto-accept off for $i_serv"
		fi
	done

	i=$((i+1))
done
