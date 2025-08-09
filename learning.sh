#!/bin/bash
source glob-coord.conf
source master.conf
source function-lib.sh

radish_message_noprompt "Learning tools for map automation"
source map.conf

if [ ! -d "./map-lab/" ]; then
	echo "Error : ./map-lab/ directory not found"
	exit 1
fi

if [ ! -d "./map-lab/raw-data/" ]; then
	echo "Error : ./map-lab/raw-data/ directory not found"
	exit 1
fi

DATA_FILE="./map-lab/raw-data/$CURR_DATAFILE"

if [ -f "$DATA_FILE" ]; then
	echo "data file found : $DATA_FILE"
else
	echo "creating datafile : $DATA_FILE"
	touch $DATA_FILE
fi

#
# Defining constatants
#

TAG_SCO="1"
TAG_ADV="2"
TAG_WAR="3"
TAG_MON="4"
TAG_DRA="5"
TAG_NAV="6"
TAG_TIT="7"

MISSION_LIST="scout adventure war monster dragon naval titan"


while true; do
	# restart with fresh view at each input
	# it's quite complex to figure out possible game states
	# after failure, cancelation
	go_to_map
	set_mouse_coordinates "a mission to learn" "X_mission" "Y_mission"
	test_and_exit $X_mission $Y_mission
	echo "set the type of this map mission"
	select i_mission in $MISSION_LIST; do
		break;
	done
	if [ -n "$i_mission" ]; then
		echo "selected ${i_mission}"
	else
		echo "nothing valid selected"
	fi
	case $i_mission in
		scout ) i_tag=$TAG_SCO;;
		adventure ) i_tag=$TAG_ADV;;
		war ) i_tag=$TAG_WAR;;
		monster ) i_tag=$TAG_MON;;
		dragon ) i_tag=$TAG_DRA;;
		naval ) i_tag=$TAG_NAV;;
		titan ) i_tag=$TAG_TIT;;
		* ) echo "Unknown mission : exit now"
			break;;
	esac
	echo "tag=$i_tag"

	click_and_go $X_mission $Y_mission "testing coordinates"
	xdotool windowactivate --sync $termwin_id
	echo "****** ****** ****** ****** ****** ******* ****** ******"
	echo "MAKE SURE MAP HAS NOT BEEN MOVED BEFORE VALIDATING INPUT"
	echo "****** ****** ****** ****** ****** ******* ****** ******"
	echo "type any NON SPACE KEY + RETURN to validate"
	read -p "otherwise NOTHING + RETURN to cancel > " i_valid
	if [ -n "$i_valid" ]; then
		csv_line="$X_mission,$Y_mission,$i_tag"
	else
		echo
		echo "invalid coordinates : cancel and continue"
		echo
		continue;
	fi
	# NOT REACHED IF NO csv_line
	echo
	echo "going to write : $csv_line"
	echo
	echo $csv_line >> $DATA_FILE
	click_and_go $X_map_mission_start $Y_map_mission_start "start mission"
done
