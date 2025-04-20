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


interactive_session() {
	local actions="Quit Assisted-Map Brute-Force Learn-Map"

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
			* ) echo "Invalid choice : $i_todo"
				continue;;
		esac
	done
}


### ### ### ###

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

		xdotool windowminimize --sync $gamewin_id
		echo "screen and cpu saving during idle mode"
		sleep 2
		xdotool windowactivate --sync $termwin_id
		echo
		echo "3 minutes idle mode... interrupt with CTRL+C"
		echo "type any key + RETURN for manual mode"
		read -t 120 -p "or hit only RETURN to speed-up > " user_input
		echo
		if [ -n "$user_input" ]; then
			interactive_session
		fi
		echo "1 minutes idle mode... interrupt with CTRL+C"
		echo "type any key + RETURN for manual mode"
		read -t 50 -p "or hit only RETURN to speed-up > " user_input
		echo
		if [ -n "$user_input" ]; then
			interactive_session
		fi
		echo "idle mode ends in 10 secdonds"
		sleep 10
		echo "starting automated sequence"
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
