#!/bin/bash
source function-lib.sh

# THIS IS RADISH AUTOMATION TOOL
# CONFIGURATION SCRIPT

radish_message "CONFIGURATION SCRIPT FOR CURRENCY FARM CYCLES"

# step 1 : get the game window ID

echo "step 1 : set game window id"
#read -p "press return key..."
#gamewin_id=$(xdotool getmouselocation | grep -oP 'window:\K\d+')
#echo id: $gamewin_id
./setwin_id.sh
source win_id.conf
echo read id: $gamewin_id
echo

### ### ### ###

back_to_root_screen() {
	sleep 1
	xdotool key Escape
	sleep 1
	xdotool key Escape
	sleep 1
	xdotool key Escape
	sleep 1
	xdotool key Escape
}

go_to_town() {
	sleep 1
	xdotool key Escape
	sleep 1
	xdotool key Escape
	sleep 1
	xdotool key Escape
	sleep 1
	xdotool key Escape
	sleep 1
	xdotool key t
}

prompt_mouse_position() {
	echo "click back to the terminal where the script is running"
	read -p "put your mouse pointer above $1 and hit return key"
}

### ### ### ###

# step 2 : show the way to expedition launch zone

echo "step 2 : the guild expeditions"
echo "you will be asked to point the mouse several times on some places"
echo "please don't click in the game"
echo "follow the script's instructions"
echo
echo "let the script go to town first"
xdotool windowactivate $gamewin_id
#back_to_root_screen
go_to_town
prompt_mouse_position "guild portal"
mouseloc=$(xdotool getmouselocation)
X_guild_portal=$(echo "$mouseloc" | grep -oP 'x:\K\d+')
Y_guild_portal=$(echo "$mouseloc" | grep -oP 'y:\K\d+')
echo "guild portal at x: $X_guild_portal, y: $Y_guild_portal"
click_and_go $X_guild_portal $Y_guild_portal "guild portal"
echo
echo "now let's find the expedition building"
prompt_mouse_position "expedition building"
mouseloc=$(xdotool getmouselocation)
X_exped=$(echo "$mouseloc" | grep -oP 'x:\K\d+')
Y_exped=$(echo "$mouseloc" | grep -oP 'y:\K\d+')
echo "expedition building at x: $X_exped, y: $Y_exped"
click_and_go $X_exped $Y_exped "expedition building"
echo
echo "now let's find the expedition launch and claim button"
prompt_mouse_position "expedition launch and claim button"
mouseloc=$(xdotool getmouselocation)
X_exped_but=$(echo "$mouseloc" | grep -oP 'x:\K\d+')
Y_exped_but=$(echo "$mouseloc" | grep -oP 'y:\K\d+')
echo "expedition button at x: $X_exped_but, y: $Y_exped_but"
echo

### ### ### ###

lauch_claim_expedition() {
	sleep 1
	xdotool windowactivate $gamewin_id
	go_to_town
	sleep 1
	xdotool mousemove $X_guild_portal $Y_guild_portal click 1
	sleep 1
	xdotool mousemove $X_exped $Y_exped click 1
	sleep 1
	xdotool mousemove $X_exped_but $Y_exped_but click 1
	sleep 5
	xdotool mousemove $X_exped_but $Y_exped_but click 1
}
# try it once
#lauch_claim_expedition

### ### ### ###

# step 3 : Oracle rituals
# We assume that 4 oracle slots are unlocked
# It should work with 3 slots. Just provide a 4th location to netral spot
echo "step 3 : the oracle rituals"
echo "you will be asked to point the mouse several times on some places"
echo "please don't click in the game"
echo "follow the script's instructions"
echo
echo "let the script go to oracle building first"
xdotool windowactivate $gamewin_id
back_to_root_screen
sleep 1
xdotool key o
echo
echo "now let's find the rituals room"
prompt_mouse_position "ritual icon"
mouseloc=$(xdotool getmouselocation)
X_ritual=$(echo "$mouseloc" | grep -oP 'x:\K\d+')
Y_ritual=$(echo "$mouseloc" | grep -oP 'y:\K\d+')
echo "ritual icon at x: $X_ritual, y: $Y_ritual"
click_and_go $X_ritual $Y_ritual "ritual room"
echo
echo "now let's get the 4 rituals buttons"
prompt_mouse_position "ritual 1"
mouseloc=$(xdotool getmouselocation)
X_ritual_1=$(echo "$mouseloc" | grep -oP 'x:\K\d+')
Y_ritual_1=$(echo "$mouseloc" | grep -oP 'y:\K\d+')
echo "ritual button 1 at x: $X_ritual_1, y: $Y_ritual_1"
prompt_mouse_position "ritual 2"
mouseloc=$(xdotool getmouselocation)
X_ritual_2=$(echo "$mouseloc" | grep -oP 'x:\K\d+')
Y_ritual_2=$(echo "$mouseloc" | grep -oP 'y:\K\d+')
echo "ritual button 2 at x: $X_ritual_2, y: $Y_ritual_2"
prompt_mouse_position "ritual 3"
mouseloc=$(xdotool getmouselocation)
X_ritual_3=$(echo "$mouseloc" | grep -oP 'x:\K\d+')
Y_ritual_3=$(echo "$mouseloc" | grep -oP 'y:\K\d+')
echo "ritual button 3 at x: $X_ritual_3, y: $Y_ritual_3"
prompt_mouse_position "ritual 4"
mouseloc=$(xdotool getmouselocation)
X_ritual_4=$(echo "$mouseloc" | grep -oP 'x:\K\d+')
Y_ritual_4=$(echo "$mouseloc" | grep -oP 'y:\K\d+')
echo "ritual button 4 at x: $X_ritual_4, y: $Y_ritual_4"
echo

