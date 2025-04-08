#!/bin/bash
source function-lib.sh

if [ ! -f "win_id.conf" ]; then
	echo "please provide a window id file with setwin_id.sh"
	exit 1
fi

source win_id.conf

if [ ! -f "collect.conf" ]; then
	echo "please provide a collect.conf file with auto-collect-config.sh"
	exit 1
fi

source collect.conf

radish_message_noprompt "FARMING DAILY CURRENCIES"

go_to_oracle
click_and_go $X_oracle_shop $Y_oracle_shop
click_and_go $X_oracle_gift $Y_oracle_gift

go_to_town
click_and_go $X_main_shop $Y_main_shop
click_and_go $X_free_box $Y_free_box
click_and_go $X_checkin_tab $Y_checkin_tab
echo "Warning : check-in button may change place when special offer occurs"
echo "a wrong check-in coordinate is not harmful"
click_and_go $X_checkin_but $Y_checkin_but
echo "try alternative position..."
click_and_go $X_checkin_but $((Y_checkin_but+46))

go_to_exotic
# toggle to X50
click_and_go $X_exo_toggle $Y_exo_toggle
click_and_go $X_exo_toggle $Y_exo_toggle

click_and_go $X_speed_scroll $Y_speed_scroll
click_and_go $X_damage_scroll $Y_damage_scroll
click_and_go $X_health_scroll $Y_health_scroll
click_and_go $X_midas_touch $Y_midas_touch

echo "scrolling to the bottom part"
sleep 4
xdotool windowactivate $gamewin_id
xdotool click --repeat 30 --delay 200 5

click_and_go $X_drum_war $Y_drum_war
click_and_go $X_dragon_armor $Y_dragon_armor
click_and_go $X_guardian_rune $Y_guardian_rune
click_and_go $X_totem_agony $Y_totem_agony
click_and_go $X_totem_annihil $Y_totem_annihil

focus_and_back_to_root_screen

