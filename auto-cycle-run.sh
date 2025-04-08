#!/bin/bash
source function-lib.sh

# THIS IS RADISH AUTOMATION TOOL
# RUN SCRIPT
# JUST EXPECT ./auto-cycle-config.sh has been successfully executed

if [ ! -f "win_id.conf" ]; then
	echo "please provide a window id file with setwin_id.sh"
	exit 1
fi

source win_id.conf

if [ -f "switch.conf" ]; then
	echo "Server swich file detected"
	source switch.conf

	server_config="$current_servname.firestone.conf"
	echo "looking for $server_config"
	if [ -f "$server_config" ]; then
		echo "$server_config found"
		source $server_config
	else
		echo "$server_config not found"
		echo "using default firestone.conf and hope it works..."
		source firestone.conf
	fi
else
	echo "no server configuration file"
	echo "using default firestone.conf and hope it works..."
	source firestone.conf
fi

radish_message "RUN SCRIPT FOR CURRENCY FARM CYCLES"

i=1
while true; do
	echo
	echo "cycle ${i}"

	launch_claim_all_timer_income

	echo
	echo "5 minutes manual mode... interrupt with CTRL+C"
	sleep 120
	echo "3 minutes manual mode... interrupt with CTRL+C"
	sleep 120
	echo "1 minutes manual mode... interrupt with CTRL+C"
	sleep 50
	echo "manual mode ends in 10 secdonds"
	sleep 10
	echo "starting automated sequence"
	i=$((i+1))
done
