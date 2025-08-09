# this one can remain non executable
# use it with source visual-lib.sh

### ### ### ### ### ###
### BASIC FUNCTIONS ###
### ### ### ### ### ###

screenshot() {
	import -window root /tmp/shot.png
	#echo "* screenshot at /tmp/shot.png"
}

make_ROI() {
	screenshot
	local x_min=$1
	local y_min=$2
	local x_max=$3
	local y_max=$4
	local roi_file=$5
	local w_roi=$((x_max-x_min))
	local h_roi=$((y_max-y_min))
	local geom="${w_roi}x${h_roi}+${x_min}+${y_min}"
	#echo "* ROI is rectangle $geom"

	convert /tmp/shot.png -crop $geom $roi_file
}

ncc_similarity() {
	local img1=$1
	local img2=$2
	if [ ! -f "$img1" ] || [ ! -f "$img2" ]; then
		echo "0"
		return
	fi
	compare -metric NCC $img1 $img2 null: 2> /tmp/ncc.txt
	local comp_out=$(cat /tmp/ncc.txt)
	echo "$comp_out"
}


### ### ### ### ### ####
### GLOBAL VARIABLES ###
### ### ### ### ### ####

# Should not be here, but right now it's OK

start_ref_pic="./tmp/start-ref.png"

fav_server_list="s1 s27 s31 s8 s14"
server_pic() {
	echo "./tmp/${1}-server-pic.png"
}

switch_fav_pic="./tmp/switch-fav-ref.png"

map_idle_notif_pic="./tmp/map-idle-notif.png"

ftree_rew_test_pic="./tmp/ftree-rewind.png"

# guild expedition pics
declare -gA guild_expe_button_pic_H=(
	["start"]="./tmp/expe-start.png"
	["claim"]="./tmp/expe-claim.png"
	["cancel"]="./tmp/expe-cancel.png"
	# blank image cannot work with ncc test
	#["none"]="./tmp/expe-none.png"
)


#### ### ### ### ####
### VISUAL CHECKS ###
#### ### ### ### ####

test_freeze() {
	focus_and_back_to_root_screen
	make_ROI $x_irongard_ul $y_irongard_ul $x_irongard_br $y_irongard_br /tmp/test_freeze_root.png

	#go_to_town
	sleep 1
	xdotool key t
	sleep 3
	make_ROI $x_irongard_ul $y_irongard_ul $x_irongard_br $y_irongard_br /tmp/test_freeze_town.png

	local ncc=$(ncc_similarity /tmp/test_freeze_root.png /tmp/test_freeze_town.png)

	focus_and_back_to_root_screen

	local compare=$(echo "${ncc//e/E} > 0.5" | bc -l)
	log_msg "* test freeze $1 : ncc=$ncc freeze=$compare"
}

init_server_pic() {
	local i_serv=""
	for i_serv in $fav_server_list; do
		./switch-server.sh $i_serv
		go_to_settings
		source switch.conf
		echo "** initializing server picture for $current_servname"
		make_ROI $x_servname_ul $y_servname_ul $x_servname_br $y_servname_br $(server_pic $current_servname)

	done
}

find_real_servername() {
	local answer="unknown"
	local i_try=""

	go_to_settings
	sleep 3
	make_ROI $x_servname_ul $y_servname_ul $x_servname_br $y_servname_br /tmp/this-server-pic.png

	local ncc=""
	local compare=""
	for i_try in $fav_server_list; do
		#echo "* trying $(server_pic $i_try)"
		ncc=$(ncc_similarity /tmp/this-server-pic.png $(server_pic $i_try))

		#echo "* ncc=$ncc"
		compare=$(echo "${ncc//e/E} > 0.8" | bc -l)
		#echo "* trying to match with $i_try : $ncc"
		if [ "$compare" == "1" ]; then
			answer=$i_try
			break
		fi
	done
	log_msg "* real_servername=$answer"
}

