#!/bin/bash
source function-lib.sh

radish_message "CONFIGURATION SCRIPT DAILY CURRENCY COLLECTING"

# reset window id configuration
./setwin_id.sh
source win_id.conf

# easiest one : oracle free gift

go_to_oracle
set_mouse_coordinates "oracle shop" "X_oracle_shop" "Y_oracle_shop"
click_and_go $X_oracle_shop $Y_oracle_shop
set_mouse_coordinates "free gift" "X_oracle_gift" "Y_oracle_gift"

# another easy one : shop and check-in
go_to_town
set_mouse_coordinates "main shop" "X_main_shop" "Y_main_shop"
click_and_go $X_main_shop $Y_main_shop
set_mouse_coordinates "free box" "X_free_box" "Y_free_box"
set_mouse_coordinates "check-in tab" "X_checkin_tab" "Y_checkin_tab"
click_and_go $X_checkin_tab $Y_checkin_tab
set_mouse_coordinates "check-in button" "X_checkin_but" "Y_checkin_but"

# the difficult one : sell stuffs other than gold items
go_to_exotic
# the up side part
set_mouse_coordinates "quantity toggle" "X_exo_toggle" "Y_exo_toggle"
set_mouse_coordinates "speed scroll" "X_speed_scroll" "Y_speed_scroll"
set_mouse_coordinates "damage scroll" "X_damage_scroll" "Y_damage_scroll"
set_mouse_coordinates "health scroll" "X_health_scroll" "Y_health_scroll"
set_mouse_coordinates "midas touch" "X_midas_touch" "Y_midas_touch"
echo "scrolling to the bottom part"
sleep 4
xdotool windowactivate $gamewin_id
xdotool click --repeat 30 --delay 200 5
set_mouse_coordinates "drums of war" "X_drum_war" "Y_drum_war"
set_mouse_coordinates "dragon armor" "X_dragon_armor" "Y_dragon_armor"
set_mouse_coordinates "guardian rune" "X_guardian_rune" "Y_guardian_rune"
set_mouse_coordinates "totem of agony" "X_totem_agony" "Y_totem_agony"
set_mouse_coordinates "totem of annihil" "X_totem_annihil" "Y_totem_annihil"

echo "X_oracle_shop=${X_oracle_shop}" > collect.conf
echo "Y_oracle_shop=${Y_oracle_shop}" >> collect.conf
echo "X_oracle_gift=${X_oracle_gift}" >> collect.conf
echo "Y_oracle_gift=${Y_oracle_gift}" >> collect.conf
echo "X_main_shop=${X_main_shop}" >> collect.conf
echo "Y_main_shop=${Y_main_shop}" >> collect.conf
echo "X_free_box=${X_free_box}" >> collect.conf
echo "Y_free_box=${Y_free_box}" >> collect.conf
echo "X_checkin_tab=${X_checkin_tab}" >> collect.conf
echo "Y_checkin_tab=${Y_checkin_tab}" >> collect.conf
echo "X_checkin_but=${X_checkin_but}" >> collect.conf
echo "Y_checkin_but=${Y_checkin_but}" >> collect.conf
echo "X_exo_toggle=${X_exo_toggle}" >> collect.conf
echo "Y_exo_toggle=${Y_exo_toggle}" >> collect.conf
echo "X_speed_scroll=${X_speed_scroll}" >> collect.conf
echo "Y_speed_scroll=${Y_speed_scroll}" >> collect.conf
echo "X_damage_scroll=${X_damage_scroll}" >> collect.conf
echo "Y_damage_scroll=${Y_damage_scroll}" >> collect.conf
echo "X_health_scroll=${X_health_scroll}" >> collect.conf
echo "Y_health_scroll=${Y_health_scroll}" >> collect.conf
echo "X_midas_touch=${X_midas_touch}" >> collect.conf
echo "Y_midas_touch=${Y_midas_touch}" >> collect.conf
echo "X_drum_war=${X_drum_war}" >> collect.conf
echo "Y_drum_war=${Y_drum_war}" >> collect.conf
echo "X_dragon_armor=${X_dragon_armor}" >> collect.conf
echo "Y_dragon_armor=${Y_dragon_armor}" >> collect.conf
echo "X_guardian_rune=${X_guardian_rune}" >> collect.conf
echo "Y_guardian_rune=${Y_guardian_rune}" >> collect.conf
echo "X_totem_agony=${X_totem_agony}" >> collect.conf
echo "Y_totem_agony=${Y_totem_agony}" >> collect.conf
echo "X_totem_annihil=${X_totem_annihil}" >> collect.conf
echo "Y_totem_annihil=${Y_totem_annihil}" >> collect.conf
