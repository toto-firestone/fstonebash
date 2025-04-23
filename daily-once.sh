#!/bin/bash

# ONLY ONCE PER DAY TASKS
# DO NOT RUN TWICE A DAY

read -p "MAKE SURE YOU RUN IT ONCE A DAY. Press return or CTRL+C"


source daily.conf
source switch.conf
echo "Let's start on $current_servname"

Nlibe=${Nlibe_H[$current_servname]-"0"}
Ndung=${Ndung_H[$current_servname]-"0"}
if ${do_libe_H[$current_servname]}; then
	echo "doing $Nlibe liberations and $Ndung dungeons"
	./auto-wm-run.sh $Nlibe $Ndung
else
	echo "skip WM daily missions"
fi
if ${do_collect_H[$current_servname]}; then
	echo "doing auto daily collect"
	./auto-collect-run.sh
else
	echo "skip daily collect"
fi

