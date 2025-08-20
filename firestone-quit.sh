#!/bin/bash
source glob-coord.conf
source master.conf
source function-lib.sh

xdotool windowactivate --sync $gamewin_id
sleep 3

move_wait_click $X_firefox_menu $Y_firefox_menu 2
sleep 5

move_wait_click $X_firefox_quit $Y_firefox_quit 2

sleep 30
