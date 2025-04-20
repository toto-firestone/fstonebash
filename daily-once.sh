#!/bin/bash

# ONLY ONCE PER DAY TASKS
# DO NOT RUN TWICE A DAY

read -p "MAKE SURE YOU RUN IT ONCE A DAY. Press return or CTRL+C"

echo "Let's go"

./switch-server.sh s27

Nlibe=6
Ndung=1
./auto-wm-run.sh $Nlibe $Ndung
./auto-collect-run.sh

#read -p "Manual check and correct before switching server"

./switch-server.sh s1

Nlibe=8
Ndung=2
./auto-wm-run.sh $Nlibe $Ndung
./auto-collect-run.sh

#read -p "Manual check and correct before switching server"

./switch-server.sh s14

Nlibe=7
Ndung=2
./auto-wm-run.sh $Nlibe $Ndung
./auto-collect-run.sh

#read -p "Manual check and correct before switching server"

./switch-server.sh s8

Nlibe=6
Ndung=1

#./auto-wm-run.sh $Nlibe $Ndung
# no more liberation on s8
./auto-collect-run.sh

# only a daily visit on s25
./switch-server.sh s25

Nlibe=3
Ndung=0

