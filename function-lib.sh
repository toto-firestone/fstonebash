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
