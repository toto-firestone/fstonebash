#!/bin/bash
source glob-coord.conf
source win_id.conf
source function-lib.sh

move_wait_click $X_firefox_menu $Y_firefox_menu 2
sleep 5

move_wait_click $X_firefox_quit $Y_firefox_quit 2

sleep 30
