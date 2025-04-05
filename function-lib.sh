# this one can remain non executable
# use it with source function-lib.sh


radish_message() {
	echo "THIS IS RADISH AUTOMATION TOOL \\o/"
	echo "$1"
	echo "DISCLAIMER : always keep in mind what a happy radish is"
	read -p "press return key... or CTRL+C :)"
}

radish_message_noprompt() {
	echo "THIS IS RADISH AUTOMATION TOOL \\o/"
	echo "$1"
	echo "DISCLAIMER : always keep in mind what a happy radish is"
}

set_mouse_coordinates() {
	sleep 1
	xdotool windowactivate $termwin_id
	echo "stay in the terminal where the script is running"
	read -p "put your mouse pointer above $1 and hit return key"
	local mouseloc=$(xdotool getmouselocation)
	local cmd_X="$2=\$(echo "\$mouseloc" | grep -oP 'x:\\K\\d+')"
	#echo $cmd_X
	local cmd_Y="$3=\$(echo "\$mouseloc" | grep -oP 'y:\\K\\d+')"
	#echo $cmd_Y
	eval $cmd_X
	eval $cmd_Y
}

### ### ### ### ### ###
## MOTION FUNCTIONS  ##
### ### ### ### ### ###

click_and_go() {
	if [ -n "$3" ]; then
		echo "let's move to $3"
	fi
	sleep 1
	# gamewin_id is a global variable defined by
        # source win_id.conf
	xdotool windowactivate $gamewin_id
	sleep 1
	xdotool mousemove $1 $2 click 1
}

focus_and_back_to_root_screen() {
	sleep 1
	xdotool windowactivate $gamewin_id
	sleep 1
	xdotool key Escape
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
	focus_and_back_to_root_screen
	sleep 1
	xdotool key t
}

go_to_oracle() {
	focus_and_back_to_root_screen
	sleep 1
	xdotool key o
}

go_to_guardian() {
	focus_and_back_to_root_screen
	sleep 1
	xdotool key g
}

go_to_map() {
	focus_and_back_to_root_screen
	sleep 1
	xdotool key m
}

go_to_exotic() {
	focus_and_back_to_root_screen
	sleep 1
	xdotool key x
}

anti_ad() {
	click_and_go $X_game_tab $Y_game_tab "anti-ad"
}

### ### ### ### ### ###
## ACTION FUNCTIONS  ##
### ### ### ### ### ###

launch_and_claim_expedition() {
	go_to_town
	sleep 1
	xdotool mousemove $X_guild_portal $Y_guild_portal click 1
	sleep 1
	xdotool mousemove $X_exped $Y_exped click 1
	sleep 2
	xdotool mousemove $X_exped_but $Y_exped_but click 1
	sleep 4
	xdotool mousemove $X_exped_but $Y_exped_but click 1
}

launch_and_claim_rituals() {
	go_to_oracle
	sleep 1
	xdotool mousemove $X_ritual $Y_ritual click 1
	sleep 2
	xdotool mousemove $X_ritual_1 $Y_ritual_1 click 1
	sleep 4
	xdotool mousemove $X_ritual_1 $Y_ritual_1 click 1
	sleep 4
	xdotool mousemove $X_ritual_2 $Y_ritual_2 click 1
	sleep 4
	xdotool mousemove $X_ritual_2 $Y_ritual_2 click 1
	sleep 4
	xdotool mousemove $X_ritual_3 $Y_ritual_3 click 1
	sleep 4
	xdotool mousemove $X_ritual_3 $Y_ritual_3 click 1
	sleep 4
	xdotool mousemove $X_ritual_4 $Y_ritual_4 click 1
	sleep 4
	xdotool mousemove $X_ritual_4 $Y_ritual_4 click 1
}

train_guardian() {
	go_to_guardian
	sleep 2
	xdotool mousemove $X_guard $Y_guard click 1
	sleep 2
	xdotool mousemove $X_guard_train $Y_guard_train click 1
}

claim_campaign_loot() {
	go_to_map
	sleep 1
	xdotool mousemove $X_campaign $Y_campaign click 1
	sleep 2
	xdotool mousemove $X_campaign_loot $Y_campaign_loot click 1
}

claim_tools() {
	go_to_town
	sleep 1
	xdotool mousemove $X_engi $Y_engi click 1
	sleep 1
	xdotool mousemove $X_engi_shop $Y_engi_shop click 1
	sleep 2
	xdotool mousemove $X_toolclaim $Y_toolclaim click 1
}

### ### ### ### ###