### ### ### ###

launch_and_claim_rituals() {
	sleep 1
	xdotool windowactivate $gamewin_id
	back_to_root_screen
	sleep 1
	xdotool key o
	sleep 1
	xdotool mousemove $X_ritual $Y_ritual click 1
	sleep 1

	xdotool mousemove $X_ritual_1 $Y_ritual_1 click 1
	sleep 5
	xdotool mousemove $X_ritual_1 $Y_ritual_1 click 1
	sleep 5
	xdotool mousemove $X_ritual_2 $Y_ritual_2 click 1
	sleep 5
	xdotool mousemove $X_ritual_2 $Y_ritual_2 click 1
	sleep 5
	xdotool mousemove $X_ritual_3 $Y_ritual_3 click 1
	sleep 5
	xdotool mousemove $X_ritual_3 $Y_ritual_3 click 1
	sleep 5
	xdotool mousemove $X_ritual_4 $Y_ritual_4 click 1
	sleep 5
	xdotool mousemove $X_ritual_4 $Y_ritual_4 click 1
	sleep 5
}
# try it once
#launch_and_claim_rituals

### ### ### ###

# step 4 : guardian trainings
echo "step 4 : the guardian trainings"
echo "you will be asked to point the mouse several times on some places"
echo "please don't click in the game"
echo "follow the script's instructions"
echo
echo "let the script go to guardian building first"
xdotool windowactivate $gamewin_id
back_to_root_screen
sleep 1
xdotool key g
echo
echo "select the guardian you want to train"
prompt_mouse_position "guardian"
mouseloc=$(xdotool getmouselocation)
X_guard=$(echo "$mouseloc" | grep -oP 'x:\K\d+')
Y_guard=$(echo "$mouseloc" | grep -oP 'y:\K\d+')
echo "guardian to train at x: $X_guard, y: $Y_guard"
echo
echo "locate the guardian training button"
prompt_mouse_position "training button"
mouseloc=$(xdotool getmouselocation)
X_guard_train=$(echo "$mouseloc" | grep -oP 'x:\K\d+')
Y_guard_train=$(echo "$mouseloc" | grep -oP 'y:\K\d+')
echo "training button at x: $X_guard_train, y: $Y_guard_train"
echo

### ### ### ###

train_guardian() {
	sleep 1
	xdotool windowactivate $gamewin_id
	back_to_root_screen
	sleep 1
	xdotool key g
	sleep 1
	xdotool mousemove $X_guard $Y_guard click 1
	sleep 1
	xdotool mousemove $X_guard_train $Y_guard_train click 1
}
# try it once
#train_guardian

### ### ### ###

# step 5 : claim campaign loot
echo "step 5 : claim campaign loot"
echo "you will be asked to point the mouse several times on some places"
echo "please don't click in the game"
echo "follow the script's instructions"
echo
echo "let the script go to map first"
xdotool windowactivate $gamewin_id
back_to_root_screen
sleep 1
xdotool key m
echo
echo "locate the campaign map selector"
prompt_mouse_position "campaign map selector"
mouseloc=$(xdotool getmouselocation)
X_campaign=$(echo "$mouseloc" | grep -oP 'x:\K\d+')
Y_campaign=$(echo "$mouseloc" | grep -oP 'y:\K\d+')
echo "campaign map select at x: $X_campaign, y: $Y_campaign"
echo
click_and_go $X_campaign $Y_campaign "campaign map"
echo "locate the loot claim button"
prompt_mouse_position "campaign loot claim"
mouseloc=$(xdotool getmouselocation)
X_campaign_loot=$(echo "$mouseloc" | grep -oP 'x:\K\d+')
Y_campaign_loot=$(echo "$mouseloc" | grep -oP 'y:\K\d+')
echo "campaign loot button at x: $X_campaign_loot, y: $Y_campaign_loot"
echo

### ### ### ###