init_switch_to_fav_pic() {
	go_to_settings
	source switch.conf
	move_wait_click $X_server_switch $Y_server_switch 3
	# this one deserves a triple click
	move_wait_click $X_fav_servers $Y_fav_servers 3
	move_wait_click $X_fav_servers $Y_fav_servers 2
	move_wait_click $X_fav_servers $Y_fav_servers 1
	make_ROI $x_switch_fav_ul $y_switch_fav_ul $x_switch_fav_br $y_switch_fav_br $switch_fav_pic

}

check_switch_to_fav_reached() {
	make_ROI $x_switch_fav_ul $y_switch_fav_ul $x_switch_fav_br $y_switch_fav_br /tmp/switch-fav.png

	local ncc=""
	local compare=""
	ncc=$(ncc_similarity /tmp/switch-fav.png $switch_fav_pic)
	compare=$(echo "${ncc//e/E} > 0.95" | bc -l)
	log_msg "* switch_fav_reached=$compare"
}

init_map_idle_picture() {
	echo "** go to map and make sure idle squad notification is on **"
	read -p "press RETURN to take screenshot > "
	make_ROI $x_map_idle_notif_ul $y_map_idle_notif_ul $x_map_idle_notif_br $y_map_idle_notif_br $map_idle_notif_pic
}

check_map_idle_notif() {
	make_ROI $x_map_idle_notif_ul $y_map_idle_notif_ul $x_map_idle_notif_br $y_map_idle_notif_br /tmp/map-idle-check.png

	local ncc=""
	local compare=""
	ncc=$(ncc_similarity /tmp/map-idle-check.png $map_idle_notif_pic)
	compare=$(echo "${ncc//e/E} > 0.95" | bc -l)
	log_msg "* map_idle_notif=$compare"
}

init_ftree_rewind_picture() {
	echo "** go to ftree and make sure it is rewinded **"
	read -p "press RETURN to take screenshot > "
	make_ROI $x_ftree_rew_test_ul $y_ftree_rew_test_ul $x_ftree_rew_test_br $y_ftree_rew_test_br $ftree_rew_test_pic
}

check_ftree_rewind() {
	make_ROI $x_ftree_rew_test_ul $y_ftree_rew_test_ul $x_ftree_rew_test_br $y_ftree_rew_test_br /tmp/ftree-rewind-test.png

	local ncc=""
	local compare=""
	ncc=$(ncc_similarity /tmp/ftree-rewind-test.png $ftree_rew_test_pic)
	compare=$(echo "${ncc//e/E} > 0.6" | bc -l)
	log_msg "* ftree rewind test : ncc=$ncc ftree_rewind=$compare"
}


### ### ### ### ### ###
### ROBUST COMMANDS ###
### ### ### ### ### ###

safe_quit() {
	make_ROI $x_url_ul $y_url_ul $x_url_br $y_url_br /tmp/before_quit.png

	local i_try=1
	echo "* quit - attempt $i_try"
	./firestone-quit.sh
	make_ROI $x_url_ul $y_url_ul $x_url_br $y_url_br /tmp/after_quit.png
	local ncc=$(ncc_similarity /tmp/before_quit.png /tmp/after_quit.png)
	local compare=$(echo "${ncc//e/E} > 0.5" | bc -l)
	log_msg "* quit attempt $i_try : ncc=$ncc fail=$compare"

	while [ "$compare" != "0" ]; do
		i_try=$((i_try+1))
		echo "* quit - attempt $i_try"
		./firestone-quit.sh
		make_ROI $x_url_ul $y_url_ul $x_url_br $y_url_br /tmp/after_quit.png

		ncc=$(ncc_similarity /tmp/before_quit.png /tmp/after_quit.png)
		compare=$(echo "${ncc//e/E} > 0.5" | bc -l)
		log_msg "* quit attempt $i_try : ncc=$ncc fail=$compare"
	done
	echo "* quit successful"
}

