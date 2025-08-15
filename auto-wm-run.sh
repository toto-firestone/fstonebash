#!/bin/bash
source glob-coord.conf
source master.conf
source function-lib.sh
source tricky-dailies.sh

# THIS IS RADISH AUTOMATION TOOL
# DAILY WM RUN SCRIPT

radish_message_noprompt "DAILY WM RUN SCRIPT"

if [ -z "$1" ]; then
	echo "error : argument 1 should be number of liberation missions"
	exit 1
fi
N_liber=$1

if [ -z "$2" ]; then
	echo "error : argument 2 should be number of dungeon missions"
	exit 1
fi
N_dung=$2

if [ -n "$3" ]; then
	T_fight_sec=$3
	echo "* liberation time set to $T_fight_sec secs."
else
	T_fight_sec=60
	echo "* liberation time defaut value is $T_fight_sec secs."
fi

echo "** Runnung with $N_liber liberations and $N_dung dungeons"

if [[ "$N_liber" -le "0" && "$N_dung" -le "0" ]]; then
	echo "Nothing to do"
	exit 0
fi

### ### ### ###
anti_ad

auto_liberation_dungeon $N_liber $N_dung $T_fight_sec

echo "Daily WM missions done"
