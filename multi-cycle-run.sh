#!/bin/bash
source glob-coord.conf
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

### ADDITIONAL VARIABLES THAT WILL BE MOVED... LATER ###

N_max_quests=10

### ### ### ###

reset_mapcycle_timestamps() {
	if [ -n "$1" ]; then
		echo "With time correction of $1 secs"
	fi
	local time_file="$current_servname.mapcycle.timestamp"
	echo "*** reset mapcycle timestamp ***"
	reset_timestamp $time_file $1
	log_msg "** reset of $time_file"
	if [ -n "$1" ]; then
		log_msg "* time correction : $1 secs"
	fi

	## manual reset of mapcycle timestamp -> quests claim task ##
	schedule_task "$current_servname.quests.todo"
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
				reset_mapcycle_timestamps $ts_diff
				continue;;
			daily ) echo "Choice : $i_reset"
				./daily-once.sh reset $current_servname
				continue;;
			* ) echo "Invalid choice : $i_reset"
				continue;;
		esac
	done
}

interactive_session() {
	local actions="Quit Brute-Force Learn-Map Reset-Timestamps"
	local i_todo

	xdotool windowactivate --sync $gamewin_id
	sleep 2
	xdotool windowactivate --sync $termwin_id
	select i_todo in $actions; do
		case $i_todo in
			Quit ) echo "Choice : $i_todo"
				break;;
			Brute-Force ) echo "Choice : $i_todo"
				./brute-force.sh $brute_force_time
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
	# do it again in seconds
	elapsed_sec=$(get_elapsed_sec $time_file)
	local t_cycle=$2
	local remain=$((1800*t_cycle - elapsed_sec))
	if [ "$remain" -lt "0" ]; then
		remain=0
	fi
	local zero_t=$(date -d "00:00" +%s)
	remain=$((zero_t + remain))
	echo "Elapsed $1 Time since reset : $elapsed / $2 half hours (countdown = $(date -d @$remain +%H:%M))"

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
		case $1 in
			daily ) echo "* reschedule task : $1"
				#schedule_task "$current_servname.daily.todo";;
				./daily-once.sh reset $current_servname;;

			## auto reset of mapcycle timestamp ##
			## -> quests claim task ##
			mapcycle ) echo "* mapcycle reset -> quests claim"
				#reset_timestamp $time_file
				#log_msg "** auto reset of $time_file"
				#schedule_task "$current_servname.quests.todo";;
				reset_mapcycle_timestamps;;

			* ) echo "* no task to reschedule for $1";;
		esac
	else
		echo "*** Nothing to do ***"
	fi
	read_timestamps $1 $2
	echo
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
		# Only adds valid task to action list
		if [ "$i_task" == "daily" ]; then
			actions="$actions $i_task"
		fi
	done

	echo "**** check if server is $current_servname and timer is ok before accepting ****"

	select i_choice in $actions; do
		case $i_choice in
			Quit ) echo "Choice : $i_choice"
				break;;
			daily ) echo "Choice : $i_choice"
				if [ $(check_before_doit) == "do" ]; then
					echo "doing it"
					./daily-once.sh "force"
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
		reward_code=$(cat ./tmp/$friday_task)
		go_to_settings
		move_wait_click $X_more $Y_more 2
		move_wait_click $X_code $Y_code 2
		xdotool type --delay 600 $reward_code
		move_wait_click $X_submit $Y_submit 2
		remove_task $friday_task
	fi
}

handle_auto_accept() {
	source auto-accept.conf
	local curr_flag=${auto_accept_flags_H[$current_servname]-false}
	if $curr_flag; then
		echo "auto-accept on for $current_servname"
		go_to_town
		move_wait_click $X_guild_portal $Y_guild_portal 2
		move_wait_click $X_guild_hall $Y_guild_hall 6
		sleep 5
		move_wait_click $X_applications $Y_applications 2
		move_wait_click $X_accept_player $Y_accept_player 2
		focus_and_back_to_root_screen
	else
		echo "auto-accept off for $current_servname"
	fi
}

handle_quests_claim() {
	if [ ! -f "./tmp/$current_servname.quests.todo" ]; then
		echo "* no quests claim"
		return
	else
		echo "* quests claim"
	fi
	# NOT REACHED IF NO SCHEDULE FILE
	go_to_daily_quests
	echo "* claim daily"
	local i_claim="0"
	while [ "$i_claim" -lt "$N_max_quests" ]; do
		move_wait_click $X_quests_claim $Y_quests_claim 1
		i_claim=$((i_claim+1))
	done

	local week_crit=$(date +%A | grep -E 'dimanche|lundi|mardi')
	if [ -n "$week_crit" ]; then
		go_to_weekly_quests
		echo "* claim weekly"
		i_claim="0"
		while [ "$i_claim" -lt "$N_max_quests" ]; do
			move_wait_click $X_quests_claim $Y_quests_claim 1
			i_claim=$((i_claim+1))
		done
	else
		echo "* skip weekly"
	fi
	focus_and_back_to_root_screen

	remove_task $current_servname.quests.todo
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
		source win_id.conf
		source switch.conf
		# LAST USAGE OF i_serv ON THE ITERATION
		if [ "$i_serv" != "$current_servname" ]; then
			echo "* server switch in wrong server"
			echo "**** SKIP THIS SERVER CYCLE ****"
			continue
		fi

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

		xdotool windowminimize --sync $gamewin_id
		echo "screen and cpu saving"
		sleep 2
		xdotool windowactivate --sync $termwin_id
		echo
		echo "interrupt with CTRL+C"
		echo "type any non space key + RETURN for manual mode"
		read -t 40 -p "or hit only RETURN to speed-up > " user_input1
		echo
		if [ -n "$user_input1" ]; then
			interactive_session
		fi

		check_scheduled_tasks
		echo "interrupt with CTRL+C"
		echo "type any non space key + RETURN for manual mode"
		read -t 20 -p "or hit only RETURN to speed-up > " user_input2
		echo
		if [ -n "$user_input2" ]; then
			interactive_scheduled
		fi

		read_timestamps "mapcycle" 12
		auto_reset_timestamps "mapcycle" 12

		xdotool windowactivate --sync $gamewin_id
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

		./daily-once.sh

		read_timestamps "mapcycle" 12
		auto_reset_timestamps "mapcycle" 12

		echo "... then auto alchemy"
		./auto-alch.sh

		echo "... then auto ftree"
		./auto-ftree.sh

		handle_fridaycode

		launch_claim_all_timer_income $gameover_status

		handle_quests_claim

		handle_auto_accept

		xdotool windowactivate --sync $termwin_id
		read_timestamps "mapcycle" 12
		auto_reset_timestamps "mapcycle" 12
		echo
		echo "***** LAST CHANCE TO CTRL+C BEFORE SERVER SWITCH *****"
		sleep 10
		echo "*** TOO LATE ! DO NOT INTERRUPT SERVER SWITCH ***"
	done
	log_msg "*** quit firestone ***"
	safe_quit

	echo
	echo "*** please let 8 minutes pause for computer cooling down ***"
	read -t 480 -p "** interrupt with RETURN "
	echo

	./firestone-starter.sh
	log_msg "*** firestone restarted ***"
	source win_id.conf

	i=$((i+1))
done
