#!/bin/bash
source function-lib.sh

# THIS IS RADISH AUTOMATION TOOL
# CONFIGURATION SCRIPT

# Set the output file

if [ -f "switch.conf" ]; then
	echo "Server swich file detected"
	source switch.conf

	config_output="$current_servname.firestone.conf"
else
	echo "no server configuration file"
	config_output=firestone.conf
fi
echo "output set to $config_output"

radish_message "CONFIGURATION SCRIPT FOR CURRENCY FARM CYCLES"

# Set the game window ID

echo "Set game window id"
#read -p "press return key..."
#gamewin_id=$(xdotool getmouselocation | grep -oP 'window:\K\d+')
#echo id: $gamewin_id
./setwin_id.sh
source win_id.conf
echo read id: $gamewin_id
echo

# Show the way to expedition launch zone

echo "The guild expeditions"
echo "you will be asked to point the mouse several times on some places"
echo "please don't click in the game"
echo "follow the script's instructions"
echo
echo "let the script go to town first"
go_to_town

set_mouse_coordinates "guild portal" "X_guild_portal" "Y_guild_portal"
echo "guild portal at x: $X_guild_portal, y: $Y_guild_portal"
click_and_go $X_guild_portal $Y_guild_portal "guild portal"
echo
echo "now let's find the expedition building"
set_mouse_coordinates "expedition building" "X_exped" "Y_exped"
echo "expedition building at x: $X_exped, y: $Y_exped"
click_and_go $X_exped $Y_exped "expedition building"
echo
echo "now let's find the expedition launch and claim button"
set_mouse_coordinates "expedition launch and claim" "X_exped_but" "Y_exped_but"
echo "expedition button at x: $X_exped_but, y: $Y_exped_but"
echo

# Oracle rituals
# We assume that 4 oracle slots are unlocked
# It should work with 3 slots. Just provide a 4th location to netral spot
echo "The oracle rituals"
echo "you will be asked to point the mouse several times on some places"
echo "please don't click in the game"
echo "follow the script's instructions"
echo
echo "let the script go to oracle building first"
go_to_oracle

echo
echo "now let's find the rituals room"
set_mouse_coordinates "ritual icon" "X_ritual" "Y_ritual"
echo "ritual icon at x: $X_ritual, y: $Y_ritual"
click_and_go $X_ritual $Y_ritual "ritual room"
echo
echo "now let's get the 4 rituals buttons"
set_mouse_coordinates "ritual 1" "X_ritual_1" "Y_ritual_1"
echo "ritual button 1 at x: $X_ritual_1, y: $Y_ritual_1"
set_mouse_coordinates "ritual 2" "X_ritual_2" "Y_ritual_2"
echo "ritual button 2 at x: $X_ritual_2, y: $Y_ritual_2"
set_mouse_coordinates "ritual 3" "X_ritual_3" "Y_ritual_3"
echo "ritual button 3 at x: $X_ritual_3, y: $Y_ritual_3"
set_mouse_coordinates "ritual 4" "X_ritual_4" "Y_ritual_4"
echo "ritual button 4 at x: $X_ritual_4, y: $Y_ritual_4"
echo

# Guardian trainings
echo "The guardian trainings"
echo "you will be asked to point the mouse several times on some places"
echo "please don't click in the game"
echo "follow the script's instructions"
echo
echo "let the script go to guardian building first"
go_to_guardian

echo
echo "select the guardian you want to train"
set_mouse_coordinates "guardian" "X_guard" "Y_guard"
echo "guardian to train at x: $X_guard, y: $Y_guard"
echo
echo "locate the guardian training button"
set_mouse_coordinates "training button" "X_guard_train" "Y_guard_train"
echo "training button at x: $X_guard_train, y: $Y_guard_train"
echo

# Claim campaign loot
echo "Claim campaign loot"
echo "you will be asked to point the mouse several times on some places"
echo "please don't click in the game"
echo "follow the script's instructions"
echo
echo "let the script go to map first"
go_to_map

echo
echo "locate the campaign map selector"
set_mouse_coordinates "campaign map selector" "X_campaign" "Y_campaign"
echo "campaign map select at x: $X_campaign, y: $Y_campaign"
echo
click_and_go $X_campaign $Y_campaign "campaign map"
echo "locate the loot claim button"
set_mouse_coordinates "campaign loot claim" "X_campaign_loot" "Y_campaign_loot"
echo "campaign loot button at x: $X_campaign_loot, y: $Y_campaign_loot"
echo

# Claim tools
echo "Claim tools"
echo "you will be asked to point the mouse several times on some places"
echo "please don't click in the game"
echo "follow the script's instructions"
echo
echo "let the script go to town first"
go_to_town

echo
echo "locate the engineer building"
set_mouse_coordinates "engineer building" "X_engi" "Y_engi"
echo "engineer building at x: $X_engi, y: $Y_engi"
click_and_go $X_engi $Y_engi "engineer building"
echo
echo "locate the engineer workshop"
set_mouse_coordinates "engineer workshop" "X_engi_shop" "Y_engi_shop"
echo "engineer workshop at x: $X_engi_shop, y: $Y_engi_shop"
click_and_go $X_engi_shop $Y_engi_shop "engineer workshop"
echo
echo "locate the tool claim button"
set_mouse_coordinates "tool claim" "X_toolclaim" "Y_toolclaim"
echo "tool claim button at x: $X_toolclaim, y: $Y_toolclaim"
echo

echo "Save coordinates in a configuration file"

#echo "gamewin_id=${gamewin_id}" > firestone.conf
# now we don't keep anymore gamewinid with coordinates
echo "X_guild_portal=${X_guild_portal}" > $config_output
echo "Y_guild_portal=${Y_guild_portal}" >> $config_output
echo "X_exped=${X_exped}" >> $config_output
echo "Y_exped=${Y_exped}" >> $config_output
echo "X_exped_but=${X_exped_but}" >> $config_output
echo "Y_exped_but=${Y_exped_but}" >> $config_output
echo "X_ritual=${X_ritual}" >> $config_output
echo "Y_ritual=${Y_ritual}" >> $config_output
echo "X_ritual_1=${X_ritual_1}" >> $config_output
echo "Y_ritual_1=${Y_ritual_1}" >> $config_output
echo "X_ritual_2=${X_ritual_2}" >> $config_output
echo "Y_ritual_2=${Y_ritual_2}" >> $config_output
echo "X_ritual_3=${X_ritual_3}" >> $config_output
echo "Y_ritual_3=${Y_ritual_3}" >> $config_output
echo "X_ritual_4=${X_ritual_4}" >> $config_output
echo "Y_ritual_4=${Y_ritual_4}" >> $config_output
echo "X_guard=${X_guard}" >> $config_output
echo "Y_guard=${Y_guard}" >> $config_output
echo "X_guard_train=${X_guard_train}" >> $config_output
echo "Y_guard_train=${Y_guard_train}" >> $config_output
echo "X_campaign=${X_campaign}" >> $config_output
echo "Y_campaign=${Y_campaign}" >> $config_output
echo "X_campaign_loot=${X_campaign_loot}" >> $config_output
echo "Y_campaign_loot=${Y_campaign_loot}" >> $config_output
echo "X_engi=${X_engi}" >> $config_output
echo "Y_engi=${Y_engi}" >> $config_output
echo "X_engi_shop=${X_engi_shop}" >> $config_output
echo "Y_engi_shop=${Y_engi_shop}" >> $config_output
echo "X_toolclaim=${X_toolclaim}" >> $config_output
echo "Y_toolclaim=${Y_toolclaim}" >> $config_output
