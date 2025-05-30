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

xdotool windowactivate --sync $gamewin_id
anti_ad
go_to_oracle
move_wait_click $X_oracle_shop $Y_oracle_shop 2
move_wait_click $X_oracle_gift $Y_oracle_gift 2

go_to_town
move_wait_click $X_main_shop $Y_main_shop 2
move_wait_click $X_free_box $Y_free_box 2
move_wait_click $X_checkin_tab $Y_checkin_tab 2
echo "Warning : check-in button may change place when special offer occurs"
echo "a wrong check-in coordinate is not harmful"
move_wait_click $X_checkin_but $Y_checkin_but 2
echo "try alternative position..."
move_wait_click $X_checkin_but $((Y_checkin_but+46)) 2

go_to_exotic
# toggle to X50
move_wait_click $X_exo_toggle $Y_exo_toggle 2
move_wait_click $X_exo_toggle $Y_exo_toggle 2

move_wait_click $X_speed_scroll $Y_speed_scroll 2
move_wait_click $X_damage_scroll $Y_damage_scroll 2
move_wait_click $X_health_scroll $Y_health_scroll 2
move_wait_click $X_midas_touch $Y_midas_touch 2

echo "scrolling to the bottom part"
sleep 2
roll_scroll_down 30
sleep 2

move_wait_click $X_drum_war $Y_drum_war 2
move_wait_click $X_dragon_armor $Y_dragon_armor 2
move_wait_click $X_guardian_rune $Y_guardian_rune 2
move_wait_click $X_totem_agony $Y_totem_agony 2
move_wait_click $X_totem_annihil $Y_totem_annihil 2

echo "claim pickaxes"
./claim-pickaxe.sh

focus_and_back_to_root_screen

