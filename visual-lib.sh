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

PICDIR="./tmp"
start_ref_pic="$PICDIR/start-ref.png"

fav_server_list="s1 s27 s31 s8 s14 s25"
server_pic() {
	echo "$PICDIR/${1}-server-pic.png"
}

switch_fav_pic="$PICDIR/switch-fav-ref.png"

map_idle_notif_pic="$PICDIR/map-idle-notif.png"

ftree_rew_test_pic="$PICDIR/ftree-rewind.png"

# guild expedition pics
declare -gA guild_expe_button_pic_H=(
	["start"]="$PICDIR/expe-start.png"
	["claim"]="$PICDIR/expe-claim.png"
	["cancel"]="$PICDIR/expe-cancel.png"
	# blank image cannot work with ncc test
	#["none"]="$PICDIR/expe-none.png"
)

# trouble shooting on startup failure
# using that function for initialization : init_start_failure_pic()
cookie_expired_pic="$PICDIR/fail_cookie_expired.png"
cache_error_pic="$PICDIR/fail_cache_error.png"
restart_from_begin="$PICDIR/fail_restart_begin_error.png"

# check this on firefox start
armor_nologin_pic="$PICDIR/armor_nologin.png"

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
		#source switch.conf
		## AT THIS STAGE, ALL SERVERS ARE UNKNOWN
		## CANNOT USE switch.conf
		echo "** initializing server picture for $i_serv"
		make_ROI $x_servname_ul $y_servname_ul $x_servname_br $y_servname_br $(server_pic $i_serv)

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

