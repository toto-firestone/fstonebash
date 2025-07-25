#!/bin/bash
source function-lib.sh

# THIS IS RADISH AUTOMATION TOOL
# SERVER CONFIGURATION SCRIPT

radish_message "SERVER CONFIGURATION SCRIPT"

if [ -z "$1" ]; then
	echo Error : expecting at least 1 server name as argument
	exit 1
fi

echo "Configuring servers config files for : $@"
for servname in "$@"; do
	serv_conf="$servname.firestone.conf"
	echo "server file : $serv_conf"
	echo "i_guardian_slot=1" > $serv_conf
done
echo
