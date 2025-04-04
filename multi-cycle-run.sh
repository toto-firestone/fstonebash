#!/bin/bash
source function-lib.sh

# THIS IS RADISH AUTOMATION TOOL
# MULTI SERVER RUN SCRIPT
# JUST EXPECT ./auto-cycle-config.sh has been successfully executed

radish_message "MULTISERVER RUN SCRIPT FOR CURRENCY FARM CYCLES"

if [ ! -f "win_id.conf" ]; then
	echo "please provide a window id file with setwin_id.sh"
	exit 1
fi

source win_id.conf

if [ -z "$@" ]; then
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


# disable with empty string
testing=""

i=1
while true; do
	echo
	echo "meta cycle ${i}"

	for i_serv in $@; do
		anti_ad
		./switch-server.sh $i_serv
		source switch.conf

		server_config="$current_servname.firestone.conf"
		echo "reading $server_config"
		source $server_config
		echo
		if [ -z "$testing" ]; then
			#echo "5 minutes manual mode... interrupt with CTRL+C"
			#sleep 120
			echo "3 minutes manual mode... interrupt with CTRL+C"
			sleep 120
			echo "1 minutes manual mode... interrupt with CTRL+C"
			sleep 50
			echo "manual mode ends in 10 secdonds"
			sleep 10
			echo "starting automated sequence"
		else
			echo "skip manual mode for testing"
		fi

		anti_ad
		launch_and_claim_expedition
		launch_and_claim_rituals
		train_guardian
		claim_campaign_loot
		claim_tools
		focus_and_back_to_root_screen
	done

	i=$((i+1))
done
