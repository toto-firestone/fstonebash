#!/bin/bash
source glob-coord.conf
source master.conf
source function-lib.sh
source visual-lib.sh

radish_message_noprompt "Automated Map tool"

source map.conf

if [ -z "$current_servname" ]; then
	echo "Error : cannot read any server name"
	exit
fi

### Getting sync with mapcycle timestamp

time_file="$current_servname.mapcycle.timestamp"
elapsed=$(get_elapsed $time_file)
echo "*** $elapsed half-hours since mapcycle start on $current_servname ***"

go_to_map
sleep 10
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
sleep 6
check_map_idle_notif
no_idle_test=$(tail -n 1 ./tmp/firestone.log | grep 'map_idle_notif=0')
if [ -n "$no_idle_test" ]; then
	echo
	echo "*** no idle squads after claim : SKIP ***"
	echo "*** map empty or all squads busy ***"
	echo
	exit
fi
# NOT REACHED IF NO IDLING SQUAD

### High value mission during first 2 hours

if [ "$elapsed" -le "3" ]; then
	echo "** doing high value missions before 4 half-hours"

	curr_60B_flag=${tier_60B_H[$current_servname]:-false}
	if $curr_60B_flag; then
		echo "* 60B tier unlocked on $current_servname"
		for i_m in ${!X_60B_map_mission_A[@]}; do
			X_mission=${X_60B_map_mission_A[$i_m]}
			Y_mission=${Y_60B_map_mission_A[$i_m]}
			echo "* try $i_m : mission X=$X_mission Y=$Y_mission (60B)"

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
		echo "* skip 60B tier on $current_servname"
	fi

	echo "** other high value missions (<= 5B tier)"
	for i_m in ${!X_HV_map_mission_A[@]}; do
		X_mission=${X_HV_map_mission_A[$i_m]}
		Y_mission=${Y_HV_map_mission_A[$i_m]}
		echo "* try $i_m : mission X=$X_mission Y=$Y_mission (HV)"
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
if $(game_is_over_on_server $current_servname); then
	echo "*** game over : skip war, adventure and scout missions ***"
	exit
fi

### War missions during first 3 hours
# update for parametric timing
war_tf=4
# legacy value is 5
# trying 4 in order to clear the map a bit sooner

if [ "$elapsed" -le "$war_tf" ]; then
	echo "** do war between half-hours 0 and $war_tf"
	for i_m in ${!X_war_map_mission_A[@]}; do
		X_mission=${X_war_map_mission_A[$i_m]}
		Y_mission=${Y_war_map_mission_A[$i_m]}
		echo "* try $i_m : mission X=$X_mission Y=$Y_mission (WR)"
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
	echo "** skip war outside half-hours 0 and $war_tf"
fi

### Adventure missions in 4th and 5th hours
# update for parametric timing
adv_t0=$((war_tf+1))
adv_tf=$((adv_t0+3))

if [ "$elapsed" -ge "$adv_t0" ] && [ "$elapsed" -le "$adv_tf" ]; then
	echo "** do adventure between half-hours $adv_t0 and $adv_tf"
	for i_m in ${!X_adv_map_mission_A[@]}; do
		X_mission=${X_adv_map_mission_A[$i_m]}
		Y_mission=${Y_adv_map_mission_A[$i_m]}
		echo "* try $i_m : mission X=$X_mission Y=$Y_mission (AD)"
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
	echo "** skip adventure outside half-hours $adv_t0 and $adv_tf"
fi

### Scout missions during last hour
# update for parametric timing
sco_t0=$((adv_tf+1))
sco_tf="11"

if [ "$elapsed" -ge "$sco_t0" ] && [ "$elapsed" -le "$sco_tf" ]; then
	echo "** do scout during half-hours $sco_t0 and $sco_tf"
	for i_m in ${!X_sco_map_mission_A[@]}; do
		X_mission=${X_sco_map_mission_A[$i_m]}
		Y_mission=${Y_sco_map_mission_A[$i_m]}
		echo "* try $i_m : mission X=$X_mission Y=$Y_mission (SC)"
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
	echo "** skip scout outside half-hours $sco_t0 and $sco_tf"
fi
