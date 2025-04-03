#!/bin/bash

# THIS IS RADISH AUTOMATION TOOL
# MULTI SERVER RUN SCRIPT
# JUST EXPECT ./auto-cycle-config.sh has been successfully executed

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

### ### ### ###
# retype the functions and make some changes

focus_and_back_to_root_screen() {
	sleep 1
	xdotool windowactivate $gamewin_id
	sleep 1
	xdotool key Escape
	sleep 1
	xdotool key Escape
	sleep 1
	xdotool key Escape
	sleep 1
	xdotool key Escape
	sleep 1
	xdotool key Escape
}

focus_and_go_to_town() {
	sleep 1
	xdotool windowactivate $gamewin_id
	sleep 1
	xdotool key Escape
	sleep 1
	xdotool key Escape
	sleep 1
	xdotool key Escape
	sleep 1
	xdotool key Escape
	sleep 1
	xdotool key Escape
	sleep 1
	xdotool key t
}

# not same name as in auto-cycle-config.sh
launch_and_claim_expedition() {
	focus_and_go_to_town
	sleep 1
	xdotool mousemove $X_guild_portal $Y_guild_portal click 1
	sleep 1
	xdotool mousemove $X_exped $Y_exped click 1
	sleep 2
	xdotool mousemove $X_exped_but $Y_exped_but click 1
	sleep 4
	xdotool mousemove $X_exped_but $Y_exped_but click 1
}

launch_and_claim_rituals() {
	focus_and_back_to_root_screen
	sleep 1
	xdotool key o
	sleep 1
	xdotool mousemove $X_ritual $Y_ritual click 1
	sleep 2
	xdotool mousemove $X_ritual_1 $Y_ritual_1 click 1
	sleep 4
	xdotool mousemove $X_ritual_1 $Y_ritual_1 click 1
	sleep 4
	xdotool mousemove $X_ritual_2 $Y_ritual_2 click 1
	sleep 4
	xdotool mousemove $X_ritual_2 $Y_ritual_2 click 1
	sleep 4
	xdotool mousemove $X_ritual_3 $Y_ritual_3 click 1
	sleep 4
	xdotool mousemove $X_ritual_3 $Y_ritual_3 click 1
	sleep 4
	xdotool mousemove $X_ritual_4 $Y_ritual_4 click 1
	sleep 4
	xdotool mousemove $X_ritual_4 $Y_ritual_4 click 1
}

train_guardian() {
	focus_and_back_to_root_screen
	sleep 1
	xdotool key g
	sleep 1
	xdotool mousemove $X_guard $Y_guard click 1
	sleep 2
	xdotool mousemove $X_guard_train $Y_guard_train click 1
}

claim_campaign_loot() {
	focus_and_back_to_root_screen
	sleep 1
	xdotool key m
	sleep 1
	xdotool mousemove $X_campaign $Y_campaign click 1
	sleep 2
	xdotool mousemove $X_campaign_loot $Y_campaign_loot click 1
}

claim_tools() {
	focus_and_go_to_town
	sleep 1
	xdotool mousemove $X_engi $Y_engi click 1
	sleep 1
	xdotool mousemove $X_engi_shop $Y_engi_shop click 1
	sleep 2
	xdotool mousemove $X_toolclaim $Y_toolclaim click 1
}

### ### ### ###

echo "THIS IS RADISH AUTOMATION TOOL \\o/"
echo "DISCLAIMER : always keep in mind what a happy radish is"
read -p "press return key..."

# disable with empty string
testing=""

i=1
while true; do
	echo
	echo "meta cycle ${i}"

	for i_serv in $@; do
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

		launch_and_claim_expedition
		launch_and_claim_rituals
		train_guardian
		claim_campaign_loot
		claim_tools
		focus_and_back_to_root_screen
	done

	i=$((i+1))
done
