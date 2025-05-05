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

### Getting sync with mapcycle timestamp

time_file="$current_servname.mapcycle.timestamp"
elapsed=$(get_elapsed $time_file)
echo "*** $elapsed half-hours since mapcycle start on $current_servname ***"

go_to_map

n_squad=${N_squads_H[$current_servname]}
echo "* claiming $n_squad map missions"

### Always claim

i_claim="0"
while [ "$i_claim" -lt "$n_squad" ]; do
	move_wait_click $X_map_mission_claim $Y_map_mission_claim 1
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

### High value mission during first 2 hours

if [ "$elapsed" -le "3" ]; then
	echo "** doing high value missions before 4 half-hours"
	for i_m in ${!X_HV_map_mission_A[@]}; do
		X_mission=${X_HV_map_mission_A[$i_m]}
		Y_mission=${Y_HV_map_mission_A[$i_m]}
		echo "* try $i_m : mission X=$X_mission Y=$Y_mission"
		if [ -z "$Y_mission" ]; then
			echo "* missing Y for X=$X_mission"
			continue;
		fi
		# NOT REACHED if coordinates are incomplete
		move_wait_click $X_mission $Y_mission 3
		move_wait_click $X_map_mission_start $Y_map_mission_start 1
		fast_return_to_map
	done
else
	echo "** skip high value missions after 4 half-hours"
fi

### game over ###
source gameover.conf
if $(game_is_over_on_server $current_servname); then
	echo "*** game over : skip war, adventure and scout missions ***"
	exit
fi

### War missions during first 3 hours

if [ "$elapsed" -le "5" ]; then
	echo "** doing war missions before 6 half-hours"
	for i_m in ${!X_war_map_mission_A[@]}; do
		X_mission=${X_war_map_mission_A[$i_m]}
		Y_mission=${Y_war_map_mission_A[$i_m]}
		echo "* try $i_m : mission X=$X_mission Y=$Y_mission"
		if [ -z "$Y_mission" ]; then
			echo "* missing Y for X=$X_mission"
			continue;
		fi
		# NOT REACHED if coordinates are incomplete
		move_wait_click $X_mission $Y_mission 3
		move_wait_click $X_map_mission_start $Y_map_mission_start 1
		fast_return_to_map
	done
else
	echo "** skip war missions after 6 half-hours"
fi

### Adventure missions in 4th and 5th hours

if [ "$elapsed" -ge "6" ] && [ "$elapsed" -le "9" ]; then
	echo "** doing adventure missions between half-hours 6 and 9"
	for i_m in ${!X_adv_map_mission_A[@]}; do
		X_mission=${X_adv_map_mission_A[$i_m]}
		Y_mission=${Y_adv_map_mission_A[$i_m]}
		echo "* try $i_m : mission X=$X_mission Y=$Y_mission"
		if [ -z "$Y_mission" ]; then
			echo "* missing Y for X=$X_mission"
			continue;
		fi
		# NOT REACHED if coordinates are incomplete
		move_wait_click $X_mission $Y_mission 3
		move_wait_click $X_map_mission_start $Y_map_mission_start 1
		fast_return_to_map
	done
else
	echo "** skip adventure missions outside half-hours 6 and 9"
fi

### Scout missions during last hour

if [ "$elapsed" -ge "10" ] && [ "$elapsed" -le "11" ]; then
	echo "** doing scout missions during half-hours 10 and 11"
	for i_m in ${!X_sco_map_mission_A[@]}; do
		X_mission=${X_sco_map_mission_A[$i_m]}
		Y_mission=${Y_sco_map_mission_A[$i_m]}
		echo "* try $i_m : mission X=$X_mission Y=$Y_mission"
		if [ -z "$Y_mission" ]; then
			echo "* missing Y for X=$X_mission"
			continue;
		fi
		# NOT REACHED if coordinates are incomplete
		move_wait_click $X_mission $Y_mission 3
		move_wait_click $X_map_mission_start $Y_map_mission_start 1
		fast_return_to_map
	done
else
	echo "** skip scout missions outside half-hours 10 and 11"
fi
