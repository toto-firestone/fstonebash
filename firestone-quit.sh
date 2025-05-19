#!/bin/bash
source win_id.conf

X_firefox_menu=1357
Y_firefox_menu=93
xdotool windowactivate --sync $gamewin_id
xdotool mousemove --sync $X_firefox_menu $Y_firefox_menu
sleep 1
xdotool click 1
sleep 1

X_firefox_quit=1298
Y_firefox_quit=772
xdotool mousemove --sync $X_firefox_quit $Y_firefox_quit
sleep 1
xdotool click 1
sleep 1
