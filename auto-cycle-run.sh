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

### ### ### ###

launch_and_claim_expedition() {
	go_to_town
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
	go_to_oracle
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
	go_to_guardian
	sleep 1
	xdotool mousemove $X_guard $Y_guard click 1
	sleep 2
	xdotool mousemove $X_guard_train $Y_guard_train click 1
}

claim_campaign_loot() {
	go_to_map
	sleep 1
	xdotool mousemove $X_campaign $Y_campaign click 1
	sleep 2
	xdotool mousemove $X_campaign_loot $Y_campaign_loot click 1
}

claim_tools() {
	go_to_town
	sleep 1
	xdotool mousemove $X_engi $Y_engi click 1
	sleep 1
	xdotool mousemove $X_engi_shop $Y_engi_shop click 1
	sleep 2
	xdotool mousemove $X_toolclaim $Y_toolclaim click 1
}

### ### ### ###

i=1
while true; do
	echo
	echo "cycle ${i}"

	launch_and_claim_expedition
	launch_and_claim_rituals
	train_guardian
	claim_campaign_loot
	claim_tools
	focus_and_back_to_root_screen

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
	anti_ad
done