init_start_ref_picture() {
	make_ROI $x_startref_ul $y_startref_ul $x_startref_br $y_startref_br $start_ref_pic
}

# does not make sense to retry forever
# just don't let the bot play on nothing
# wait for human intervention after a timeout
# or let it go if 3rd argument is provided
wait_game_start() {
	local n_try=$1
	local t_interval=$2
	if [ -z "$3" ]; then
		echo "** blocking wait **"
		log_msg "** blocking wait **"
	else
		echo "** non-blocking wait **"
		log_msg "** non-blocking wait **"
	fi

	local i_check=1
	local ncc=0
	local compare=0
	while [ "$i_check" -le "$n_try" ]; do
		sleep $t_interval
		echo "* check $i_check"
		make_ROI $x_startref_ul $y_startref_ul $x_startref_br $y_startref_br /tmp/start-check.png

		ncc=$(ncc_similarity /tmp/start-check.png $start_ref_pic)
		compare=$(echo "${ncc//e/E} > 0.5" | bc -l)
		if [ "$compare" == "1" ]; then
			log_msg "* start check $i_check/$n_try : ncc=$ncc success=$compare"
			return
		else
			echo "* wait $t_interval more sec."
		fi
		i_check=$((i_check+1))
	done
	# NOT REACHED IF SUCCESS
	local dummy=""
	log_msg "* start failed ($i_check/$n_try) : ncc=$ncc success=$compare"
	echo
	if [ -z "$3" ]; then
		echo "*** There is a problem : human intervention required ***"
		read -p "stop with CTRL+C or continue with RETURN " dummy
		log_msg "* human intervention now"
	else
		echo "*** There is a problem : further action is required ***"
	fi
}

init_guild_button_pic() {
	if [ -z "$1" ]; then
		echo "no button name (start cancel claim none) : do nothing"
		return
	fi

	# opens expedition window
	go_to_town
	move_wait_click $X_guild_portal $Y_guild_portal 2
	move_wait_only $X_exped $Y_exped 6
	super_slow_click

	make_ROI $x_guild_expe_but_ul $y_guild_expe_but_ul $x_guild_expe_but_br $y_guild_expe_but_br ${guild_expe_button_pic_H[$1]}

}

get_guild_expe_button() {
	make_ROI $x_guild_expe_but_ul $y_guild_expe_but_ul $x_guild_expe_but_br $y_guild_expe_but_br "/tmp/current-expe-but.png"

	local compare="0"
	local ncc_start=$(ncc_similarity /tmp/current-expe-but.png ${guild_expe_button_pic_H["start"]})
	#echo "* guild expedition button ncc_start=$ncc_start"
	# beware arbitrary small number in scientific notation
	compare=$(echo "${ncc_start//e/E} > 0.9" | bc -l)
	if [ "$compare" == "1" ]; then
		log_msg "* exped button : ncc=$ncc_start id=start"
		return
	fi

	local ncc_cancel=$(ncc_similarity /tmp/current-expe-but.png ${guild_expe_button_pic_H["cancel"]})
	#echo "* guild expedition button ncc_cancel=$ncc_cancel"
	compare=$(echo "${ncc_cancel//e/E} > 0.9" | bc -l)
	if [ "$compare" == "1" ]; then
		log_msg "* exped button : ncc=$ncc_cancel id=cancel"
		return
	fi

	local ncc_claim=$(ncc_similarity /tmp/current-expe-but.png ${guild_expe_button_pic_H["claim"]})
	#echo "* guild expedition button ncc_claim=$ncc_claim"
	compare=$(echo "${ncc_claim//e/E} > 0.9" | bc -l)
	if [ "$compare" == "1" ]; then
		log_msg "* exped button : ncc=$ncc_claim id=claim"
		return
	fi
	# UNKNOWN PIC IF REACHED
	log_msg "* exped button : ncc=0 id=none"
}
