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

x_irongard_ul=501
y_irongard_ul=176
x_irongard_br=881
y_irongard_br=215

x_url_ul=258
y_url_ul=73
x_url_br=1123
y_url_br=103

start_ref_pic="./tmp/start-ref.png"
x_startref_ul=72
y_startref_ul=699
x_startref_br=109
y_startref_br=732

x_servname_ul=877
y_servname_ul=442
x_servname_br=1210
y_servname_br=555
fav_server_list="s1 s27 s31 s8 s14"
server_pic() {
	echo "./tmp/${1}-server-pic.png"
}

x_switch_fav_ul=352
y_switch_fav_ul=211
x_switch_fav_br=1023
y_switch_fav_br=320
switch_fav_pic="./tmp/switch-fav-ref.png"

x_map_idle_notif_ul=344
y_map_idle_notif_ul=854
x_map_idle_notif_br=853
y_map_idle_notif_br=876
map_idle_notif_pic="./tmp/map-idle-notif.png"

x_ftree_rew_test_ul=55
y_ftree_rew_test_ul=371
x_ftree_rew_test_br=154
y_ftree_rew_test_br=669
ftree_rew_test_pic="./tmp/ftree-rewind.png"


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

	local compare=$(echo "$ncc > 0.5" | bc -l)
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
		compare=$(echo "$ncc > 0.8" | bc -l)
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
	source $current_servname
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
	compare=$(echo "$ncc > 0.95" | bc -l)
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
	compare=$(echo "$ncc > 0.95" | bc -l)
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
	compare=$(echo "$ncc > 0.6" | bc -l)
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
	local compare=$(echo "$ncc > 0.5" | bc -l)
	log_msg "* quit attempt $i_try : ncc=$ncc fail=$compare"

	while [ "$compare" != "0" ]; do
		i_try=$((i_try+1))
		echo "* quit - attempt $i_try"
		./firestone-quit.sh
		make_ROI $x_url_ul $y_url_ul $x_url_br $y_url_br /tmp/after_quit.png

		ncc=$(ncc_similarity /tmp/before_quit.png /tmp/after_quit.png)
		compare=$(echo "$ncc > 0.5" | bc -l)
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
		compare=$(echo "$ncc > 0.5" | bc -l)
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

