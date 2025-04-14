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
echo "very basic checks performed..."


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
		read -t 120 -p "or hit only RETURN to speed-up"
		echo
		echo "1 minutes idle mode... interrupt with CTRL+C"
		echo "type any key + RETURN for manual mode"
		read -t 50 -p "or hit only RETURN to speed-up"
		echo
		echo "idle mode ends in 10 secdonds"
		sleep 10
		echo "starting automated sequence"
		xdotool windowactivate --sync $gamewin_id

		launch_claim_all_timer_income
	done

	i=$((i+1))
done
