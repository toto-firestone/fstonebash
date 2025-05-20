#!/bin/bash
source win_id.conf
source function-lib.sh

X_firefox_menu=1357
Y_firefox_menu=93
move_wait_click $X_firefox_menu $Y_firefox_menu 2
sleep 5

X_firefox_quit=1298
Y_firefox_quit=772
move_wait_click $X_firefox_quit $Y_firefox_quit 2

sleep 30