claim_campaign_loot() {
	sleep 1
	xdotool windowactivate $gamewin_id
	back_to_root_screen
	sleep 1
	xdotool key m
	sleep 1
	xdotool mousemove $X_campaign $Y_campaign click 1
	sleep 1
	xdotool mousemove $X_campaign_loot $Y_campaign_loot click 1
}
# try it once
#claim_campaign_loot

### ### ### ###

# step 6 : claim tools
echo "step 6 : claim tools"
echo "you will be asked to point the mouse several times on some places"
echo "please don't click in the game"
echo "follow the script's instructions"
echo
echo "let the script go to town first"
xdotool windowactivate $gamewin_id
back_to_root_screen
sleep 1
xdotool key t
echo
echo "locate the engineer building"
prompt_mouse_position "engineer building"
mouseloc=$(xdotool getmouselocation)
X_engi=$(echo "$mouseloc" | grep -oP 'x:\K\d+')
Y_engi=$(echo "$mouseloc" | grep -oP 'y:\K\d+')
echo "engineer building at x: $X_engi, y: $Y_engi"
click_and_go $X_engi $Y_engi "engineer building"
echo
echo "locate the engineer workshop"
prompt_mouse_position "engineer workshop"
mouseloc=$(xdotool getmouselocation)
X_engi_shop=$(echo "$mouseloc" | grep -oP 'x:\K\d+')
Y_engi_shop=$(echo "$mouseloc" | grep -oP 'y:\K\d+')
echo "engineer workshop at x: $X_engi_shop, y: $Y_engi_shop"
click_and_go $X_engi_shop $Y_engi_shop "engineer workshop"
echo
echo "locate the tool claim button"
prompt_mouse_position "tool claim"
mouseloc=$(xdotool getmouselocation)
X_toolclaim=$(echo "$mouseloc" | grep -oP 'x:\K\d+')
Y_toolclaim=$(echo "$mouseloc" | grep -oP 'y:\K\d+')
echo "tool claim button at x: $X_toolclaim, y: $Y_toolclaim"
echo

### ### ### ###

claim_tools() {
	sleep 1
	xdotool windowactivate $gamewin_id
	back_to_root_screen
	sleep 1
	xdotool key t
	sleep 1
	xdotool mousemove $X_engi $Y_engi click 1
	sleep 1
	xdotool mousemove $X_engi_shop $Y_engi_shop click 1
	sleep 1
	xdotool mousemove $X_toolclaim $Y_toolclaim click 1
}
# try it once
#claim_tools

### ### ### ###

echo "final step : save coordinates in a configuration file"

#echo "gamewin_id=${gamewin_id}" > firestone.conf
# now we don't keep anymore gamewinid with coordinates
echo "X_guild_portal=${X_guild_portal}" > firestone.conf
echo "Y_guild_portal=${Y_guild_portal}" >> firestone.conf
echo "X_exped=${X_exped}" >> firestone.conf
echo "Y_exped=${Y_exped}" >> firestone.conf
echo "X_exped_but=${X_exped_but}" >> firestone.conf
echo "Y_exped_but=${Y_exped_but}" >> firestone.conf
echo "X_ritual=${X_ritual}" >> firestone.conf
echo "Y_ritual=${Y_ritual}" >> firestone.conf
echo "X_ritual_1=${X_ritual_1}" >> firestone.conf
echo "Y_ritual_1=${Y_ritual_1}" >> firestone.conf
echo "X_ritual_2=${X_ritual_2}" >> firestone.conf
echo "Y_ritual_2=${Y_ritual_2}" >> firestone.conf
echo "X_ritual_3=${X_ritual_3}" >> firestone.conf
echo "Y_ritual_3=${Y_ritual_3}" >> firestone.conf
echo "X_ritual_4=${X_ritual_4}" >> firestone.conf
echo "Y_ritual_4=${Y_ritual_4}" >> firestone.conf
echo "X_guard=${X_guard}" >> firestone.conf
echo "Y_guard=${Y_guard}" >> firestone.conf
echo "X_guard_train=${X_guard_train}" >> firestone.conf
echo "Y_guard_train=${Y_guard_train}" >> firestone.conf
echo "X_campaign=${X_campaign}" >> firestone.conf
echo "Y_campaign=${Y_campaign}" >> firestone.conf
echo "X_campaign_loot=${X_campaign_loot}" >> firestone.conf
echo "Y_campaign_loot=${Y_campaign_loot}" >> firestone.conf
echo "X_engi=${X_engi}" >> firestone.conf
echo "Y_engi=${Y_engi}" >> firestone.conf
echo "X_engi_shop=${X_engi_shop}" >> firestone.conf
echo "Y_engi_shop=${Y_engi_shop}" >> firestone.conf
echo "X_toolclaim=${X_toolclaim}" >> firestone.conf
echo "Y_toolclaim=${Y_toolclaim}" >> firestone.conf