enforce_real_servername_to_switch() {
	local find_result real_servername
	# performs a server name check
	find_real_servername
	find_result=$(tail -n 1 ./tmp/firestone.log)
	echo "$find_result"
	real_servername=$(echo "$find_result" | grep -oP 'real_servername=\K[^[:space:]]+$')

	# and enforce switch.conf value with real server name on startup
	echo "overwriting $real_servername to switch file"
	echo "current_servname=$real_servername" > switch.conf
	cat switch.conf
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

init_armor_games_nologin_pic() {
	echo "** start firefox, logout from armor games"
	read -p "press RETURN to take screenshot > "
	make_ROI $x_check_armor_login_ul $y_check_armor_login_ul $x_check_armor_login_br $y_check_armor_login_br $armor_nologin_pic
}

check_armor_games_nologin() {
	make_ROI $x_check_armor_login_ul $y_check_armor_login_ul $x_check_armor_login_br $y_check_armor_login_br /tmp/armor-login-check.png

	local ncc=""
	local compare=""
	ncc=$(ncc_similarity /tmp/armor-login-check.png $armor_nologin_pic)
	compare=$(echo "${ncc//e/E} > 0.9" | bc -l)
	log_msg "* armor games logout test : ncc=$ncc armor_logout=$compare"
}

### ### ### ### ### ### ### ### ####
### Failure detection on startup ###
### ### ### ### ### ### ### ### ####

init_start_failure_pic() {
	make_ROI $x_failure_screen_ul $y_failure_screen_ul $x_failure_screen_br $y_failure_screen_br $1

}

clear_firefox_cache_reload() {
	xdotool windowactivate --sync $gamewin_id
	move_wait_click $X_firefox_menu $Y_firefox_menu 5
	sleep 5
	move_wait_click $X_firefox_history $Y_firefox_history 5
	sleep 5
	move_wait_click $X_firefox_erase_history $Y_firefox_erase_history 5
	sleep 5
	move_wait_click $X_erase_confirm $Y_erase_confirm 5
	sleep 5
	move_wait_click $X_firefox_reload_page $Y_firefox_reload_page 5
	sleep 5
}

escape_intro_sequence() {
	xdotool windowactivate --sync $gamewin_id
	sleep 5
	move_wait_click $X_skip_intro_dialog $Y_skip_intro_dialog 5
	sleep 5
	move_wait_click $X_skip_intro_dialog $Y_skip_intro_dialog 5
	sleep 5
	# all hotkeys are disabled in that introduction sequence situation
	move_wait_click $X_setting_cogs $Y_setting_cogs 5
	sleep 5
	source switch.conf
	# current_servname contains former valid server value
	# check value of current_servname
	if [ "$current_servname" == "unknown" ]; then
		# just in case switch file is really corrupted
		current_servname="s31"
	fi
	# then overwrite switch file with unknown server name
	# in order to enforce real switch
	echo "current_servname=unknown" > switch.conf

	# only one try for favorite server reach
	./switch-server.sh $current_servname 1
}

check_fail_sequence() {
	local ok_crit=$(tail -n 1 ./tmp/firestone.log | grep 'success=1')
	if [ -n "$ok_crit" ]; then
		echo "** no failure **"
		return
	else
		echo "** failure check sequence starts **"
	fi
	# NOT REACHED IF SUCCESS

	make_ROI $x_failure_screen_ul $y_failure_screen_ul $x_failure_screen_br $y_failure_screen_br /tmp/failure-screen.png

	local ncc=""
	local compare=""

	ncc=$(ncc_similarity /tmp/failure-screen.png $cookie_expired_pic)
	compare=$(echo "${ncc//e/E} > 0.8" | bc -l)
	if [ "$compare" == "1" ]; then
		log_msg "* startup fail test : ncc=$ncc fail=cookie_expired"

		move_wait_click $X_accept_cookies $Y_accept_cookies 10
		sleep 5
		start_load_game
		./restore-game-view.sh
		return
	fi

	ncc=$(ncc_similarity /tmp/failure-screen.png $cache_error_pic)
	compare=$(echo "${ncc//e/E} > 0.6" | bc -l)
	if [ "$compare" == "1" ]; then
		log_msg "* startup fail test : ncc=$ncc fail=cache_error"

		clear_firefox_cache_reload
		sleep 5
		# reload page does not reset game view
		# clicking in any spot inside firestone square in armor game
		# will actually start loading
		# no need to click exactly on play button
		start_load_game
		./restore-game-view.sh
		return
	fi

	ncc=$(ncc_similarity /tmp/failure-screen.png $restart_from_begin)
	compare=$(echo "${ncc//e/E} > 0.6" | bc -l)
	if [ "$compare" == "1" ]; then
		log_msg "* startup fail test : ncc=$ncc fail=restart_begin"

		escape_intro_sequence
		# switch server will try one game restart in case of failure
		# this is a potentially infinite recursion case
		# then we need to introduce a mechanics preventing that
		# based on the 1 try case for favorite reach detection

		# in addition, server-switch script has a retry mechanics
		# on favorite server selection, based on escape hotkey
		# since hotkeys are disabled
		# this may lead to a worse corruption
		# that's why there is only 1 try for reaching fav servers

		# when fav reach fails, switch server exits
		# infite recursion may occur if fav is reached but
		# failure happens after

		# then no quit restart with firestone-starter if switch fails
		# a robust procedure is out of scope now
		# since we are already in troubleshooting situation

		## at the moment, 1 favorite server switch has been attempted
		## the value of switch.conf will tell about success status
		## further retry can be implemented according to the former
		## observations

		# soft reload the game just in case...
		# when this error occurs, server access is stuck
		# a reload is necessary : we do it anyway
		# TODO : may require some improvements
		xdotool windowactivate --sync $gamewin_id
		sleep 10
		move_wait_click $X_firefox_reload_page $Y_firefox_reload_page 5
		sleep 10
		# reload page does not reset game view
		# clicking in any spot inside firestone square in armor game
		# will actually start loading
		# no need to click exactly on play button
		start_load_game
		./restore-game-view.sh
		return
	fi
	# NOT REACHED IF FAIL DETECTED

	# FAIL UNKOWN
	log_msg "* startup fail test : ncc=$ncc fail=unknown"
	## DEFAULT ACTION IS CLEAR CACHE, RELOAD PAGE AND RESTORE GAME VIEW
	sleep 5
	clear_firefox_cache_reload
	sleep 5
	start_load_game
	./restore-game-view.sh
}


### ### ### ### ### ###
### ROBUST COMMANDS ###
### ### ### ### ### ###

safe_quit() {
	make_ROI $x_url_ul $y_url_ul $x_url_br $y_url_br /tmp/before_quit.png

	local i_try=1
	echo "* quit - attempt $i_try"
	basic_quit_firefox
	make_ROI $x_url_ul $y_url_ul $x_url_br $y_url_br /tmp/after_quit.png
	local ncc=$(ncc_similarity /tmp/before_quit.png /tmp/after_quit.png)
	local compare=$(echo "${ncc//e/E} > 0.5" | bc -l)
	log_msg "* quit attempt $i_try : ncc=$ncc fail=$compare"

	while [ "$compare" != "0" ] && [ "$i_try" -lt "6" ]; do
		i_try=$((i_try+1))
		echo "* quit - attempt $i_try"
		if [ "$i_try" -le "3" ]; then
			basic_quit_firefox
		else
			echo "* menu layout may have changed : close window"
			basic_quit_firefox force
		fi
		make_ROI $x_url_ul $y_url_ul $x_url_br $y_url_br /tmp/after_quit.png

		ncc=$(ncc_similarity /tmp/before_quit.png /tmp/after_quit.png)
		compare=$(echo "${ncc//e/E} > 0.5" | bc -l)
		log_msg "* quit attempt $i_try : ncc=$ncc fail=$compare"
	done
	# a last resort kill is necessary in case of crash on exit
	# or game crash before firefox quit process
	# image comparison could fail infinitely
	killall firefox
	killall crashreporter
	# this kill has no effect if firefox exits normally
	# it is intended to close the crash report prompt
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
	log_msg "* start failed ($i_check/$n_try) : ncc=$ncc success=$compare"

	### SECOND CHANCE WITH FAIL CHECK ###
	# only for blocking wait case
	if [ -z "$3" ]; then
		check_fail_sequence
		i_check=1
		while [ "$i_check" -le "$n_try" ]; do
			sleep $t_interval
			echo "* check $i_check"
			make_ROI $x_startref_ul $y_startref_ul $x_startref_br $y_startref_br /tmp/start-check.png

			ncc=$(ncc_similarity /tmp/start-check.png $start_ref_pic)
			compare=$(echo "${ncc//e/E} > 0.5" | bc -l)
			if [ "$compare" == "1" ]; then
				log_msg "* start second chance check $i_check/$n_try : ncc=$ncc success=$compare"
				return
			else
				echo "* wait $t_interval more sec."
			fi
			i_check=$((i_check+1))
		done
		log_msg "* second chance start failed ($i_check/$n_try) : ncc=$ncc success=$compare"

	fi
	# NOT REACHED IF SUCCESS

	local dummy=""
	echo
	if [ -z "$3" ]; then
		echo "*** There is a problem : human intervention required ***"
		log_msg "* failed to auto-restart game : bot stalled"
		if ! $DETACHED_BOT; then
			read -p "stop with CTRL+C or continue with RETURN " dummy
		else
			log_msg "* detached mode : exit now"
			screenshot
			mv /tmp/shot.png tmp/crashed-screen.png
			log_msg "* screenshot tmp/crashed-screen.png done"
			safe_quit
			# ensure everything is off
			# safe_quit always killall firefox
			killall_bots
			## scheduling respawn ##
			detached_cmd_line_launcher ./firestone-respawn.sh 60 /dev/null
			## ##
			exit 1
		fi
		log_msg "* human intervention now"
	else
		echo "*** There is a problem : further action is required ***"
		log_msg "* failed to auto-restart game on non blocking wait"
	fi
}

init_guild_button_pic() {
	if [ -z "$1" ]; then
		echo "no button name (start cancel claim) : do nothing"
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
