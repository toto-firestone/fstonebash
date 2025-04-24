#!/bin/bash
source function-lib.sh
source win_id.conf
source view.conf

radish_message_noprompt "Automated Map tool"

source map.conf
source switch.conf

if [ -z "$current_servname" ]; then
	echo "Error : cannot read any server name"
	exit
fi

go_to_map

n_squad=${N_squads_H[$current_servname]}
echo "* claiming $n_squad map missions"

i_claim="0"
while [ "$i_claim" -lt "$n_squad" ]; do
	click_and_go $X_map_mission_claim $Y_map_mission_claim
	sleep 1
	i_claim=$((i_claim+1))
done

fast_return_to_map() {
	xdotool windowactivate --sync $gamewin_id
	sleep .5
	xdotool key Escape
	sleep .5
	xdotool key Escape
	sleep .5
	xdotool key m
	sleep .5
}

fast_return_to_map

for i_m in ${!X_HV_map_mission_A[@]}; do
	X_mission=${X_HV_map_mission_A[$i_m]}
	Y_mission=${Y_HV_map_mission_A[$i_m]}
	echo "* try $i_m : mission X=$X_mission Y=$Y_mission"
	if [ -z "$Y_mission" ]; then
		echo "* missing Y for X=$X_mission"
		continue;
	fi
	# NOT REACHED if coordinates are incomplete
	click_and_go $X_mission $Y_mission
	click_and_go $X_map_mission_start $Y_map_mission_start
	fast_return_to_map
done
